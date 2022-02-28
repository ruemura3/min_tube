import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/widgets/profile_card.dart';

/// channel home tab
class HomeTab extends StatefulWidget {
  /// channel id
  final String? channelId;
  /// channel instance
  final Channel? channel;

  /// constructor
  HomeTab({this.channelId, this.channel});

  @override
  _HomeTabState createState() => _HomeTabState();
}

/// channel home tab state class
class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    if (widget.channel != null) {
      return ProfileCardForChannelScreen(channel: widget.channel!,);
    } else {
      return Center(child: CircularProgressIndicator(),);
    }
  }
}