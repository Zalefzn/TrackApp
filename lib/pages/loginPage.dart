// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';

//responsive
import 'package:trackapp/config/config.dart';

//package
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _Login();
}

class _Login extends State<LoginPage> {
  //controller input
  final TextEditingController _pin = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Future<void> _login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? usersJson = prefs.getString('users');
    List<Map<String, dynamic>> users = usersJson != null
        ? List<Map<String, dynamic>>.from(json.decode(usersJson))
        : [];
    String pin = _pin.text;
    String password = _password.text;

    if (pin.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All fields are required')));
      return;
    }

    try {
      Map<String, dynamic> user = users.firstWhere(
        (user) => user['pin'] == pin && user['password'] == password,
      );

      await prefs.setString('current_username', user['username']);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Login successful')));
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid credentials')));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget header() {
      return Center(
        child: Column(
          children: [
            Container(
              height: SizeConfig.blockVertical * 12,
              width: SizeConfig.blockHorizontal * 60,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/trackgps.png'))),
            ),
            const Text(
              'Silakan login menggunakan akun\n yang sudah terdaftar.',
              style: TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      );
    }

    Widget input() {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pin',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _pin,
                keyboardType: TextInputType.number,
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
              const SizedBox(height: 10),
              const Text(
                'Password',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _password,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  hintText: '********',
                  hintStyle: TextStyle(color: Colors.grey.shade300),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                ),
                obscureText: true,
              ),
              SizedBox(height: SizeConfig.blockHorizontal * 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Handle checkbox onTap logic here
                    },
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(
                          width: 2.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Ingat Saya'),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget button() {
      return Center(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  height: SizeConfig.blockVertical * 6,
                  width: SizeConfig.blockHorizontal * 90,
                  decoration: BoxDecoration(
                      color: const Color(0xffDC3545),
                      borderRadius: BorderRadius.circular(10)),
                  child: TextButton(
                      onPressed: () async {
                        await _login();
                      },
                      child: const Text('Masuk',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          )))),
              SizedBox(height: SizeConfig.blockVertical * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum punya akun ?'),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/register', (route) => false);
                    },
                    child: const Text('Daftar',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ],
          ),
        ),
      );
    }

    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: SizeConfig.blockVertical * 16),
                  header(),
                  input(),
                  button(),
                ],
              ),
            )));
  }
}
