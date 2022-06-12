import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/channel_screen/channel_screen.dart';
import 'package:min_tube/screens/playlist_screen.dart';
import 'package:min_tube/screens/video_screen.dart';
import 'package:min_tube/util/util.dart';
import 'package:min_tube/widgets/floating_search_button.dart';
import 'package:min_tube/widgets/original_app_bar.dart';

/// 検索結果画面
class SearchResultScreen extends StatefulWidget {
  /// 検索クエリ
  final String query;

  /// コンストラクタ
  SearchResultScreen({required this.query});

  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

/// 検索結果画面ステート
class _SearchResultScreenState extends State<SearchResultScreen> {
  /// APIインスタンス
  ApiService _api = ApiService.instance;
  /// ロード中フラグ
  bool _isLoading = false;
  /// APIレスポンス
  SearchListResponse? _response;
  /// 検索結果一覧
  List<SearchResult> _items = [];

  @override
  void initState() {
    _isLoading = true;
    Future(() async {
      final response = await _api.getSearchList(query: widget.query);
      if (mounted) {
        setState(() {
          _response = response;
          _items = response.items!;
          _isLoading = false;
        });
      }
    });
    super.initState();
  }

  /// 追加の検索結果を取得する
  bool _getAdditionalSearchResult(ScrollNotification scrollDetails) {
    if (!_isLoading && // ロード中でない
      scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent && // 最後までスクロールしている
      _items.length < _response!.pageInfo!.totalResults!) { // 現在のアイテム数が全アイテム数より少ない
      _isLoading = true;
      Future(() async {
        final response = await _api.getSearchList(
          query: widget.query,
          pageToken: _response!.nextPageToken!,
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
    return Scaffold(
      appBar: OriginalAppBar(title: widget.query,),
      body: _searchResultScreenBody(),
      floatingActionButton: FloatingSearchButton(),
    );
  }

  /// 検索結果画面ボディ
  Widget _searchResultScreenBody() {
    if (_response != null) {
      return NotificationListener<ScrollNotification>(
        onNotification: _getAdditionalSearchResult,
        child: ListView.builder(
          padding: const EdgeInsets.all(8).copyWith(bottom: 0),
          itemCount: _items.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == _items.length) {
              if (_items.length < _response!.pageInfo!.totalResults!) {
                return Center(child: CircularProgressIndicator(),);
              }
              return Container();
            }
            if (_items[index].id!.kind! == 'youtube#video') {
              return _videoCard(_items[index],);
            }
            if (_items[index].id!.kind! == 'youtube#channel') {
              return _profileCard(_items[index],);
            }
            if (_items[index].id!.kind! == 'youtube#playlist') {
              return _playlistCard(_items[index],);
            }
            return Container();
          },
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
      child: Column(
        children: [
          Container(
            height: 112,
            padding: const EdgeInsets.all(8),
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
                        '${Util.formatTimeago(searchResult.snippet!.publishedAt)} ・ ${searchResult.snippet!.channelTitle!}',
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
          Divider(color: Colors.grey,),
        ],
      ),
    );
  }

  /// プロフィールカード
  Widget _profileCard(SearchResult searchResult) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChannelScreen(
            channelId: searchResult.snippet!.channelId!,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(
                    searchResult.snippet!.thumbnails!.medium!.url!
                  ),
                ),
                SizedBox(width: 16,),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        searchResult.snippet!.title!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey,),
        ],
      ),
    );
  }

  /// プレイリストカード
  Widget _playlistCard(SearchResult searchResult) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlaylistScreen(
            playlistId: searchResult.id!.playlistId!,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 112,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Image.network(
                      searchResult.snippet!.thumbnails!.medium!.url!,
                      errorBuilder: (c, o, s) {
                        return Container();
                      },
                    ),
                    Container(
                      color: Colors.black.withOpacity(0.7),
                      width: 64,
                      height: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          ),
                          Text(
                            'プレイ\nリスト',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                        searchResult.snippet!.channelTitle!,
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
          Divider(color: Colors.grey,),
        ],
      ),
    );
  }
}