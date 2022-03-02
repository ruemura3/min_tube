import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/home_screen/subscription_items.dart';
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
  /// subscription response
  SubscriptionListResponse? _response;
  ///  subscription list
  List<Subscription> _items = [];

  @override
  void initState() {
    super.initState();
    Future(() async {
      final response = await _api.getSubscriptionResponse();
      setState(() {
        _response = response;
        _items = response.items!;
      });
    });
  }

  bool _getAdditionalSubscription(ScrollNotification scrollDetails) {
    if (scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent &&
      _items.length < _response!.pageInfo!.totalResults!) {
      Future(() async {
        final response = await _api.getSubscriptionResponse(
          pageToken: _response!.nextPageToken!,
        );
        setState(() {
          _response = response;
          _items.addAll(response.items!);
        });
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
            return SubscriptionItems(subscription: _items[index],);
          },
        ),
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }
}
