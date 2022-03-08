import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/login_screen.dart';
import 'package:min_tube/screens/playlist_screen.dart';
import 'package:min_tube/widgets/profile_card.dart';
import 'package:min_tube/widgets/search_bar.dart';

class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  /// api service
  ApiService _api = ApiService.instance;
  /// current user
  GoogleSignInAccount? _currentUser;
  /// current user channel
  Channel? _channel;

  @override
  void initState() {
    super.initState();
    Future(() async {
      final user = await _api.user;
      final response = await _api.getChannelResponse(mine: true);
      if (mounted) {
        setState(() {
          _currentUser = user;
          _channel = response.items![0];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchBar(title: 'マイページ',),
      body: _myScreenBody(),
    );
  }

  /// my screen body
  Widget _myScreenBody() {
    if (_currentUser != null && _channel != null) {
      return Column(
        children: [
          MyProfileCard(channel: _channel!),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlaylistScreen(),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.thumb_up_outlined),
                  SizedBox(width: 16,),
                  Expanded(
                    child: Text(
                      '高く評価した動画',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: _showLogoutDialog,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.logout_outlined),
                  SizedBox(width: 16,),
                  Expanded(
                    child: Text(
                      'ログアウト',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }

  _showLogoutDialog() {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          content: Text("ログアウトしますか？"),
          actions: <Widget>[
            TextButton(
              child: Text("キャンセル"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("ログアウト"),
              onPressed: () async {
                await _api.logout();
                if (mounted) {
                  setState(() {
                    _currentUser = null;
                  });
                }
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(),
                  ),
                  (route) => false
                );
              },
            ),
          ],
        );
      },
    );
  }
}