import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/widgets/search_bar.dart';

/// home screen class
class HomeScreen extends StatefulWidget {
  /// constructor
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

/// home screen state class
class _HomeScreenState extends State<HomeScreen> {
  /// api service
  ApiService _api = ApiService.instance;
  /// current user
  GoogleSignInAccount? _currentUser;
  /// is login finished
  bool _isLoginFinished = false;
  /// subscription list response
  SubscriptionListResponse? _response;
  /// search result list
  List<Subscription> _items = [];
  /// should show app bar title
  bool _shouldShowTitle = false;

  @override
  void initState() {
    super.initState();
    Future(() async {
      final user = await _api.user;
      setState(() {
        _currentUser = user;
        _isLoginFinished = true;
      });
      if (_currentUser != null) {
        final response = await _api.getSubscriptionsResource();
        setState(() {
          _response = response;
          _items = response.items!;
          _shouldShowTitle = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchBar('MinTube', null, _shouldShowTitle, _currentUser),
      body: _homeScreenBody(),
    );
  }

  /// home screen body
  Widget _homeScreenBody() {
    if (!_isLoginFinished) {
      return Center(child: CircularProgressIndicator(),);
    } else {
      if (_currentUser != null) {
        return _homeBody();
      } else {
        return _loginBody();
      }
    }
  }

  /// login body
  Widget _loginBody() {
    /// sign in button height
    final double buttonHeight = 50;
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
              color: Colors.red,
            ),
            label: Text('Sign in with Google',),
            onPressed: () async {
              final user = await _api.logIn();
              setState(() {
                _currentUser = user;
              });
              final response = await _api.getSubscriptionsResource();
              setState(() {
                _response = response;
                _items = response.items!;
                _shouldShowTitle = true;
              });
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
              onPrimary: Colors.black,
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

  /// home body
  Widget _homeBody() {
    if (_response != null) {
      return ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        itemCount: _items.length,
        itemBuilder: (BuildContext context, int index) {
          return Text(_items[index].snippet!.title!);
        },
      );
    } else {
      return Center(child: CircularProgressIndicator(),);
    }
  }
}
