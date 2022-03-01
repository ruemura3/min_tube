import 'package:flutter/material.dart';
import 'package:min_tube/screens/home_screen.dart';

void main() {
  runApp(MinTube());
}

class MinTube extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[50],
          foregroundColor: Colors.black,
        )
      ),
      darkTheme: ThemeData.dark().copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850],
          foregroundColor: Colors.white,
        )
      ),
      themeMode: ThemeMode.system,
      home: HomeScreen(),
    );
  }
}
