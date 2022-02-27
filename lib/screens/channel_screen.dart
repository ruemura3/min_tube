import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/widgets/profile_card.dart';
import 'package:min_tube/widgets/search_bar.dart';
import 'package:min_tube/widgets/video_card.dart';

/// channel screen
class ChannelScreen extends StatefulWidget {
  /// channel id
  final String? channelId;
  /// channel instance
  final Channel? channel;
  /// channel title
  final String channelTitle;

  /// constructor
  ChannelScreen({this.channelId, this.channel, required this.channelTitle});

  @override
  _ChannelScreenState createState() => _ChannelScreenState();
}

/// channel screen state
class _ChannelScreenState extends State<ChannelScreen> {
  /// api service
  ApiService _api = ApiService.instance;
  /// channel instance
  Channel? _channel;
  /// playlist items list response
  PlaylistItemListResponse? _response;
  /// search result list
  List<PlaylistItem> _items = [];

  @override
  void initState() {
    super.initState();
    if (widget.channel == null) {
      Future(() async {
        final channel = await _api.getChannel(widget.channelId!);
        final response = await _api.getPlaylistItemsListResponse(
          channel.contentDetails!.relatedPlaylists!.uploads!
        );
        setState(() {
          _channel = channel;
          _response = response;
          _items = response.items!;
        });
      });
    } else {
      Future(() async {
        final response = await _api.getPlaylistItemsListResponse(
          widget.channel!.contentDetails!.relatedPlaylists!.uploads!
        );
        setState(() {
          _channel = widget.channel;
          _response = response;
          _items = response.items!;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchBar(widget.channelTitle),
      body: _channelScreenBody(),
    );
  }

  /// channel screen body
  Widget _channelScreenBody() {
    if (_response != null) {
      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollDetails) {
          if (scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent) {
            Future(() async {
              final response = await _api.getPlaylistItemsListResponse(
                _channel!.contentDetails!.relatedPlaylists!.uploads!,
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
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.all(16),
          itemCount: _items.length + 2,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: ProfileCardForChannelScreen(channel: _channel!,),
              );
            }
            if (index == _items.length + 1) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Center(child: CircularProgressIndicator(),),
              );
            }
            return VideoCardForPlaylist(playlistItem: _items[index - 1]);
          },
        ),
      );
    } else {
      return Center(child: CircularProgressIndicator(),);
    }
  }
}