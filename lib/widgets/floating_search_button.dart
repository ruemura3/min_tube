import 'package:flutter/material.dart';
import 'package:min_tube/screens/search_result_screen.dart';

/// 右下の検索ボタン
class FloatingSearchButton extends StatelessWidget {
  /// 検索ダイアログを表示する
  _showSearchDialog(BuildContext context) {
    /// 検索クエリ
    String query = '';
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
              _search(context, query);
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
                _search(context, query);
              },
            ),
          ],
        );
      }
    );
  }

  /// 検索を行う
  void _search(BuildContext context, String query) {
    if (query != '') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchResultScreen(query: query,),
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