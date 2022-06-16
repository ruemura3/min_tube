import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/channel_screen/channel_screen.dart';
import 'package:min_tube/screens/login_screen.dart';
import 'package:min_tube/screens/playlist_screen.dart';
import 'package:min_tube/widgets/original_app_bar.dart';

/// マイページ画面
class MyPageScreen extends StatefulWidget {
  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

/// マイページ画面ステート
class _MyPageScreenState extends State<MyPageScreen> {
  /// APIインスタンス
  ApiService _api = ApiService.instance;
  /// ログイン中ユーザ
  GoogleSignInAccount? _currentUser;
  /// ログイン中ユーザのチャンネル
  Channel? _channel;

  @override
  void initState() {
    Future(() async {
      final user = await _api.user;
      final response = await _api.getChannelList(mine: true);
      if (mounted) {
        setState(() {
          _currentUser = user;
          _channel = response.items![0];
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OriginalAppBar(
        title: 'マイページ',
        shouldShowProfileButton: false,
      ),
      body: _myScreenBody(),
    );
  }

  /// マイページ画面ボディ
  Widget _myScreenBody() {
    if (_currentUser != null && _channel != null) { // ユーザとチャンネルがnullでない場合
      return Column(
        children: [
          _profileCard(),
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChannelScreen(
                  channel: _channel!,
                  tabPage: 2,
                  isMine: true,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.playlist_play),
                  SizedBox(width: 16,),
                  Expanded(
                    child: Text(
                      'プレイリスト',
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

  Widget _profileCard() {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChannelScreen(
            channel: _channel,
            isMine: true,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _channel!.snippet!.thumbnails!.medium != null
              ? CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(_channel!.snippet!.thumbnails!.medium!.url!)
              )
              : CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blueGrey,
                child: Text(_channel!.snippet!.title!.substring(0, 1)),
              ),
            SizedBox(width: 16,),
            Expanded(
              child: Text(
                _channel!.snippet!.title!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showLogoutDialog() {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          content: Text(
            "ログアウトしますか？",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "キャンセル",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(
                "ログアウト",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                await _api.logout();
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