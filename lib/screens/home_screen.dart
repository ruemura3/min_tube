import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/widgets/profile_card.dart';
import 'package:min_tube/widgets/search_bar.dart';

/// home screen
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

/// home screen state
class _HomeScreenState extends State<HomeScreen> {
  /// api service
  ApiService _api = ApiService.instance;
  /// is loading
  bool _isLoading = false;
  /// subscription response
  SubscriptionListResponse? _response;
  ///  subscription list
  List<Subscription> _items = [];

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Future(() async {
      final response = await _api.getSubscriptionResponse();
      setState(() {
        _response = response;
        _items = response.items!;
      });
      _isLoading = false;
    });
  }

  /// get additional subscription
  bool _getAdditionalSubscription(ScrollNotification scrollDetails) {
    if (!_isLoading &&
      scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent &&
      _items.length < _response!.pageInfo!.totalResults!) {
      _isLoading = true;
      Future(() async {
        final response = await _api.getSubscriptionResponse(
          pageToken: _response!.nextPageToken!,
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
      appBar: SearchBar(
        title: null,
        shouldShowTitle: true,
        shouldShowBack: false,
      ),
      body: _homeScreenBody(),
    );
  }

  /// home screen body
  Widget _homeScreenBody() {
    if (_response != null) {
      if (_items.length == 0) {
        return Center(
          child: Text('このチャンネルには動画がありません'),
        );
      }
      return NotificationListener<ScrollNotification>(
        onNotification: _getAdditionalSubscription,
        child: ListView.builder(
          itemCount: _items.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == _items.length) {
              if (_items.length < _response!.pageInfo!.totalResults!) {
                return Center(child: CircularProgressIndicator(),);
              }
              return Container();
            }
            return ProfileCardForHomeScreen(subscription: _items[index]);
          },
        ),
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }
}
