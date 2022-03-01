import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/widgets/profile_card.dart';
import 'package:min_tube/widgets/video_card.dart';

/// channel home tab
class UploadVideoTab extends StatefulWidget {
  /// channel instance
  final Channel? channel;

  /// constructor
  UploadVideoTab({this.channel});

  @override
  _UploadVideoTabState createState() => _UploadVideoTabState();
}

/// search result screen state class
class _UploadVideoTabState extends State<UploadVideoTab> {
  /// api service
  ApiService _api = ApiService.instance;
  /// playlist items list response
  PlaylistItemListResponse? _response;
  /// search result list
  List<PlaylistItem> _items = [];

  @override
  void initState() {
    super.initState();
    Future(() async {
      final response = await _api.getPlaylistItemListResponse(
        widget.channel!.contentDetails!.relatedPlaylists!.uploads!
      );
      setState(() {
        _response = response;
        _items = response.items!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _channelScreenBody();
  }

  /// channel screen body
  Widget _channelScreenBody() {
    if (_response != null) {
      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollDetails) {
          if (scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent &&
            _items.length < _response!.pageInfo!.totalResults!) {
            Future(() async {
              final response = await _api.getPlaylistItemListResponse(
                widget.channel!.contentDetails!.relatedPlaylists!.uploads!,
                _response!.nextPageToken!
              );
              setState(() {
                _response = response;
                _items.addAll(response.items!);
              });
            });
          }
          return false;
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _items.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == _items.length) {
                if (_items.length < _response!.pageInfo!.totalResults!) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Center(child: CircularProgressIndicator(),),
                  );
                } else {
                  return Container();
                }
              }
              return VideoCardForPlaylist(playlistItem: _items[index]);
            },
          ),
        ),
      );
    } else {
      return Center(child: CircularProgressIndicator(),);
    }
  }
}