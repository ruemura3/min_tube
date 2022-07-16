import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/channel_screen/channel_screen.dart';
import 'package:min_tube/util/util.dart';
import 'package:min_tube/widgets/floating_search_button.dart';
import 'package:min_tube/widgets/subscribe_button.dart';
import 'package:min_tube/widgets/original_app_bar.dart';
import 'package:min_tube/widgets/video_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// 動画画面
class VideoScreen extends StatefulWidget {
  /// 動画ID
  final String? videoId;
  /// プレイリストインスタンス
  final Playlist? playlist;
  /// プレイリストアイテムレスポンス
  final PlaylistItemListResponse? response;
  /// プレイリストアイテム一覧
  final List<PlaylistItem>? items;
  /// 現在のインデックス
  final int? idx;
  /// プレイリスト用かどうか
  final bool isForPlaylist;

  /// コンストラクタ
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

/// 動画画面ステート
class _VideoScreenState extends State<VideoScreen> {
  /// APIインスタンス
  ApiService _api = ApiService.instance;
  /// ロード中フラグ
  bool _isLoading = false;
  /// 動画ID
  late String _videoId;
  /// 動画インスタンス
  Video? _video;
  /// チャンネルインスタンス
  Channel? _channel;
  /// 動画の評価
  String? _rating;
  /// 高評価ボタン活性フラグ
  bool _isLikeEnabled = false;
  /// 低評価ボタン活性フラグ
  bool _isDislikeEnabled = false;
  /// 非表示動画かどうか
  bool _isNotAvailable = false;
  /// プレイリストアイテムレスポンス
  late PlaylistItemListResponse _response;
  /// プレイリストアイテム一覧
  late List<PlaylistItem> _items;
  /// 現在のインデックス
  late int _idx;
  /// YouTubeプレイヤーコントローラ
  late YoutubePlayerController _controller;
  /// YouTubeプレイヤーが準備できたかどうか
  bool _isPlayerReady = false;
  /// ボリューム
  double _volume = 100;

  @override
  void initState() {
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
    super.initState();
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

  /// 動画IDから動画を取得する
  void _getVideoByVideoId({bool? isToNext}) async {
    setState(() {
      _isNotAvailable = false;
    });
    var video = await _api.getVideoList(ids: [_videoId]);
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
    var channel = await _api.getChannelList(ids: [video.items![0].snippet!.channelId!]);
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
  }

  /// 1つ前の動画を開始する
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

  /// 1つ後の動画を開始する
  void _startNextVideo() {
    if (_idx == _items.length - 3) {
      if (!_isLoading && _items.length < _response.pageInfo!.totalResults!) {
        _getAdditionalPlaylist();
      }
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

  /// 追加のプレイリストアイテムを読み込む
  void _getAdditionalPlaylist() async {
    _isLoading = true;
    Future(()async {
      final response = await _api.getPlaylistItemList(
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
    });
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
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (data) {
          if(widget.isForPlaylist) {
            _startNextVideo();
          }
        },
      ),
      builder: (context, player) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: OriginalAppBar(),
          body: _videoScreenBody(player),
        ),
      ),
    );
  }

