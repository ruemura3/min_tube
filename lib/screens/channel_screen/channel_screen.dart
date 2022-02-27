import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/screens/channel_screen/home_tab.dart';
import 'package:min_tube/screens/channel_screen/playlist_tab.dart';
import 'package:min_tube/screens/channel_screen/upload_video_tab.dart';
import 'package:min_tube/widgets/search_bar.dart';

/// channel screen
class ChannelScreen extends StatelessWidget {
  /// channel id
  final String? channelId;
  /// channel instance
  final Channel? channel;
  /// channel title
  final String channelTitle;
  /// channel screen tabs
  final _tabs = <Tab> [
    Tab(text: 'ホーム'),
    Tab(text:'動画'),
    Tab(text:'プレイリスト'),
  ];

  /// constructor
  ChannelScreen({this.channelId, this.channel, required this.channelTitle});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: SearchBar(
          channelTitle,
          TabBar(tabs: _tabs,)
        ),
        body: TabBarView(
          children: [
            HomeTab(
              channelId: channelId,
              channel: channel
            ),
            UploadVideoTab(
              channelId: channelId,
              channel: channel
            ),
            PlaylistTab(),
          ],
        ),
      ),
    );
  }
}
