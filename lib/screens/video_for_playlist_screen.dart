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
class VideoForPlaylistScreen extends StatefulWidget {
  /// playlist
  final Playlist playlist;
  /// playlist response
  final PlaylistItemListResponse response;
  /// playlist items
  final List<PlaylistItem> items;
  /// current index
  final int idx;

  /// constructor
  VideoForPlaylistScreen({
    required this.playlist,
    required this.response,
    required this.items,
    required this.idx
  });

  @override
  _VideoForPlaylistScreenState createState() => _VideoForPlaylistScreenState();
}

/// video screen state
class _VideoForPlaylistScreenState extends State<VideoForPlaylistScreen> {
  /// api service
  ApiService _api = ApiService.instance;
  /// is loading
  bool _isLoading = false;
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
  late YoutubePlayerController _controller;
  /// playlist response
  late PlaylistItemListResponse _response;
  /// playlist items
  late List<PlaylistItem> _items;
  /// current index
  late int _idx;
  /// video id
  late String _videoId;

  @override
  void initState() {
    super.initState();
    _response = widget.response;
    _items = widget.items;
    _idx = widget.idx;
    _videoId = _items[_idx].contentDetails!.videoId!;
    _getVideoByVideoId();
    _controller = YoutubePlayerController(
      initialVideoId: _videoId,
      flags: YoutubePlayerFlags(
        hideThumbnail: true,
        captionLanguage: 'ja',
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

  /// get video by video id
  void _getVideoByVideoId() async {
    try {
      var video = await _api.getVideoResponse(ids: [_videoId]);
      var channel = await _api.getChannelResponse(ids: [video.items![0].snippet!.channelId!]);
      var rating = await _api.getVideoRating(ids: [_videoId]);
      if (mounted) {
        setState(() {
          _video = video.items![0];
          _channel = channel.items![0];
          _rating = rating.items![0].rating;
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
  }

  /// start next video
  void _startNextVideo() {
    _idx += 1;
    _videoId = _items[_idx].contentDetails!.videoId!;
    _getVideoByVideoId();
    _controller.load(_videoId);
    if (_idx == _items.length - 2) {
      _getAdditionalPlaylistItemByLastVideo();
    }
  }

  /// get additional playlist item by scroll
  bool _getAdditionalPlaylistItemByScroll(ScrollNotification scrollDetails) {
    if (!_isLoading &&
      scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent &&
      _items.length < _response.pageInfo!.totalResults!) {
      _isLoading = true;
      _getAdditionalPlaylist();
    }
    return false;
  }

  /// get additional playlist item by last video
  void _getAdditionalPlaylistItemByLastVideo() {
    if (!_isLoading && _items.length < _response.pageInfo!.totalResults!) {
      _isLoading = true;
      _getAdditionalPlaylist();
    }
  }

  /// get additional playlist item
  Future<void> _getAdditionalPlaylist() async {
    try {
      final response = await _api.getPlaylistItemResponse(
        id: widget.playlist.id!,
        pageToken: _response.nextPageToken!,
      );
      if (mounted) {
        setState(() {
          _response = response;
          _items.addAll(response.items!);
          _isLoading = false;
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
        progressColors: ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
        bottomActions: _bottomActions(),
        onEnded: (data) {
          _startNextVideo();
        },
      ),
      builder: (context, player) => Scaffold(
        appBar: SearchBar(
          title: _video != null
          ? _video!.snippet!.title!
          : '',
        ),
        body: _videoScreenBody(player),
        floatingActionButton: FloatingSearchButton(),
      ),
    );
  }

  /// bottom actions
  List<Widget> _bottomActions() {
    if (_video != null) {
      if (_video!.snippet!.liveBroadcastContent! != 'live') {
        return [
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
        ];
      }
    return [
      SizedBox(width: 10,),
      Container(
        padding: const EdgeInsets.only(left: 4, top: 2, right: 4, bottom: 2),
        color: Colors.red.withOpacity(0.7),
        child: Text('LIVE'),
      ),
      Expanded(child: Row(),),
      FullScreenButton(),
    ];
    }
    return [];
  }

  Widget _videoScreenBody(Widget player) {
    return Column(
      children: [
        player,
        _video != null && _channel != null
        ? Expanded(
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
                        launch('https://www.youtube.com/watch?v=$_videoId');
                      },
                      child: Text('この動画を外部ブラウザで開く')
                    ),
                  ),
                  SizedBox(height: 80,),
                ],
              ),
            ),
          ),
        )
        : Center(child: CircularProgressIndicator(),),
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
                    text: 'https://www.youtube.com/watch?v=$_videoId'
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
        await _api.rateVideo(id: _videoId, rating: 'like');
        setState(() {
          _rating = 'like';
          _isLikeEnabled = true;
        });
      } else {
        await _api.rateVideo(id: _videoId, rating: 'none');
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
        await _api.rateVideo(id: _videoId, rating: 'dislike');
        setState(() {
          _rating = 'dislike';
          _isDislikeEnabled = true;
        });
      } else {
        await _api.rateVideo(id: _videoId, rating: 'none');
        setState(() {
          _rating = 'none';
          _isDislikeEnabled = true;
        });
      }
    });
  }
}