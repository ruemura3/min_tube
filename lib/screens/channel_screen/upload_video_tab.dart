import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/error_screen.dart';
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
  /// is loading
  bool _isLoading = false;
  /// upload video response
  SearchListResponse? _response;
  /// upload video list
  List<SearchResult> _items = [];

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Future(() async {
      try {
        final response = await _api.getSearchResponse(
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

  /// get additional upload video
  bool _getAdditionalUploadVideo(ScrollNotification scrollDetails) {
    if (!_isLoading &&
    scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent &&
      _items.length < _response!.pageInfo!.totalResults!) {
      _isLoading = true;
      Future(() async {
        try {
          final response = await _api.getSearchResponse(
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
            itemCount: _items.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == _items.length) {
                if (_items.length < _response!.pageInfo!.totalResults!) {
                  return Center(child: CircularProgressIndicator(),);
                }
                return Container();
              }
              return VideoCardForUpload(searchResult: _items[index]);
            },
          ),
        ),
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }
}