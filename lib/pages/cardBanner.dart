// ignore_for_file: file_names

import 'package:flutter/material.dart';

//responsive
import 'package:trackapp/config/config.dart';

//package
import 'package:lottie/lottie.dart';

class Slide extends StatelessWidget {
  final String imagePath;
  final String text;
  final String text2;

  Slide({required this.imagePath, required this.text, required this.text2});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    ;
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: EdgeInsets.only(top: SizeConfig.blockVertical * 13),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              margin: const EdgeInsets.all(0),
              height: SizeConfig.blockVertical * 20,
              width: SizeConfig.blockHorizontal * 70,
              child: Lottie.asset(imagePath)),
          const SizedBox(height: 15),
          Text(
            text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            text2,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
