import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/error_screen.dart';
import 'package:min_tube/screens/playlist_screen.dart';
import 'package:min_tube/widgets/playlist_card.dart';
import 'package:min_tube/widgets/search_bar.dart';

class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
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
        final response = await _api.getPlaylistResponse(mine: true);
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

  /// get additional playlist
  bool _getAdditionalPlaylistItem(ScrollNotification scrollDetails) {
    if (!_isLoading &&
      scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent &&
      _items.length < _response!.pageInfo!.totalResults!) {
      _isLoading = true;
      Future(() async {
        try {
          final response = await _api.getPlaylistResponse(
            mine: true,
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
    return Scaffold(
      appBar: SearchBar(),
      body: _myScreenBody(),
    );
  }

  /// my screen body
  Widget _myScreenBody() {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlaylistScreen(),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.thumb_up_outlined),
            SizedBox(width: 16,),
            Expanded(
              child: Text(
                '高く評価した動画',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    // if (_items.length == 0) {
    //   return Center(
    //     child: Text('このチャンネルにはプレイリストがありません'),
    //   );
    // }
    // if (_response != null) {
    //   return NotificationListener<ScrollNotification>(
    //     onNotification: _getAdditionalPlaylistItem,
    //     child: Padding(
    //       padding: const EdgeInsets.only(top: 8),
    //       child: ListView.builder(
    //         itemCount: _items.length + 1,
    //         itemBuilder: (BuildContext context, int index) {
    //           if (index == _items.length) {
    //             if (_items.length < _response!.pageInfo!.totalResults!) {
    //               return Center(child: CircularProgressIndicator(),);
    //             }
    //             return Container();
    //           }
    //           return PlaylistCard(playlist: _items[index]);
    //         },
    //       ),
    //     ),
    //   );
    // }
    // return Center(child: CircularProgressIndicator(),);
  }
}