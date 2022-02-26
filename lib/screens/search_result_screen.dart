import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/widgets/search_bar.dart';

/// search result screen
class SearchResultScreen extends StatefulWidget {
  /// constructor
  SearchResultScreen({required this.query});

  /// search query
  final String query;

  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

/// search result screen state class
class _SearchResultScreenState extends State<SearchResultScreen> {
  /// api service
  ApiService _api = ApiService.instance;
  /// search list response
  SearchListResponse? _response;
  /// search result list
  List<SearchResult> _items = [];

  @override
  void initState() {
    super.initState();
    Future(() async {
      final response = await _api.searchWithQuery(widget.query);
      setState(() {
        _response = response;
        _items = response.items!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchBar('検索結果'),
      body: _searchResultScreenBody(),
    );
  }

  Widget _searchResultScreenBody() {
    if (_response != null) {
      return Column(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollDetails) {
              if (scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent) {
                Future(() async {
                  final response = await _api.searchWithQuery(widget.query);
                  setState(() {
                    _response = response;
                    _items.addAll(response.items!);
                  });
                });
              }
              return false;
            },
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (BuildContext context, int index) {
                return Text(_items[index].snippet!.title!);
              },
            ),
          ),
        ],
      );
    } else {
      return Center(child: CircularProgressIndicator(),);
    }
  }
}