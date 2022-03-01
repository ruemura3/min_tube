import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/widgets/playlist_card.dart';

/// playlist tab
class PlaylistTab extends StatefulWidget {
  /// channel instance
  final Channel? channel;

  PlaylistTab({this.channel});

  @override
  _PlaylistTabState createState() => _PlaylistTabState();
}

class _PlaylistTabState extends State<PlaylistTab> {
  /// api service
  ApiService _api = ApiService.instance;
  /// playlist items list response
  PlaylistListResponse? _response;
  /// search result list
  List<Playlist> _items = [];

  @override
  void initState() {
    super.initState();
    Future(() async {
      final response = await _api.getPlaylistListResponse(
        widget.channel!.id!
      );
      setState(() {
        _response = response;
        _items = response.items!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_response != null) {
      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollDetails) {
          if (scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent &&
            _items.length < _response!.pageInfo!.totalResults!) {
            Future(() async {
              final response = await _api.getPlaylistListResponse(
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
              return PlaylistCard(playlist: _items[index]);
            },
          ),
        ),
      );
    } else {
      return Center(child: CircularProgressIndicator(),);
    }
  }
}