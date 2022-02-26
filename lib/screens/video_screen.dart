import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/util/util.dart';
import 'package:min_tube/widgets/profile_card.dart';
import 'package:min_tube/widgets/search_bar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

/// video screen
class VideoScreen extends StatefulWidget {
  /// video id
  final String videoId;

  /// constructor
  VideoScreen({required this.videoId});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

/// video screen state
class _VideoScreenState extends State<VideoScreen> {
  /// api service
  ApiService _api = ApiService.instance;
  /// video instance
  Video? _video;
  /// channel instance
  Channel? _channel;
  /// youtube player controller
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // init youtube player controller
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        hideThumbnail: true,
        captionLanguage: 'ja',
        disableDragSeek: false,
        isLive: false,
        startAt: 0,
      ),
    );
    // get video and channel info
    Future(() async {
      final video = await _api.getVideoDetail(widget.videoId);
      final channel = await _api.getChannelDetail(video.snippet!.channelId!);
      setState(() {
        _video = video;
        _channel = channel;
      });
    });
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        onReady: () {

        },
        onEnded: (data) {

        },
      ),
      builder: (context, player) => Scaffold(
        appBar: SearchBar(),
        body: Column(
          children: [
            player,
            _videoScreenBody(),
          ]
        ),
      ),
    );
  }

  /// video screen body
  Widget _videoScreenBody() {
    if (_video != null && _channel != null) {
      return ListView(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _video!.snippet!.title!,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8,),
                    Text(
                      _viewsAndTimeago(_video!.statistics!.viewCount!, _video!.snippet!.publishedAt!),
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w300,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8,),
                    ProfileCardForVideoScreen(channel: _channel!),
                    SizedBox(height: 8,),
                    Text(
                      _video!.snippet!.description!,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]
      );
    } else {
      return Center(child: CircularProgressIndicator(),);
    }
  }

  String _viewsAndTimeago(String viewCount, DateTime publishAt) {
    return '${Util.formatViewCount(viewCount)}・${timeago.format(publishAt)}';
  }
}