import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/util/api_util.dart';
import 'package:min_tube/screens/channel_screen/channel_screen.dart';
import 'package:min_tube/screens/login_screen.dart';
import 'package:min_tube/screens/playlist_screen.dart';
import 'package:min_tube/widgets/original_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// マイページ画面
class MyPageScreen extends StatefulWidget {
  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

/// マイページ画面ステート
class _MyPageScreenState extends State<MyPageScreen> {
  /// APIインスタンス
  ApiUtil _api = ApiUtil.instance;
  /// ログイン中ユーザ
  GoogleSignInAccount? _currentUser;
  /// ログイン中ユーザのチャンネル
  Channel? _channel;
  /// 再生速度
  double _speed = 1.0;
  /// SharedPreferences
  late SharedPreferences _preferences;

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
      _preferences = await SharedPreferences.getInstance();
      final speed = _preferences.getDouble('speed');
      if (speed != null) {
        _speed = speed;
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
            onTap: () => showSettingDialog(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.speed),
                  SizedBox(width: 16,),
                  Expanded(
                    child: Text(
                      'デフォルトの再生速度',
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

  /// プロフィールカードを返す
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

  /// ログアウトダイアログを表示する
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

  /// 設定ダイアログを表示する
  showSettingDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16,),
                  Text(
                    'デフォルトの再生速度',
                    style: TextStyle(fontWeight: FontWeight.bold,),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16,),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          child: Text('2.0'),
                          value: 2.0,
                        ),
                        DropdownMenuItem(
                          child: Text('1.75'),
                          value: 1.75,
                        ),
                        DropdownMenuItem(
                          child: Text('1.5'),
                          value: 1.5,
                        ),
                        DropdownMenuItem(
                          child: Text('1.25'),
                          value: 1.25,
                        ),
                        DropdownMenuItem(
                          child: Text('標準'),
                          value: 1.00,
                        ),
                        DropdownMenuItem(
                          child: Text('0.75'),
                          value: 0.75,
                        ),
                        DropdownMenuItem(
                          child: Text('0.5'),
                          value: 0.5,
                        ),
                        DropdownMenuItem(
                          child: Text('0.25'),
                          value: 0.25,
                        ),
                      ],
                      onChanged: (double? value) {
                        setState(() {
                          _speed = value!;
                        });
                        _preferences.setDouble('speed', _speed);
                      },
                      value: _speed,
                    ),
                  ),
                ]
              ),
              actions: [
                TextButton(
                  child: Text(
                    '完了',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          }
        );
      }
    );
  }
}