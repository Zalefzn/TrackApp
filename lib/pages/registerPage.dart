// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:convert';

//responsive
import 'package:trackapp/config/config.dart';

//package
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _Register();
}

class _Register extends State<RegisterPage> {
  //controller input
  final TextEditingController _pin = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Future<void> _regster() async {
    String username = _username.text;
    String pin = _pin.text;
    String password = _password.text;

    if (username.isEmpty || pin.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All fields are required')));
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userJson = prefs.getString('users');
    List<Map<String, dynamic>> users = userJson != null
        ? List<Map<String, dynamic>>.from(json.decode(userJson))
        : [];

    users.add({
      'username': username,
      'pin': pin,
      'password': password,
    });

    await prefs.setString('users', json.encode(users));
    await prefs.setString('current_username', username);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Register Success')));

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
              'Isi formulir dibawah\n untuk membuat akun.',
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
                'Username',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _username,
                decoration: InputDecoration(
                  hintText: 'Johndoe',
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
              const SizedBox(height: 5),
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
                  width: SizeConfig.blockHorizontal * 80,
                  decoration: BoxDecoration(
                      color: const Color(0xffDC3545),
                      borderRadius: BorderRadius.circular(10)),
                  child: TextButton(
                      onPressed: () async {
                        await _regster();
                      },
                      child: const Text('Daftar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          )))),
              SizedBox(height: SizeConfig.blockVertical * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah punya akun ?'),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false);
                    },
                    child: const Text('Masuk',
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
                  SizedBox(height: SizeConfig.blockVertical * 11),
                  header(),
                  input(),
                  button(),
                ],
              ),
            )));
  }
}
