import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/widgets/profile_card.dart';
import 'package:min_tube/widgets/search_bar.dart';
import 'package:min_tube/widgets/video_card.dart';

/// search result screen
class SearchResultScreen extends StatefulWidget {
  /// search query
  final String query;

  /// constructor
  SearchResultScreen({required this.query});

  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

/// search result screen state
class _SearchResultScreenState extends State<SearchResultScreen> {
  /// api service
  ApiService _api = ApiService.instance;
  /// is loading
  bool _isLoading = false;
  /// search response
  SearchListResponse? _response;
  /// search result list
  List<SearchResult> _items = [];

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Future(() async {
      final response = await _api.getSearchResponse(query: widget.query);
      setState(() {
        _response = response;
        _items = response.items!;
      });
      _isLoading = false;
    });
  }

  /// get additional search result
  bool _getAdditionalSearchResult(ScrollNotification scrollDetails) {
    if (!_isLoading &&
      scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent &&
      _items.length < _response!.pageInfo!.totalResults!) {
      _isLoading = true;
      Future(() async {
        final response = await _api.getSearchResponse(
          query: widget.query,
          pageToken: _response!.nextPageToken!
        );
        setState(() {
          _response = response;
          _items.addAll(response.items!);
        });
        _isLoading = false;
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchBar(title: widget.query,),
      body: _searchResultScreenBody(),
    );
  }

  /// search result screen body
  Widget _searchResultScreenBody() {
    if (_response != null) {
      return NotificationListener<ScrollNotification>(
        onNotification: _getAdditionalSearchResult,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _items.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == _items.length) {
              if (_items.length < _response!.pageInfo!.totalResults!) {
                return Center(child: CircularProgressIndicator(),);
              }
              return Container();
            }
            if (_items[index].id!.kind! == 'youtube#video') {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: VideoCardForSearchResult(searchResult: _items[index],),
              );
            }
            if (_items[index].id!.kind! == 'youtube#channel') {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ProfileCardForSearchResult(searchResult: _items[index],),
              );
            }
            return Container();
          },
        ),
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }
}