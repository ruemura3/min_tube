import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/widgets/video_card.dart';

/// channel upload video tab
class UploadVideoTab extends StatefulWidget {
  /// channel instance
  final Channel channel;

  /// constructor
  UploadVideoTab({required this.channel});

  @override
  _UploadVideoTabState createState() => _UploadVideoTabState();
}

/// channel upload video tab
class _UploadVideoTabState extends State<UploadVideoTab> {
  /// api service
  ApiService _api = ApiService.instance;
  /// upload video response
  PlaylistItemListResponse? _response;
  /// upload video list
  List<PlaylistItem> _items = [];

  @override
  void initState() {
    super.initState();
    Future(() async {
      final response = await _api.getPlaylistItemResponse(
        id: widget.channel.contentDetails!.relatedPlaylists!.uploads!,
      );
      setState(() {
        _response = response;
        _items = response.items!;
      });
    });
  }

  /// get additional upload video
  bool _getAdditionalUploadVideo(ScrollNotification scrollDetails) {
    if (scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent &&
      _items.length < _response!.pageInfo!.totalResults!) {
      Future(() async {
        final response = await _api.getPlaylistItemResponse(
          id: widget.channel.contentDetails!.relatedPlaylists!.uploads!,
          pageToken: _response!.nextPageToken!,
        );
        setState(() {
          _response = response;
          _items.addAll(response.items!);
        });
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_response != null) {
      return NotificationListener<ScrollNotification>(
        onNotification: _getAdditionalUploadVideo,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ListView.builder(
            itemCount: _items.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == _items.length) {
                if (_items.length < _response!.pageInfo!.totalResults!) {
                  return Center(child: CircularProgressIndicator(),);
                }
                return Container();
              }
              return VideoCardForPlaylist(playlistItem: _items[index]);
            },
          ),
        ),
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }
}