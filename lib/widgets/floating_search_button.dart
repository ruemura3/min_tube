import 'package:flutter/material.dart';
import 'package:min_tube/screens/search_result_screen.dart';

/// 右下の検索ボタン
class FloatingSearchButton extends StatefulWidget {
  @override
  _FloatingSearchButtonState createState() => _FloatingSearchButtonState();
}

/// 右下の検索ボタンステート
class _FloatingSearchButtonState extends State<FloatingSearchButton> {
  /// 検索クエリ
  String _query = '';
  /// テキスト編集コントローラ
  final _controller = TextEditingController();

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
                _search();
              },
            ),
          ],
        );
      }
    );
  }

  /// 検索を行う
  void _search() {
    if (_query != '') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchResultScreen(query: _query,),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _showSearchDialog(context);
      },
      child: Icon(Icons.search),
    );
  }
}