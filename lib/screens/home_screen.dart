import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:min_tube/api/api_service.dart';

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
      appBar: AppBar(
        title: Text(''),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: _profileIcon(),
          )
        ],
      ),
      body: Container(),
    );
  }

  Widget _profileIcon() {
    if (_currentUser == null) {
      return IconButton(
        icon: Icon(Icons.account_circle),
        onPressed: _signIn,
      );
    } else {
      return GestureDetector(
        onTap: () {

        },
        child: _currentUser!.photoUrl == null ?
          CircleAvatar(
            backgroundColor: Colors.blueGrey,
            child: Text(_currentUser!.displayName!.substring(0, 1)),
          ) :
          CircleAvatar(backgroundImage: NetworkImage(_currentUser!.photoUrl!))
      );
    }
  }
}
