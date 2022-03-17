import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/error_screen.dart';
import 'package:min_tube/screens/my_screen.dart';
import 'package:min_tube/widgets/floating_search_button.dart';
import 'package:min_tube/widgets/profile_card.dart';
import 'package:min_tube/widgets/app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      try {
        final response = await _api.getSubscriptionResponse();
        _items = response.items!;
        _response = response;
        int itemLength = _items.length;
        while (itemLength < _response!.pageInfo!.totalResults!) {
          final response = await _api.getSubscriptionResponse(
            pageToken: _response!.nextPageToken!,
          );
          _items.addAll(response.items!);
          itemLength = _items.length;
        }
        if (mounted) {
          setState(() {
            _response = _response;
            _items = _response!.items!;
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
      final preferences = await SharedPreferences.getInstance();
      List<String>? favoriteIds = preferences.getStringList('favorites');
      if (favoriteIds != null) {
        for (var f in favoriteIds) {
          final favoriteChannel = _items.firstWhere(
            (subscription) => subscription.snippet!.resourceId!.channelId! == f
          );
          _items.remove(favoriteChannel);
          _items.insert(0, favoriteChannel);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: null,
        shouldShowTitle: true,
        shouldShowBack: false,
      ),
      body: _homeScreenBody(),
      floatingActionButton: FloatingSearchButton(),
    );
  }

  /// home screen body
  Widget _homeScreenBody() {
    if (_response != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: ListView.builder(
          itemCount: _items.length + 2,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Column(
                children: [
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyScreen(),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'マイページ',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios)
                        ],
                      ),
                    ),
                  ),
                  Divider(color: Colors.grey,),
                ],
              );
            }
            if (index == _items.length + 1) {
              if (_items.length == 0) {
                return Center(
                  child: Text('登録しているチャンネルがありません'),
                );
              }
              return Container();
            }
            return ProfileCardForHomeScreen(subscription: _items[index - 1]);
          },
        ),
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }
}
