import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:min_tube/screens/home_screen.dart';
import 'package:min_tube/screens/video_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: VideoScreen(),
    );
  }
}
