import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/widgets/profile_card.dart';

/// channel home tab
class HomeTab extends StatefulWidget {
  /// channel instance
  final Channel? channel;

  /// constructor
  HomeTab({this.channel});

  @override
  _HomeTabState createState() => _HomeTabState();
}

/// channel home tab state class
class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    if (widget.channel != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: ProfileCardForChannelScreen(channel: widget.channel!,),
        ),
      );
    } else {
      return Center(child: CircularProgressIndicator(),);
    }
  }
}