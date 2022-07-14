import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/home_screen.dart';
import 'package:min_tube/screens/my_page_screen.dart';
import 'package:min_tube/screens/search_result_screen.dart';

/// オリジナルアップバー
class OriginalAppBar extends StatefulWidget with PreferredSizeWidget {
  /// アップバータイトル
  final String? title;
  /// 検索バーかどうか
  final bool isSearch;
  /// プロフィールボタンを表示すべきかどうか
  final bool shouldShowProfileButton;
  /// タブバー
  final TabBar? tabBar;

  /// コンストラクタ
  OriginalAppBar({
    this.title,
    this.isSearch = false,
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
    if (widget.title != null) {
      if (widget.isSearch) {
        return InkWell(
          onTap: () {
            _showSearchDialog(context);
          },
          child: Text(
            widget.title!,
            style: TextStyle(
              fontSize: 18,
            ),
          )
        );
      }
      return Text(
        widget.title!,
        style: TextStyle(
          fontSize: 18,
        ),
      );
    }
    return InkWell(
      onTap: () => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(),
        ),
        (route) => false
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
              ? Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(_currentUser!.photoUrl!)
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  child: Text(_currentUser!.displayName!.substring(0, 1)),
                ),
              )
          ),
          SizedBox(width: 8,),
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

  /// 検索ダイアログを表示する
  _showSearchDialog(BuildContext context) {
    /// 検索クエリ
    String query = widget.title!;
    /// テキスト編集コントローラ
    final controller = TextEditingController(text: query);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(),
              ),
              hintText: 'YouTubeを検索',
              suffixIcon: IconButton(
                onPressed: () {
                  controller.clear();
                  query = '';
                },
                icon: Icon(
                  Icons.clear,
                ),
              ),
            ),
            onChanged: (text) {
              query = text;
            },
            onEditingComplete: () {
              _search(query);
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'キャンセル',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                '検索',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                _search(query);
              },
            ),
          ],
        );
      }
    );
  }

  /// 検索を行う
  void _search(String query) {
    if (query != '') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchResultScreen(query: query,),
        )
      );
    }
  }
}