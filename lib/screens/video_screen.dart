import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/error_screen.dart';
import 'package:min_tube/util/util.dart';
import 'package:min_tube/widgets/floating_search_button.dart';
import 'package:min_tube/widgets/profile_card.dart';
import 'package:min_tube/widgets/search_bar.dart';
import 'package:url_launcher/url_launcher.dart';
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
  /// video rating
  String? _rating;
  /// is like button enabled
  bool _isLikeEnabled = false;
  /// is dislike button enabled
  bool _isDislikeEnabled = false;
  /// youtube player controller
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    Future(() async {
      try {
        var video = await _api.getVideoResponse(ids: [widget.videoId]);
        var channel = await _api.getChannelResponse(ids: [video.items![0].snippet!.channelId!]);
        var rating = await _api.getVideoRating(ids: [widget.videoId]);
        if (mounted) {
          setState(() {
            _video = video.items![0];
            _channel = channel.items![0];
            _rating = rating.items![0].rating;
            _controller = YoutubePlayerController(
              initialVideoId: widget.videoId,
              flags: YoutubePlayerFlags(
                hideThumbnail: true,
                captionLanguage: 'ja',
              ),
            );
            _isLikeEnabled = true;
            _isDislikeEnabled = true;
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
    _controller?.pause();
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
                  _videoScreenButtons(),
                  Divider(color: Colors.grey,),
                  ProfileCardForVideoScreen(channel: _channel!,),
                  Divider(color: Colors.grey,),
                  _video!.snippet!.description! != ''
                  ? Column(
                    children: [
                      SizedBox(height: 8,),
                      Util.getDescriptionWithUrl(
                        _video!.snippet!.description!,
                        context,
                      ),
                      SizedBox(height: 8,),
                      Divider(color: Colors.grey,),
                    ],
                  )
                  : Container(),
                  SizedBox(height: 8,),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        launch('https://www.youtube.com/watch?v=${widget.videoId}');
                      },
                      child: Text('この動画を外部ブラウザで開く')
                    ),
                  ),
                  SizedBox(height: 80,),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// video buttons
  Widget _videoScreenButtons() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              IconButton(
                onPressed: _isLikeEnabled
                ? _tapLikeButton
                : null,
                icon: _rating == 'like'
                ? Icon(Icons.thumb_up)
                : Icon(Icons.thumb_up_outlined)
              ),
              Text('高評価'),
            ],
          ),
          Column(
            children: [
              IconButton(
                onPressed: _isDislikeEnabled
                ? _tapDislikeButton
                : null,
                icon: _rating == 'dislike'
                ? Icon(Icons.thumb_down)
                : Icon(Icons.thumb_down_outlined)
              ),
              Text('低評価'),
            ],
          ),
          Column(
            children: [
              IconButton(
                onPressed: () async {
                  final data = ClipboardData(
                    text: 'https://www.youtube.com/watch?v=${widget.videoId}'
                  );
                  await Clipboard.setData(data);
                  final snackBar = SnackBar(
                    content: Text('動画のURLをコピーしました'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                icon: Icon(Icons.copy),
              ),
              Text('コピー'),
            ],
          ),
        ],
      ),
    );
  }

  void _tapLikeButton() {
    setState(() {
      _isLikeEnabled = false;
    });
    Future(() async {
      if (_rating != 'like') {
        await _api.rateVideo(id: widget.videoId, rating: 'like');
        setState(() {
          _rating = 'like';
          _isLikeEnabled = true;
        });
      } else {
        await _api.rateVideo(id: widget.videoId, rating: 'none');
        setState(() {
          _rating = 'none';
          _isLikeEnabled = true;
        });
      }
    });
  }

  void _tapDislikeButton() {
    setState(() {
      _isDislikeEnabled = false;
    });
    Future(() async {
      if (_rating != 'dislike') {
        await _api.rateVideo(id: widget.videoId, rating: 'dislike');
        setState(() {
          _rating = 'dislike';
          _isDislikeEnabled = true;
        });
      } else {
        await _api.rateVideo(id: widget.videoId, rating: 'none');
        setState(() {
          _rating = 'none';
          _isDislikeEnabled = true;
        });
      }
    });
  }
}