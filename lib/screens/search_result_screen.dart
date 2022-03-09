import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/error_screen.dart';
import 'package:min_tube/widgets/floating_search_button.dart';
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
      try {
        final response = await _api.getSearchResponse(query: widget.query);
        if (mounted) {
          setState(() {
            _response = response;
            _items = response.items!;
            _isLoading = false;
          });
        }
      } catch (e) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ErrorScreen(),
          )
        );
      }
    });
  }

  /// get additional search result
  bool _getAdditionalSearchResult(ScrollNotification scrollDetails) {
    if (!_isLoading &&
      scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent &&
      _items.length < _response!.pageInfo!.totalResults!) {
      _isLoading = true;
      Future(() async {
        try {
          final response = await _api.getSearchResponse(
            query: widget.query,
            pageToken: _response!.nextPageToken!
          );
          if (mounted) {
            setState(() {
              _response = response;
              _items.addAll(response.items!);
              _isLoading = false;
            });
          }
        } catch (e) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ErrorScreen(),
            )
          );
        }
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchBar(title: widget.query,),
      body: _searchResultScreenBody(),
      floatingActionButton: FloatingSearchButton(),
    );
  }

  /// search result screen body
  Widget _searchResultScreenBody() {
    if (_response != null) {
      return NotificationListener<ScrollNotification>(
        onNotification: _getAdditionalSearchResult,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: _items.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == _items.length) {
              if (_items.length < _response!.pageInfo!.totalResults!) {
                return Center(child: CircularProgressIndicator(),);
              }
              return Container();
            }
            if (_items[index].id!.kind! == 'youtube#video') {
              return VideoCardForSearchResult(searchResult: _items[index],);
            }
            if (_items[index].id!.kind! == 'youtube#channel') {
              return ProfileCardForSearchResult(searchResult: _items[index],);
            }
            return Container();
          },
        ),
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }
}