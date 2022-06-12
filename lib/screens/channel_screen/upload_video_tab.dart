import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/video_screen.dart';
import 'package:min_tube/util/util.dart';

/// チャンネル画面のアップロード動画タブ
class UploadVideoTab extends StatefulWidget {
  /// チャンネルインスタンス
  final Channel channel;

  /// コンストラクタ
  UploadVideoTab({required this.channel});

  @override
  _UploadVideoTabState createState() => _UploadVideoTabState();
}

/// アップロード動画タブステート
class _UploadVideoTabState extends State<UploadVideoTab> {
  /// APIインスタンス
  ApiService _api = ApiService.instance;
  /// ロード中フラグ
  bool _isLoading = false;
  /// APIレスポンス
  SearchListResponse? _response;
  /// アップロード動画一覧
  List<SearchResult> _items = [];

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Future(() async {
      final response = await _api.getSearchList(
        channelId: widget.channel.id!,
        order: 'date',
        type: ['video'],
      );
      if (mounted) {
        setState(() {
          _response = response;
          _items = response.items!;
          _isLoading = false;
        });
      }
    });
  }

  /// 追加の動画読み込み
  bool _getAdditionalUploadVideo(ScrollNotification scrollDetails) {
    if (!_isLoading && // ロード中でない
    scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent && // 最後までスクロールしている
      _items.length < _response!.pageInfo!.totalResults!) { // 現在のアイテム数が全アイテム数より少ない
      _isLoading = true;
      Future(() async {
        final response = await _api.getSearchList(
          channelId: widget.channel.id!,
          order: 'date',
          pageToken: _response!.nextPageToken!,
          type: ['video'],
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
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_response != null) { // レスポンスがnull出ない場合
      if (_items.length == 0) { // アイテム数が0の場合
        return Center(
          child: Text('このチャンネルには動画がありません'),
        );
      }
      return NotificationListener<ScrollNotification>(
        onNotification: _getAdditionalUploadVideo,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ListView.builder(
            itemCount: _items.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == _items.length) { // 最後のインデックスの場合
                if (_items.length < _response!.pageInfo!.totalResults!) {
                  return Center(child: CircularProgressIndicator(),);
                }
                return Container();
              }
              return _videoCard(_items[index]);
            },
          ),
        ),
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }

  /// 動画カード
  Widget _videoCard(SearchResult searchResult) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => VideoScreen(
            videoId: searchResult.id!.videoId!,
          ),
        ),
      ),
      child: Container(
        height: 112,
        padding: const EdgeInsets.only(top: 8, right: 16, bottom: 8, left: 16),
        child: Row(
          children: <Widget>[
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Image.network(
                  searchResult.snippet!.thumbnails!.medium!.url!,
                  errorBuilder: (c, o, s) {
                    return AspectRatio(
                      child: Container(),
                      aspectRatio: 16/9,
                    );
                  },
                ),
                searchResult.snippet!.liveBroadcastContent == 'live'
                  ? Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      color: Colors.red.withOpacity(0.8),
                      padding: const EdgeInsets.only(left: 4, top: 2, right: 4, bottom: 2),
                      child: Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  : Container(),
              ]
            ),
            SizedBox(width: 16,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      searchResult.snippet!.title!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    Util.formatTimeago(searchResult.snippet!.publishedAt),
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}