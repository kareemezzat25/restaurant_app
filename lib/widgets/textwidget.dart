import 'package:flutter/material.dart';

class TextWidget {
  static TextStyle boldTextFieldStyle() {
    return const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins');
  }

  static TextStyle HeadLineTextFieldStyle() {
    return const TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins');
  }

  static TextStyle LightTextFieldStyle() {
    return const TextStyle(
        color: Colors.black38,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins');
  }

  static TextStyle semiBoldTextFieldStyle() {
    return const TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins');
  }
}
