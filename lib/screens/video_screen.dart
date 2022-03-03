import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/util/util.dart';
import 'package:min_tube/widgets/profile_card.dart';
import 'package:min_tube/widgets/search_bar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// video screen
class VideoScreen extends StatefulWidget {
  /// video id
  final String videoId;
  /// video title
  final String videoTitle;

  /// constructor
  VideoScreen({required this.videoId, required this.videoTitle});

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
      var video = await _api.getVideoResponse(ids: [widget.videoId]);
      var channel = await _api.getChannelResponse(ids: [video.items![0].snippet!.channelId!]);
      setState(() {
        _video = video.items![0];
        _channel = channel.items![0];
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
        onReady: () {},
        onEnded: (data) {},
      ),
      builder: (context, player) => Scaffold(
        appBar: SearchBar(title: widget.videoTitle,),
        body: _videoScreenBody(player),
      ),
    );
  }

  /// video screen body
  Widget _videoScreenBody(Widget player) {
    if (_video != null && _channel != null) {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          _videoDetails(player),
          Padding(
            padding: const EdgeInsets.all(16).copyWith(bottom: 32),
            child: ProfileCardForVideoScreen(channel: _channel!,),
          )
        ]
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }

  Widget _videoDetails(Widget player) {
    return Column(
      children: [
        player,
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                    Util.viewsAndTimeago(
                      _video!.statistics!.viewCount!,
                      _video!.snippet!.publishedAt!
                    ),
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w300,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8,),
                  Divider(color: Colors.grey,),
                  SizedBox(height: 8,),
                  Text(_video!.snippet!.description!,),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}