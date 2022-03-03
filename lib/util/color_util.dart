import 'package:flutter/material.dart';

class ColorUtil {
  static textColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
    ? Colors.white
    : Colors.black;
  }
}