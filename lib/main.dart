import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/home_screen.dart';
import 'package:min_tube/screens/login_screen.dart';

void main() {
  runApp(MinTube());
}

/// mintube
class MinTube extends StatefulWidget {
  @override
  _MinTubeState createState() => _MinTubeState();
}

/// mintube state
class _MinTubeState extends State<MinTube> {
  /// api service
  ApiService _api = ApiService.instance;
  /// current user
  GoogleSignInAccount? _currentUser;
  /// is login finished
  bool _isLaunched = false;

  @override
  void initState() {
    super.initState();
    Future(() async {
      final user = await _api.user;
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLaunched = true;
        });
      }
    });
  }

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
      home: _home(),
    );
  }

  /// root screen
  Widget _home() {
    if (_isLaunched) {
      if (_currentUser != null) {
        return HomeScreen();
      }
      return LoginScreen();
    }
    return Center(child: CircularProgressIndicator(),);
  }
}
