import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/widgets/floating_search_button.dart';
import 'package:min_tube/widgets/search_bar.dart';
import 'package:min_tube/widgets/video_card.dart';

/// playlist screen
class PlaylistScreen extends StatefulWidget {
  /// playlist Id
  final Playlist playlist;

  /// constructor
  PlaylistScreen({required this.playlist});

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

/// playlist screen item
class _PlaylistScreenState extends State<PlaylistScreen> {
  /// api service
  ApiService _api = ApiService.instance;
  /// is loading
  bool _isLoading = false;
  /// upload video response
  PlaylistItemListResponse? _response;
  /// upload video list
  List<PlaylistItem> _items = [];

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Future(() async {
      final response = await _api.getPlaylistItemResponse(
        id: widget.playlist.id!,
      );
      if (mounted) {
        setState(() {
          _response = response;
          _items = response.items!;
        });
      }
      _isLoading = false;
    });
  }

  /// get additional upload video
  bool _getAdditionalUploadVideo(ScrollNotification scrollDetails) {
    if (!_isLoading &&
    scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent &&
      _items.length < _response!.pageInfo!.totalResults!) {
      _isLoading = true;
      Future(() async {
        final response = await _api.getPlaylistItemResponse(
          id: widget.playlist.id!,
          pageToken: _response!.nextPageToken!,
        );
        if (mounted) {
          setState(() {
            _response = response;
            _items.addAll(response.items!);
          });
        }
        _isLoading = false;
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchBar(title: widget.playlist.snippet!.title!,),
      body: _playlistScreenBody(),
      floatingActionButton: FloatingSearchButton(),
    );
  }

  /// playlist screen body
  Widget _playlistScreenBody() {
    if (_response != null) {
      if (_items.length == 0) {
        return Center(
          child: Text('このチャンネルには動画がありません'),
        );
      }
      return NotificationListener<ScrollNotification>(
        onNotification: _getAdditionalUploadVideo,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ListView.builder(
            itemCount: _items.length + 2,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return _playlistDetail();
              }
              if (index == _items.length + 1) {
                if (_items.length < _response!.pageInfo!.totalResults!) {
                  return Center(child: CircularProgressIndicator(),);
                }
                return Container();
              }
              return VideoCardForPlaylist(playlistItem: _items[index - 1]);
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
              widget.playlist.snippet!.title!,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 8,),
          Container(
            width: double.infinity,
            child: Text(
              widget.playlist.snippet!.channelTitle!,
              style: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(height: 8,),
          Text(
            widget.playlist.snippet!.description!,
            style: TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
  }
}