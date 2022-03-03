import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/home_screen/home_screen.dart';
import 'package:min_tube/widgets/search_bar.dart';

/// login screen
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

/// home screen state
class _LoginScreenState extends State<LoginScreen> {
  /// api service
  ApiService _api = ApiService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchBar(
        title: null,
        shouldShowTitle: false,
        shouldShowBack: false,
      ),
      body: _loginScreenBody(),
    );
  }

  /// login body
  Widget _loginScreenBody() {
    /// sign in button height
    final double buttonHeight = 56;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 32, top: 64, right: 32, bottom: 64),
            child: Image.asset(
              Theme.of(context).brightness == Brightness.dark
              ? 'assets/images/logo_dark.png'
              : 'assets/images/logo_light.png',
            ),
          ),
          ElevatedButton.icon(
            icon: FaIcon(
              FontAwesomeIcons.google,
            ),
            label: Text(
              'Sign in with Google',
              style: TextStyle(fontSize: 18),
            ),
            onPressed: () async {
              await _api.login();
              Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScreen(),
              )
            );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonHeight/2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}