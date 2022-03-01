import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/channel_screen/home_tab.dart';
import 'package:min_tube/screens/channel_screen/playlist_tab.dart';
import 'package:min_tube/screens/channel_screen/upload_video_tab.dart';
import 'package:min_tube/widgets/search_bar.dart';

/// channel screen
class ChannelScreen extends StatefulWidget {
  /// channel id
  final String? channelId;
  /// channel instance
  final Channel? channel;
  /// channel title
  final String channelTitle;

  /// constructor
  ChannelScreen({this.channelId, this.channel, required this.channelTitle});

  @override
  _ChannelScreenState createState() => _ChannelScreenState();
}

/// channel home tab state
class _ChannelScreenState extends State<ChannelScreen> {
  /// api service
  ApiService _api = ApiService.instance;
  /// channel instance
  Channel? _channel;

  /// channel screen tabs
  final _tabs = <Tab> [
    Tab(text: 'ホーム'),
    Tab(text:'動画'),
    Tab(text:'プレイリスト'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.channel != null) {
      setState(() {
        _channel = widget.channel;
      });
    } else {
      Future(() async {
        final channels = await _api.getChannelResponse(ids: [widget.channelId!]);
        setState(() {
          _channel = channels.items![0];
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: SearchBar(
          title: widget.channelTitle,
          tabBar: TabBar(tabs: _tabs,),
        ),
        body: _channelScreenBody(),
      ),
    );
  }

  Widget _channelScreenBody() {
    if (_channel != null) {
      return TabBarView(
        children: [
          HomeTab(channel: _channel!),
          UploadVideoTab(channel: _channel!),
          PlaylistTab(channel: _channel!),
        ],
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }
}
