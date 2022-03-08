import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/error_screen.dart';
import 'package:min_tube/util/util.dart';
import 'package:min_tube/widgets/floating_search_button.dart';
import 'package:min_tube/widgets/profile_card.dart';
import 'package:min_tube/widgets/search_bar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    // get video and channel info
    Future(() async {
      try {
        var video = await _api.getVideoResponse(ids: [widget.videoId]);
        var channel = await _api.getChannelResponse(ids: [video.items![0].snippet!.channelId!]);
        if (mounted) {
          setState(() {
            _video = video.items![0];
            _channel = channel.items![0];
            _controller = YoutubePlayerController(
              initialVideoId: widget.videoId,
              flags: YoutubePlayerFlags(
                hideThumbnail: true,
                captionLanguage: 'ja',
              ),
            );
          });
        }
      } catch (e) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ErrorScreen(),
          )
        );
      }
    });
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller!.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller != null
    ? YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller!,
        progressColors: ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
        bottomActions: _video!.snippet!.liveBroadcastContent! != 'live'
        ? [
          const SizedBox(width: 14.0),
          CurrentPosition(),
          const SizedBox(width: 8.0),
          ProgressBar(
            isExpanded: true,
            colors: ProgressBarColors(
              backgroundColor: Colors.white.withOpacity(0.6),
              playedColor: Colors.red,
              bufferedColor: Colors.white,
              handleColor: Colors.redAccent,
            ),
          ),
          RemainingDuration(),
          const PlaybackSpeedButton(),
          FullScreenButton(),
        ]
        : [
          SizedBox(width: 10,),
          Container(
            padding: const EdgeInsets.only(left: 3, top: 2, right: 3, bottom: 2),
            color: Colors.red.withOpacity(0.7),
            child: Text('LIVE'),
          ),
          Expanded(child: Row(),),
          FullScreenButton(),
        ],
        onReady: () {},
        onEnded: (data) {},
      ),
      builder: (context, player) => Scaffold(
        appBar: SearchBar(),
        body: _videoScreenBody(player),
        floatingActionButton: FloatingSearchButton(),
      ),
    )
    : Scaffold(
      appBar: SearchBar(),
      body: Center(child: CircularProgressIndicator(),),
    );
  }

  Widget _videoScreenBody(Widget player) {
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
                  ProfileCardForVideoScreen(channel: _channel!,),
                  Divider(color: Colors.grey,),
                  SizedBox(height: 8,),
                  Util.getDescriptionWithUrl(
                    _video!.snippet!.description!,
                    context,
                  ),
                  SizedBox(height: 136,),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}