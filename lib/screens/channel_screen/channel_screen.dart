import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/channel_screen/home_tab.dart';
import 'package:min_tube/screens/channel_screen/playlist_tab.dart';
import 'package:min_tube/screens/channel_screen/upload_video_tab.dart';
import 'package:min_tube/screens/error_screen.dart';
import 'package:min_tube/util/color_util.dart';
import 'package:min_tube/widgets/floating_search_button.dart';
import 'package:min_tube/widgets/app_bar.dart';

/// channel screen
class ChannelScreen extends StatefulWidget {
  /// channel id
  final String? channelId;
  /// channel instance
  final Channel? channel;
  /// animate to
  final int tabPage;
  /// is mine
  final bool isMine;

  /// constructor
  ChannelScreen({
    this.channelId,
    this.channel,
    this.tabPage = 0,
    this.isMine = false
  });

  @override
  _ChannelScreenState createState() => _ChannelScreenState();
}

/// channel home tab state
class _ChannelScreenState extends State<ChannelScreen> with SingleTickerProviderStateMixin {
  /// api service
  ApiService _api = ApiService.instance;
  /// channel instance
  Channel? _channel;
  /// tab controller
  late TabController _tabController;

  /// channel screen tabs
  final _tabs = <Tab> [
    Tab(text: 'ホーム'),
    Tab(text:'動画'),
    Tab(text:'プレイリスト'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    if (widget.channel != null) {
      setState(() {
        _channel = widget.channel;
      });
    } else {
      Future(() async {
        final channels = await _api.getChannelResponse(ids: [widget.channelId!]);
        if (mounted) {
          setState(() {
            _channel = channels.items![0];
          });
        }
      });
    }
    _tabController.animateTo(widget.tabPage);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: OriginalAppBar(
          title: _channel != null
          ? _channel!.snippet!.title
          : '',
          tabBar: TabBar(
            labelColor: ColorUtil.textColor(context),
            unselectedLabelColor: Colors.grey,
            controller: _tabController,
            tabs: _tabs,
          ),
        ),
        body: _channelScreenBody(),
        floatingActionButton: FloatingSearchButton(),
      ),
    );
  }

  /// channel screen body
  Widget _channelScreenBody() {
    if (_channel != null) {
      return TabBarView(
        controller: _tabController,
        children: [
          HomeTab(channel: _channel!, isMine: widget.isMine),
          UploadVideoTab(channel: _channel!),
          PlaylistTab(channel: _channel!, isMine: widget.isMine),
        ],
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }
}
