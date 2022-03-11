import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/error_screen.dart';
import 'package:min_tube/widgets/playlist_card.dart';

/// channel playlist tab
class PlaylistTab extends StatefulWidget {
  /// channel instance
  final Channel channel;
  /// is mine
  final bool isMine;

  /// constructor
  PlaylistTab({required this.channel, required this.isMine});

  @override
  _PlaylistTabState createState() => _PlaylistTabState();
}

/// channel playlist tab state
class _PlaylistTabState extends State<PlaylistTab> {
  /// api service
  ApiService _api = ApiService.instance;
  /// is loading
  bool _isLoading = false;
  /// playlist item response
  PlaylistListResponse? _response;
  /// playlist item list
  List<Playlist> _items = [];

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Future(() async {
      try {
        final response = await _api.getPlaylistResponse(
          channelId: widget.channel.id!
        );
        if (mounted) {
          setState(() {
            _response = response;
            _items = response.items!;
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

  /// get item length
  int _getTotalResults() {
    if (widget.isMine) {
      return _response!.pageInfo!.totalResults! - 1;
    }
    return _response!.pageInfo!.totalResults!;
  }

  /// get additional playlist
  bool _getAdditionalPlaylistItem(ScrollNotification scrollDetails) {
    if (!_isLoading &&
      scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent &&
      _items.length < _response!.pageInfo!.totalResults!) {
      _isLoading = true;
      Future(() async {
        try {
          final response = await _api.getPlaylistResponse(
            channelId: widget.channel.id!,
            pageToken: _response!.nextPageToken!,
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
  }

  @override
  Widget build(BuildContext context) {
    if (_items.length == 0) {
      return Center(
        child: Text('このチャンネルにはプレイリストがありません'),
      );
    }
    if (_response != null) {
      return NotificationListener<ScrollNotification>(
        onNotification: _getAdditionalPlaylistItem,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ListView.builder(
            itemCount: _items.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == _items.length) {
                if (_items.length < _getTotalResults()) {
                  return Center(child: CircularProgressIndicator(),);
                }
                return Container();
              }
              return PlaylistCard(playlist: _items[index]);
            },
          ),
        ),
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }
}