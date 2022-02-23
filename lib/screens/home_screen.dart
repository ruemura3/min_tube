import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/widgets/search_bar.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    ApiService.googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {

      }
    });
    ApiService.googleSignIn.signInSilently();
  }

  Future _signIn() async {
    await ApiService.instance.setUser();
    setState(() {
      _currentUser = ApiService.instance.getUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchBar(),
      body: Container(),
    );
  }
}