  /// ボタンアクション
  List<Widget>? _bottomActions() {
    if (_video != null) {
      if (_video!.snippet!.liveBroadcastContent! != 'live') {
        return [
          const SizedBox(width: 14.0),
          CurrentPosition(),
          const SizedBox(width: 8.0),
          ProgressBar(
            isExpanded: true,
            colors: ProgressBarColors(
              playedColor: Colors.red,
              handleColor: Colors.redAccent,
            ),
          ),
          RemainingDuration(),
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
      ];
    }
    return [];
  }

  // 動画画面ボディ
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
                  child: Column(
                    children: [
                      widget.isForPlaylist
                        ? InkWell(
                          onTap: _showPlaylistItems,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            width: double.infinity,
                            color: Colors.black,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.playlist!.snippet!.title!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color:Colors.white),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        )
                        : Container(),
                      Padding(
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
                              _statisticInfo(),
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w300,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            _videoScreenButtons(),
                            Divider(color: Colors.grey,),
                            _profileCard(_channel!,),
                            Divider(color: Colors.grey,),
                            SizedBox(height: 8,),
                            Util.getDescriptionWithUrl(
                              _video!.snippet!.description!,
                              context,
                            ),
                            SizedBox(height: 96,),
                          ],
                        ),
                      ),
                    ],
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
        Positioned(
          left: 16,
          right: 16,
          bottom: 49,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 56,
                width: 296,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.cyan,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: Offset(1, 2),
                    ),
                  ]
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.keyboard_arrow_left, color: Colors.white,)
                    ),
                    IconButton(
                      onPressed: () {
                        _controller.seekTo(_controller.value.position - Duration(seconds: 10));
                      },
                      icon: Icon(Icons.forward_10, color: Colors.white,)
                    ),
                    IconButton(
                      icon: Icon(
                        _controller.value.isPlaying
                          ? Icons.play_arrow
                          : Icons.pause,
                        color: Colors.white,
                      ),
                      onPressed: _isPlayerReady
                        ? () {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                          setState(() {});
                        }
                        : null,
                    ),
                    IconButton(
                      onPressed: () {
                        _controller.seekTo(_controller.value.position + Duration(seconds: 10));
                      },
                      icon: Icon(Icons.replay_10, color: Colors.white,)
                    ),
                    // IconButton(
                    //   onPressed: () {
                    //     showSettingDialog(context);
                    //   },
                    //   icon: Icon(Icons.more_horiz), color: Colors.white,
                    // ),
                  ]
                ),
              ),
              FloatingSearchButton(),
            ],
          ),
        ),
      ]
    );
  }

  String _statisticInfo() {
    if (_video != null) {
      if (_video!.snippet!.liveBroadcastContent! != 'live') {
        return Util.viewsAndTimeago(
          _video!.statistics!.viewCount!,
          _video!.snippet!.publishedAt!
        );
      } else {
        return Util.formatSubScriberCount(_video!.liveStreamingDetails!.concurrentViewers!)! + ' 人が視聴中';
      }
    } else {
      return '';
    }
  }

  /// 動画用ボタン
  Widget _videoScreenButtons() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
            icon: Icon(Icons.content_copy,)
          ),
          IconButton(
            onPressed: () {
              launch('https://www.youtube.com/watch?v=$_videoId');
            },
            icon: Icon(Icons.open_in_browser,)
          ),
        ],
      ),
    );
  }

  /// 高評価ボタン押下時挙動
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

  /// 低評価ボタン押下時挙動
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

  /// プレイリストアイテムを表示する
  _showPlaylistItems() {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return _playlistItems();
          }
        );
      }
    );
  }

  /// プレイリストアイテム
  Widget _playlistItems() {
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
                  _getAdditionalPlaylist();
                }
                return false;
              },
              child: ListView.builder(
                itemCount: _items.length + 2,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          IconButton(onPressed: _startPreviousVideo, icon: Icon(Icons.skip_previous)),
                          IconButton(onPressed: _startNextVideo, icon: Icon(Icons.skip_next)),
                        ],),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.clear)
                        ),
                      ],
                    );
                  }
                  if (index == _items.length + 1) {
                    if (_items.length < _response.pageInfo!.totalResults!) {
                      return Center(child: CircularProgressIndicator(),);
                    }
                    return Container();
                  }
                  return VideoCardForPlaylist(
                    playlist: widget.playlist!,
                    response: _response,
                    items: _items,
                    idx: index - 1,
                  );
                },
              ),
            ),
          );
        }
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }

  /// プロフィールカード
  Widget _profileCard(Channel channel) {
    return Container(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChannelScreen(
              channel: channel,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  channel.snippet!.thumbnails!.medium!.url!
                ),
              ),
              SizedBox(width: 8,),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      channel.snippet!.title!,
                      overflow: TextOverflow.ellipsis,
                    ),
                    channel.statistics!.subscriberCount != null
                      ? Text(
                        'チャンネル登録者数 ' +
                        Util.formatSubScriberCount(channel.statistics!.subscriberCount)!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13
                        ),
                      )
                      : Container(),
                  ],
                ),
              ),
              SubscribeButton(channel: channel,),
            ],
          ),
        ),
      ),
    );
  }

  /// 設定ダイアログを表示する
  showSettingDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                children: [
                  Slider(
                    inactiveColor: Colors.transparent,
                    value: _volume,
                    min: 0.0,
                    max: 100.0,
                    divisions: 10,
                    label: '${(_volume).round()}',
                    onChanged: _isPlayerReady
                      ? (value) {
                          setState(() {
                            _volume = value;
                          });
                          _controller.setVolume(_volume.round());
                        }
                      : null,
                  ),
                ]
              ),
              actions: [
                TextButton(
                  child: Text(
                    '完了',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          }
        );
      }
    );
  }
}