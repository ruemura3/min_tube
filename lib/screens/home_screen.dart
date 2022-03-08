import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/error_screen.dart';
import 'package:min_tube/widgets/floating_search_button.dart';
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
  /// current user
  GoogleSignInAccount? _currentUser;
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
      try {
        final user = await _api.user;
        final response = await _api.getSubscriptionResponse();
        if (mounted) {
          setState(() {
            _currentUser = user;
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

  /// get additional subscription
  bool _getAdditionalSubscription(ScrollNotification scrollDetails) {
    if (!_isLoading &&
      scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent &&
      _items.length < _response!.pageInfo!.totalResults!) {
      _isLoading = true;
      Future(() async {
        try {
          final response = await _api.getSubscriptionResponse(
            pageToken: _response!.nextPageToken!,
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
      appBar: SearchBar(
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
      if (_items.length == 0) {
        return Center(
          child: Text('登録しているチャンネルがありません'),
        );
      }
      return NotificationListener<ScrollNotification>(
        onNotification: _getAdditionalSubscription,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ListView.builder(
            itemCount: _items.length + 2,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Column(
                  children: [
                    MyProfileCard(currentUser: _currentUser!),
                    Divider(color: Colors.grey,),
                  ],
                );
              }
              if (index == _items.length + 1) {
                if (_items.length < _response!.pageInfo!.totalResults!) {
                  return Center(child: CircularProgressIndicator(),);
                }
                return Container();
              }
              return ProfileCardForHomeScreen(subscription: _items[index - 1]);
            },
          ),
        ),
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }
}
