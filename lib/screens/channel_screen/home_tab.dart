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
  /// api service
  ApiService _api = ApiService.instance;
  /// channel instance
  Channel? _channel;

  @override
  void initState() {
    super.initState();
    if (widget.channel == null) {
      Future(() async {
        final channel = await _api.getChannel(widget.channelId!);
        setState(() {
          _channel = channel;
        });
      });
    } else {
      setState(() {
        _channel = widget.channel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_channel != null) {
      return ProfileCardForChannelScreen(channel: _channel!,);
    } else {
      return Center(child: CircularProgressIndicator(),);
    }
  }
}