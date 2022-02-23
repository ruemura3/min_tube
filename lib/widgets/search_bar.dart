import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:min_tube/api/api_service.dart';

/// search bar
class SearchBar extends StatefulWidget with PreferredSizeWidget {
  /// app bar text
  final String appBarText = 'MinTube';

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  _SearchBarState createState() => _SearchBarState();
}

/// search bar state
class _SearchBarState extends State<SearchBar> {
  /// current user
  GoogleSignInAccount? _currentUser;
  /// search query
  String _query = '';
  /// search query text editing controller
  final _controller = TextEditingController();

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

  /// クエリを引数に検索結果画面に遷移する
  _search() {
    if (_query != '') { // クエリが未入力でない場合
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => SearchResultScreen(query: _query,),
      //   )
      // );
    }
  }

  /// 検索ダイアログを表示する
  _showSearchDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(),
              ),
              hintText: 'YouTubeを検索',
              suffixIcon: IconButton(
                onPressed: () {
                  _controller.clear();
                  _query = '';
                },
                icon: Icon(
                  Icons.clear,
                ),
              ),
            ),
            onChanged: (text) {
              _query = text;
            },
            onEditingComplete: () {
              _search();
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'キャンセル',
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                '検索',
              ),
              onPressed: () {
                _search();
              },
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
          widget.appBarText,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: _profileIcon(),
        )
      ],
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
        child: _currentUser!.photoUrl == null
        ?  CircleAvatar(
            backgroundColor: Colors.blueGrey,
            child: Text(_currentUser!.displayName!.substring(0, 1)),
          )
        : CircleAvatar(backgroundImage: NetworkImage(_currentUser!.photoUrl!))
      );
    }
  }
}