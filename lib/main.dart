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
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: HomeScreen(),
    );
  }
}
