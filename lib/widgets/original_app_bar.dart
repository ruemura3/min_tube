import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/home_screen.dart';
import 'package:min_tube/screens/my_screen.dart';

/// オリジナルアップバー
class OriginalAppBar extends StatefulWidget with PreferredSizeWidget {
  /// アップバータイトル
  final String? title;
  /// タイトルを表示すべきかどうか
  final bool shouldShowTitle;
  /// プロフィールボタンを表示すべきかどうか
  final bool shouldShowProfileButton;
  /// タブバー
  final TabBar? tabBar;

  /// コンストラクタ
  OriginalAppBar({
    this.title,
    this.shouldShowTitle = true,
    this.shouldShowProfileButton = true,
    this.tabBar,
  });

  @override
  Size get preferredSize {
    if (tabBar != null) {
      return Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
    }
    return Size.fromHeight(kToolbarHeight);
  }

  @override
  _OriginalAppBarState createState() => _OriginalAppBarState();
}

/// オリジナルアップバーステート
class _OriginalAppBarState extends State<OriginalAppBar> {
  /// APIインスタンス
  ApiService _api = ApiService.instance;
  /// ログイン中ユーザ
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    Future(() async {
      final user = await _api.user;
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: _appBarTitle(),
      actions: _appBarActions(),
      bottom: widget.tabBar,
    );
  }

  /// アップバータイトル
  Widget _appBarTitle() {
    if (!widget.shouldShowTitle) {
      return Container();
    }
    if (widget.title != null) {
      return Text(
        widget.title!,
        style: TextStyle(
          fontSize: 18,
        ),
      );
    }
    return InkWell(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(),
        )
      ),
      child: Image.asset(
        Theme.of(context).brightness == Brightness.dark
          ? 'assets/images/logo_dark.png'
          : 'assets/images/logo_light.png',
          width: 120,
      ),
    );
  }

  /// プロフィールアイコン
  List<Widget> _appBarActions() {
    if (widget.shouldShowProfileButton) {
      if (_currentUser != null) {
        return [
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MyPageScreen(),
              ),
            ),
            child: _currentUser!.photoUrl != null
              ? CircleAvatar(
                backgroundImage: NetworkImage(_currentUser!.photoUrl!)
              )
              : CircleAvatar(
                backgroundColor: Colors.blueGrey,
                child: Text(_currentUser!.displayName!.substring(0, 1)),
              )
          ),
          SizedBox(width: 16,),
        ];
      }
      Future(() async {
        final user = await _api.user;
        if (mounted) {
          setState(() {
            _currentUser = user;
          });
        }
      });
    }
    return [];
  }
}