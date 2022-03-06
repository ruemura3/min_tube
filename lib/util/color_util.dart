import 'package:flutter/material.dart';

class ColorUtil {
  /// text color
  static textColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
    ? Colors.white
    : Colors.black;
  }
}