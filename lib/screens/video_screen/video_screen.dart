import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/error_screen.dart';
import 'package:min_tube/util/color_util.dart';
import 'package:min_tube/util/util.dart';
import 'package:min_tube/widgets/floating_search_button.dart';
import 'package:min_tube/widgets/profile_card.dart';
import 'package:min_tube/widgets/app_bar.dart';
import 'package:min_tube/widgets/video_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// video screen
class VideoScreen extends StatefulWidget {
  /// video id
  final String? videoId;
  /// playlist
  final Playlist? playlist;
  /// playlist response
  final PlaylistItemListResponse? response;
  /// playlist items
  final List<PlaylistItem>? items;
  /// current index
  final int? idx;
  /// is for playlist
  final bool isForPlaylist;

  /// constructor
  VideoScreen({
    this.videoId,
    this.playlist,
    this.response,
    this.items,
    this.idx,
    this.isForPlaylist = false,
  });

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

/// video screen state
class _VideoScreenState extends State<VideoScreen> {
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
  /// is not available
  bool _isNotAvailable = false;
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
    if (widget.isForPlaylist) {
      _response = widget.response!;
      _items = widget.items!;
      _idx = widget.idx!;
      _videoId = _items[_idx].contentDetails!.videoId!;
    } else {
      _videoId = widget.videoId!;
    }
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
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// get video by video id
  void _getVideoByVideoId({bool? isToNext}) async {
    setState(() {
      _isNotAvailable = false;
    });
    try {
      var video = await _api.getVideoResponse(ids: [_videoId]);
      if (video.items!.length == 0) {
        if (isToNext != null) {
          if (isToNext) {
            _startNextVideo();
          } else {
            _startPreviousVideo();
          }
        }
        setState(() {
          _isNotAvailable = true;
        });
        return;
      }
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

  /// start previous video
  void _startPreviousVideo() {
    if (_idx > 0) {
      setState(() {
        _video = null;
        _channel = null;
        _rating = null;
        _idx -= 1;
      });
      _videoId = _items[_idx].contentDetails!.videoId!;
      _getVideoByVideoId(isToNext: false);
      _controller.load(_videoId);
    }
  }

  /// start next video
  void _startNextVideo() {
    if (_idx == _items.length - 2) {
      _getAdditionalPlaylistItemByLastVideo();
    }
    if (_idx < _response.pageInfo!.totalResults! - 1) {
      setState(() {
        _video = null;
        _channel = null;
        _rating = null;
      });
      _idx += 1;
      _videoId = _items[_idx].contentDetails!.videoId!;
      _getVideoByVideoId(isToNext: true);
      _controller.load(_videoId);
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
        id: widget.playlist!.id!,
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
          if(widget.isForPlaylist) {
            _startNextVideo();
          }
        },
      ),
      builder: (context, player) => Scaffold(
        appBar: BaseAppBar(
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
        SizedBox(width: 8,),
        Container(
          padding: const EdgeInsets.only(left: 4, top: 2, right: 4, bottom: 2),
          color: Colors.red.withOpacity(0.7),
          child: Text(
            'LIVE',
            style: TextStyle(color: Colors.white),
          ),
        ),
        Expanded(child: Row(),),
        FullScreenButton(),
      ];
    }
    return [];
  }

  Widget _videoScreenBody(Widget player) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Column(
          children: [
            player,
            _video != null && _channel != null && _rating != null
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
                          child: Text('動画のURLをコピーする'),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            launch('https://www.youtube.com/watch?v=$_videoId');
                          },
                          child: Text('この動画をブラウザで開く'),
                        ),
                      ),
                      SizedBox(height: 96,),
                    ],
                  ),
                ),
              ),
            )
            : _isNotAvailable
            ? Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Center(child: Text('この動画は非公開または削除されました'),),
            )
            : Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Center(child: CircularProgressIndicator(),),
            ),
          ],
        ),
        widget.isForPlaylist
        ? InkWell(
          onTap: _showPlaylistList,
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            height: 72,
            color: Colors.black.withOpacity(0.8),
            child: Text(
              widget.playlist!.snippet!.title!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: ColorUtil.reversedTextColor(context)),
            ),
          ),
        )
        : Container(),
      ]
    );
  }

  /// video buttons
  Widget _videoScreenButtons() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.isForPlaylist
          ? IconButton(onPressed: _startPreviousVideo, icon: Icon(Icons.skip_previous))
          : Container(),
          IconButton(onPressed: () {
            _controller.seekTo(_controller.value.position - Duration(seconds: 10));
          }, icon: Icon(Icons.forward_10)),
          IconButton(
            onPressed: _isLikeEnabled
            ? _tapLikeButton
            : null,
            icon: _rating == 'like'
            ? Icon(Icons.thumb_up)
            : Icon(Icons.thumb_up_outlined)
          ),
          IconButton(
            onPressed: _isDislikeEnabled
            ? _tapDislikeButton
            : null,
            icon: _rating == 'dislike'
            ? Icon(Icons.thumb_down)
            : Icon(Icons.thumb_down_outlined)
          ),
          IconButton(onPressed: () {
            _controller.seekTo(_controller.value.position + Duration(seconds: 10));
          }, icon: Icon(Icons.replay_10)),
          widget.isForPlaylist
          ? IconButton(onPressed: _startNextVideo, icon: Icon(Icons.skip_next))
          : Container(),
        ],
      ),
    );
  }

  /// tap like button
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

  /// tap dislike button
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

  _showPlaylistList() {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return _playlistList();
          }
        );
      }
    );
  }

  Widget _playlistList() {
    if (_video != null && _channel != null && _rating != null) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollDetails) {
                if (!_isLoading &&
                  scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent &&
                  _items.length < _response.pageInfo!.totalResults!) {
                  _isLoading = true;
                  Future(() async {
                    try {
                      final response = await _api.getPlaylistItemResponse(
                        id: widget.playlist!.id!,
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
                  });
                }
                return false;
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ListView.builder(
                  itemCount: _items.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == _items.length) {
                      if (_items.length < _response.pageInfo!.totalResults!) {
                        return Center(child: CircularProgressIndicator(),);
                      }
                      return Container();
                    }
                    return VideoCardForPlaylist(
                      playlist: widget.playlist!,
                      response: _response,
                      items: _items,
                      idx: index,
                    );
                  },
                ),
              ),
            ),
          );
        }
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }
}