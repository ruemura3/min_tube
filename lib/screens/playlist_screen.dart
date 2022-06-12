import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/channel_screen/channel_screen.dart';
import 'package:min_tube/widgets/floating_search_button.dart';
import 'package:min_tube/widgets/app_bar.dart';
import 'package:min_tube/widgets/video_card.dart';

/// playlist screen
class PlaylistScreen extends StatefulWidget {
  /// playlist id
  final String? playlistId;
  /// playlist
  final Playlist? playlist;

  /// constructor
  PlaylistScreen({this.playlistId, this.playlist});

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

/// playlist screen item
class _PlaylistScreenState extends State<PlaylistScreen> {
  /// api service
  ApiService _api = ApiService.instance;
  /// is loading
  bool _isLoading = false;
  /// playlist instance
  Playlist? _playlist;
  /// upload video response
  PlaylistItemListResponse? _response;
  /// upload video list
  List<PlaylistItem> _items = [];
  /// is there private
  int _privateCount = 0;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    if (widget.playlist != null) {
      _playlist = widget.playlist;
      Future(() async {
        await _getPlaylistItems();
      });
    } else {
      Future(() async {
        final response = await _api.getPlaylistList(ids: [widget.playlistId ?? 'LL']);
        if (mounted) {
          setState(() {
            _playlist = response.items![0];
          });
        }
        await _getPlaylistItems();
      });
    }
  }

  Future<void> _getPlaylistItems() async {
    final response = await _api.getPlaylistItemList(
      id: _playlist!.id!,
    );
    if (mounted) {
      setState(() {
        _response = response;
        _items = response.items!;
        _isLoading = false;
        print(_items);
      });
    }
  }

  /// get additional playlist item
  bool _getAdditionalPlaylistItem(ScrollNotification scrollDetails) {
    if (!_isLoading &&
      scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent &&
      _items.length < _response!.pageInfo!.totalResults!) {
      _isLoading = true;
      Future(() async {
        final response = await _api.getPlaylistItemList(
          id: _playlist!.id!,
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
      appBar: OriginalAppBar(
        title: _playlist != null
        ? _playlist!.snippet!.title!
        : '',
      ),
      body: _playlistScreenBody(),
      floatingActionButton: FloatingSearchButton(),
    );
  }

  /// playlist screen body
  Widget _playlistScreenBody() {
    if (_response != null) {
      return NotificationListener<ScrollNotification>(
        onNotification: _getAdditionalPlaylistItem,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ListView.builder(
            itemCount: _items.length + 2,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return _playlistDetail();
              }
              if (_items.length == 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16,),
                  child: Center(
                    child: Text('このプレイリストには動画がありません'),
                  ),
                );
              }
              if (index == _items.length + 1) {
                if (_items.length < _response!.pageInfo!.totalResults!) {
                  return Center(child: CircularProgressIndicator(),);
                }
                if (_privateCount != 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 16,),
                    child: Center(
                      child: Text('$_privateCount本の利用できない動画が非表示になっています'),
                    ),
                  );
                }
                return Container();
              }
              if (_items[index - 1].status!.privacyStatus != 'public') {
                _privateCount += 1;
              }
              return VideoCardForPlaylist(
                playlist: _playlist!,
                response: _response!,
                items: _items,
                idx: index - 1,
              );
            },
          ),
        ),
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }

  /// playlist detail
  Widget _playlistDetail() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Text(
              _playlist!.snippet!.title!,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 8,),
          Container(
            width: double.infinity,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChannelScreen(
                    channelId: _playlist!.snippet!.channelId!,
                  ),
                ),
              ),
              child: Text(
                _playlist!.snippet!.channelTitle!,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          SizedBox(height: 8,),
          Container(
            width: double.infinity,
            child: Text(
              _playlist!.snippet!.description!,
              style: TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }
}
