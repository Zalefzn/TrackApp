// ignore_for_file: unused_local_variable, unused_element, avoid_print, unused_field

import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';

//package
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackapp/config/config.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _Home2();
}

class _Home2 extends State<HomePage2>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool _isSwitched = false;
  StreamSubscription<Position>? _positionStreamSubscription;
  late TabController _tabController;
  final Battery _battery = Battery();
  Position? _currentPosition;
  Position? _endPosition;
  double _lastDirection = 0.0;
  double _totalDistance = 0.0;
  bool _isSendingData = false;
  bool _isConnected = false;
  String _timestamp = '';
  int _batteryLevel = 0;
  Timer? _timer;
  List<String> statusHistory = [];
  File? _image;
  String? username;
  String? distanceDisplay;

  // Controller inputs
  TextEditingController deviceId = TextEditingController();
  TextEditingController serverURL = TextEditingController();
  TextEditingController distance = TextEditingController();
  TextEditingController frequency = TextEditingController();
  TextEditingController angle = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _getCurrentTimestamp();
    _getSwitchedState();
    _loadImage();
    _getBatteryLevel();
    _initGyroscope();
    _startLocationTracking();
    _loadData();
    _startForegroundService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _positionStreamSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('userImage');
    setState(() {
      _image =
          imagePath != null && imagePath.isNotEmpty ? File(imagePath) : null;
    });
  }

  Future<void> _initGyroscope() async {
    // ignore: deprecated_member_use
    accelerometerEvents.listen((AccelerometerEvent event) {
      _lastDirection = _calculateDirection(event.x, event.y);
      _checkDirectionChange();
    });
  }

  void _checkDirectionChange() {
    double degreeThreshold = double.tryParse(angle.text) ?? 30.0;
    double directionDifference = (_lastDirection - _lastDirection).abs();

    if (directionDifference >= degreeThreshold - 1 &&
        directionDifference <= degreeThreshold + 1) {
      if (_isSwitched) {
        _sendDataToServer(_lastDirection);
      }
      print(
          'Direction change detected: ${_lastDirection.toStringAsFixed(2)} degrees');
    }
  }

  double _calculateDirection(double x, double y) {
    double radians = atan2(y, x);
    double degrees = radians * (180 / pi);
    return (degrees + 360) % 360;
  }

  Future<void> _getBatteryLevel() async {
    final int batteryLevel = await _battery.batteryLevel;
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Future<void> _saveSwitchState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSwitched', value);
  }

  Future<void> _getSwitchedState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSwitched = prefs.getBool('isSwitched') ?? false;
    });
  }

  void _startLocationTracking() {
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        distanceDisplay = 'Location permissions are permanently denied';
      });
      return;
    }

    if (permission == LocationPermission.denied) {
      setState(() {
        distanceDisplay = 'Location permissions are denied';
      });
      return;
    }

    const LocationSettings locationOptions = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationOptions,
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
      });
      if (_isSwitched) {
        _sendDataToServer(double.tryParse(angle.text) ?? 30.0);
        _checkDistanceChange(position);
      }
    });
  }

  void _checkDistanceChange(Position currentPosition) {
    double distanceThreshold = double.tryParse(distance.text) ?? 50.0;
    if (_endPosition != null) {
      double distance = Geolocator.distanceBetween(
        _endPosition!.latitude,
        _endPosition!.longitude,
        currentPosition.latitude,
        currentPosition.longitude,
      );

      _totalDistance += distance;

      if (_totalDistance >= distanceThreshold) {
        _sendDataToServer(_totalDistance);
        _totalDistance = 0;
        print('$distanceThreshold meters traveled, data sent to server.');
      }
    }
    _endPosition = currentPosition;
  }

  void _getCurrentTimestamp() {
    _timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    print('timestamp: $_timestamp');
  }

  void _startSendingData() {
    if (_timer != null) {
      _timer!.cancel();
    }

    int frequencyValue = int.tryParse(frequency.text) ?? 5;
    _timer = Timer.periodic(Duration(seconds: frequencyValue), (timer) {
      _sendDataToServer(_lastDirection);
    });

    setState(() {
      _isSendingData = true;
    });
  }

  void _stopSendingData() {
    _timer?.cancel();
    setState(() {
      _isSendingData = false;
    });
  }

  Future<void> _sendDataToServer(double rotation) async {
    if (deviceId.text.isEmpty ||
        deviceId.text == 'Unknown' ||
        deviceId.text == 'Permission denied') {
      print('DeviceId not available');
      return;
    }

    if (_currentPosition == null) {
      print('Current position is not available');
      return;
    }

    double distanceValue = double.tryParse(distance.text) ?? 0.0;
    double angleValue = rotation;
    int frequencyValue = int.tryParse(frequency.text) ?? 0;

    String serverUrl = '${serverURL.text}/?id=${deviceId.text}'
        '&lat=${_currentPosition?.latitude}'
        '&lon=${_currentPosition?.longitude}'
        '&timestamp=$_timestamp'
        '&speed=${_currentPosition?.speed}'
        '&bearing=${_currentPosition?.heading}'
        '&altitude=${_currentPosition?.altitude}'
        '&accuracy=${_currentPosition?.accuracy}'
        '&hdop=0.8'
        '&batt=$_batteryLevel'
        '&distance=$distanceValue'
        '&angle=$angleValue'
        '&frequency=$frequencyValue';

    setState(() {
      _isSendingData = true;
    });

    try {
      final response = await http.post(Uri.parse(serverUrl));
      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _isConnected = true;
          statusHistory.insert(0,
              'Location Updated - ${DateFormat.yMd().add_jm().format(DateTime.now())}');
        });
      } else {
        setState(() {
          _isConnected = false;
          statusHistory.insert(0,
              'Location Not Found - ${DateFormat.yMd().add_jm().format(DateTime.now())}');
        });
        print('Failed to send data: ${response.statusCode}');
      }
      await Future.delayed(const Duration(seconds: 5));
    } catch (e) {
      setState(() {
        _isConnected = false;
        _isSendingData = false;
        statusHistory.insert(
            0, 'Error - ${DateFormat.yMd().add_jm().format(DateTime.now())}');
      });
      print('Error: $e');
    }

    setState(() {
      _isSendingData = false;
    });
  }

  void clearHistory() {
    setState(() {
      statusHistory.clear();
    });
  }

  Future<void> information() async {
    await Navigator.pushNamedAndRemoveUntil(
        context, '/profile', (route) => false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _saveData();
    }
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceId', deviceId.text);
    await prefs.setString('serverURL', serverURL.text);
    await prefs.setString('frequency', frequency.text);
    await prefs.setString('distance', distance.text);
    await prefs.setString('angle', angle.text);
  } 

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    deviceId.text = prefs.getString('deviceId') ?? '';
    serverURL.text = prefs.getString('serverURL') ?? '';
    frequency.text = prefs.getString('frequency') ?? '';
    distance.text = prefs.getString('distance') ?? '';
    angle.text = prefs.getString('angle') ?? '';
    username = prefs.getString('current_username'); 
  }

  void _startForegroundService() {  
    try {
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'foreground_service',
          channelName: 'Foreground Service Notification',
          channelDescription:
              'This notification appears when the foreground service is running.',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
        ),
        iosNotificationOptions: const IOSNotificationOptions(),
        foregroundTaskOptions: const ForegroundTaskOptions(
          interval: 5000,
          isOnceEvent: false,
          autoRunOnBoot: true,
          allowWakeLock: true,
          allowWifiLock: true,
        ),
      );
    } catch (e) {
      print('Error starting foreground service: $e');
    }
  }

  void _onCreate() {
    print('Foreground Task Created');
    // Add any additional initialization code here
  }

  void _onDestroy() {
    print('Foreground Task Destroyed');
    // Add any cleanup code here
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    Widget header() {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(10),
          height: SizeConfig.blockVertical * 9,
          width: SizeConfig.blockHorizontal * 90,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  image: _image != null && _image!.path.isNotEmpty
                      ? DecorationImage(
                          image: FileImage(_image!),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: AssetImage('assets/profile.png'),
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(username ?? 'username not found',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      )),
                  const Text('Avanza',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  information();
                },
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      image: const DecorationImage(
                          image: AssetImage('assets/setting.png')),
                      borderRadius: BorderRadius.circular(50)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget inputContent() {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: SizeConfig.blockVertical * 2),
              const Text(
                'Isi informasi berikut untuk data\npelacakan perangkat.',
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: SizeConfig.blockVertical * 5),
              const Text(
                'Device Identifier',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              Container(
                margin: const EdgeInsets.all(0),
                height: SizeConfig.blockVertical * 8,
                width: SizeConfig.blockHorizontal * 90,
                child: TextField(
                  enabled: !_isSwitched,
                  controller: deviceId,
                  onChanged: (value) {
                    _saveData();
                  },
                  decoration: InputDecoration(
                    hintText: '000000',
                    hintStyle: TextStyle(color: Colors.grey.shade300),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                  ),
                ),
              ),
              const Text(
                'Server URL',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              Container(
                margin: const EdgeInsets.all(0),
                height: SizeConfig.blockVertical * 8,
                width: SizeConfig.blockHorizontal * 90,
                child: TextField(
                  enabled: !_isSwitched,
                  controller: serverURL,
                  onChanged: (value) {
                    _saveData();
                  },
                  decoration: InputDecoration(
                    hintText: 'http://test.id:3030',
                    hintStyle: TextStyle(color: Colors.grey.shade300),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                  ),
                ),
              ),
              const Text(
                'Fraquency',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              Container(
                margin: const EdgeInsets.all(0),
                height: SizeConfig.blockVertical * 8,
                width: SizeConfig.blockHorizontal * 90,
                child: TextField(
                  enabled: !_isSwitched,
                  controller: frequency,
                  onChanged: (value) {
                    _saveData();
                  },
                  decoration: InputDecoration(
                    hintText: '000',
                    hintStyle: TextStyle(color: Colors.grey.shade300),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                  ),
                ),
              ),
              const Text(
                'Distance',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              Container(
                margin: const EdgeInsets.all(0),
                height: SizeConfig.blockVertical * 8,
                width: SizeConfig.blockHorizontal * 90,
                child: TextField(
                  enabled: !_isSwitched,
                  controller: distance,
                  onChanged: (value) {
                    _saveData();
                  },
                  decoration: InputDecoration(
                    hintText: '00000',
                    suffixText: 'M',
                    hintStyle: TextStyle(color: Colors.grey.shade300),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                  ),
                ),
              ),
              const Text(
                'Angle Device',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              Container(
                margin: const EdgeInsets.all(0),
                height: SizeConfig.blockVertical * 8,
                width: SizeConfig.blockHorizontal * 90,
                child: TextField(
                  enabled: !_isSwitched,
                  controller: angle,
                  onChanged: (value) {
                    _saveData();
                  },
                  decoration: InputDecoration(
                    hintText: '000',
                    hintStyle: TextStyle(color: Colors.grey.shade300),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildStatusHistory() {
      List<String> reversedHistory = List.from(statusHistory.reversed);
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: reversedHistory.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Card(
                    color: Colors.white,
                    elevation: 0,
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.grey, width: 1),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      title: Text(
                        reversedHistory[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: Icon(
                        reversedHistory[index].contains('Location Updated')
                            ? Icons.check_circle
                            : Icons.error,
                        color:
                            reversedHistory[index].contains('Location Updated')
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: clearHistory,
              child: const Text('Clear History'),
            ),
          ),
        ],
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/trackapp.png',
                      height: 35,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          _isSwitched
                              ? 'assets/active.png'
                              : 'assets/activeNone.png',
                          height: 30,
                        ),
                        Switch(
                          value: _isSwitched,
                          onChanged: (value) async {
                            setState(() {
                              _isSwitched = value;
                              _saveSwitchState(value);
                              if (_isSwitched) {
                                _getCurrentTimestamp();
                                _getCurrentLocation();
                                _initGyroscope();
                                _startSendingData();
                              } else {
                                _stopSendingData();
                              }
                            });
                          },
                          activeColor: const Color(0xffDC3545),
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.grey.shade300,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            header(),
            TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xffDC3545),
              tabs: [
                Tab(
                  child: Text(
                    'Setting',
                    style: TextStyle(
                      color: _tabController.index == 0
                          ? const Color(0xffDC3545)
                          : Colors.black,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Status',
                    style: TextStyle(
                      color: _tabController.index == 1
                          ? const Color(0xffDC3545)
                          : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _isSwitched
                      ? AbsorbPointer(
                          absorbing: true,
                          child: Opacity(
                            opacity: 0.5,
                            child: inputContent(),
                          ),
                        )
                      : inputContent(),
                  Center(
                      child: _isSendingData
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: buildStatusHistory(),
                                ),
                              ],
                            )
                          : Container(
                              margin: const EdgeInsets.all(0),
                              child: const Center(
                                  child: Text('Status not available')))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
