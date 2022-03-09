import 'package:flutter/material.dart';
import 'package:min_tube/screens/search_result_screen.dart';

/// floating search button
class FloatingSearchButton extends StatefulWidget {
  @override
  _FloatingSearchButtonState createState() => _FloatingSearchButtonState();
}

/// floating search button state
class _FloatingSearchButtonState extends State<FloatingSearchButton> {
  /// search query
  String _query = '';
  /// search query text editing controller
  final _controller = TextEditingController();

  /// pop search dialog
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

  /// transit to search result screen with search query
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