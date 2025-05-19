import 'package:flutter/material.dart';

class Config {
  static MediaQueryData? mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;

  //alto y ancho inicializacion de la pantalla
  void init(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    screenWidth = mediaQueryData!.size.width;
    screenHeight = mediaQueryData!.size.height;
  }

  static get widthSize {
    return screenWidth;
  }

  static get heightSize {
    return screenHeight;
  }

  //Define espacing height
  static const spaceSmall = SizedBox(height: 25);
  static final spaceMedium = SizedBox(height: screenHeight! * 0.05);
  static final spaceBig = SizedBox(height: screenHeight! * 0.08);

  //textform field border
  static const outlinedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const focusBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: Colors.red),
  );
  static const errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: Colors.red),
  );

  static const primaryColor = Colors.red;
  static const Color successColor = Color(0xFF4CAF50); // Green (for success)
  static const Color cancelColor = Color(0xFFB0BEC5); // Grey (for cancel)
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;

  static const base_url = 'https://kaunselingadtectaiping.com.my/';
  static const base_url2 = 'http://192.168.0.106/ADTEC-EKaunsel/';
  // static const base_url = 'https://kaunselingadtectaiping.com.my/';
}
