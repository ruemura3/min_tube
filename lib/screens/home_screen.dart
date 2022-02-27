import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/widgets/search_bar.dart';

/// Home screen class
class HomeScreen extends StatefulWidget {
  /// constructor
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

/// home screen state class
class _HomeScreenState extends State<HomeScreen> {
  /// api service
  ApiService _api = ApiService.instance;
  /// subscription list response
  SubscriptionListResponse? _response;
  /// search result list
  List<Subscription> _items = [];

  @override
  void initState() {
    super.initState();
    // Future(() async {
    //   final response = await _api.getSubscriptionsResource();
    //   setState(() {
    //     _response = response;
    //     _items = response.items!;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchBar('MinTube'),
      body: Container(),
    );
  }
}
