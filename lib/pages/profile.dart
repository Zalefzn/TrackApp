import 'dart:io';

import 'package:flutter/material.dart';

//package
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

//responsive
import '../config/config.dart';

class ProfileInfo extends StatefulWidget {
  const ProfileInfo({super.key});

  @override
  State<ProfileInfo> createState() => _Profile();
}

class _Profile extends State<ProfileInfo> {
  @override
  void initState() {
    _loadData();
    super.initState();
  }

  File? _image;
  String? username;
  String? deviceId;
  String? serverURL;
  String? frequency;
  String? angle;
  String? distance;

  Future<void> _getImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userImage', pickedFile.path);
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('userImage');
    username = prefs.getString('current_username');
    setState(() {
      if (imagePath != null && File(imagePath).existsSync()) {
        _image = File(imagePath);
      } else {
        _image = null;
      }
    });
  }

  Future<void> _logout() async {
    await Navigator.pushNamedAndRemoveUntil(
        context, '/login', (route) => false);
  }

  void _backToHome() {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext cotext) {
    Widget header() {
      return Container(
          margin: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  _backToHome();
                },
                child: Container(
                  height: SizeConfig.blockVertical * 7,
                  width: SizeConfig.blockHorizontal * 7,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/chevron.png'),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              const Text('Account Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  )),
              const Spacer(),
            ],
          ));
    }

    Widget profilePict() {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              _getImageFromCamera();
            },
            child: Container(
              height: SizeConfig.blockVertical * 12,
              width: SizeConfig.blockHorizontal * 25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                image: _image != null && _image!.path.isNotEmpty
                    ? DecorationImage(
                        image: FileImage(_image!),
                        fit: BoxFit.cover,
                      )
                    : const DecorationImage(
                        image: AssetImage('assets/profile.png'),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
          SizedBox(height: SizeConfig.blockVertical * 2),
          Text(username ?? 'username not found',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const Text('Avanza',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
        ],
      ));
    }

    Widget cardInfo() {
      return Container();
    }

    Widget buttonLogout() {
      return Center(
        child: Container(
            height: SizeConfig.blockVertical * 6,
            width: SizeConfig.blockHorizontal * 90,
            decoration: BoxDecoration(
                color: const Color(0xffDC3545),
                borderRadius: BorderRadius.circular(10)),
            child: TextButton(
                onPressed: () async {
                  await _logout();
                },
                child: const Text('Keluar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    )))),
      );
    }

    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              header(),
              SizedBox(height: SizeConfig.blockVertical * 2),
              profilePict(),
              SizedBox(height: SizeConfig.blockVertical * 45),
              buttonLogout(),
            ],
          )),
    );
  }
}
