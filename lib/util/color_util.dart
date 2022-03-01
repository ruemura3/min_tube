import 'package:flutter/material.dart';

class ColorUtil {
  static Color backGround(Brightness brightness) {
    return brightness  == Brightness.dark
    ? Colors.black
    : Colors.white;
  }
  static Color text(Brightness brightness) {
    return brightness  == Brightness.dark
    ? Colors.white
    : Colors.black;
  }
}