import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:min_tube/widgets/search_bar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// video screen
class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

/// video screen state
class _VideoScreenState extends State<VideoScreen> {
  /// youtube player controller
  late YoutubePlayerController _controller;

  /// video id
  final String _videoId = 'a_IA-8nQ4FY';

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: _videoId,
      flags: const YoutubePlayerFlags(
        hideThumbnail: true,
        captionLanguage: 'ja',
        disableDragSeek: false,
        isLive: false,
        startAt: 0,
      ),
    );
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
            Container()
          ]
        ),
      ),
    );
  }
}