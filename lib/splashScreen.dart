// ignore_for_file: file_names

import 'package:flutter/material.dart';

//responsive
import 'config/config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _Splash();
}

class _Splash extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(
        const Duration(seconds: 3),
        () => {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/banner', (route) => false)
            });

    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
              height: SizeConfig.blockVertical * 100,
              width: SizeConfig.blockHorizontal * 100,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/bg_splash.png'))),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                      height: SizeConfig.blockVertical * 30,
                      width: SizeConfig.blockHorizontal * 30,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/logo.png'))))
                ],
              ))),
    );
  }
}
