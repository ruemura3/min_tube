import 'package:flutter/material.dart';

/// カラーユーティリティクラス
class ColorUtil {
  /// テキストカラー
  static textColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : Colors.black;
  }

  /// 逆のテキストカラー
  static reversedTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
      ? Colors.black
      : Colors.white;
  }
}