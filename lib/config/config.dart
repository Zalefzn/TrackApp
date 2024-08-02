import 'package:flutter/material.dart';

class SizeConfig {
  static MediaQueryData _mediaQuery = _mediaQuery;
  static double widthScreen = widthScreen;
  static double heightScreen = heightScreen;
  static double blockHorizontal = blockHorizontal;
  static double blockVertical = blockVertical;

  void init(BuildContext context) {
    _mediaQuery = MediaQuery.of(context);
    heightScreen = _mediaQuery.size.height;
    widthScreen = _mediaQuery.size.width;
    blockHorizontal = widthScreen / 100;
    blockVertical = heightScreen / 100;
  }
}
