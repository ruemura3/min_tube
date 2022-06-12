import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/screens/video_screen.dart';
import 'package:min_tube/util/util.dart';

/// video card for search result
/// use only when kind is 'youtube#video'
class VideoCardForSearchResult extends StatelessWidget {
  /// search result
  final SearchResult searchResult;

  /// constructor
  VideoCardForSearchResult({required this.searchResult});

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.only(top: 4, right: 16, bottom: 4, left: 16),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(4).copyWith(left: 0, right: 16),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      searchResult.snippet!.liveBroadcastContent! == 'none'
                      ? Image.network(
                        searchResult.snippet!.thumbnails!.medium!.url!,
                      )
                      : AspectRatio(
                        aspectRatio: 16/9,
                        child: Container(height: double.infinity,),
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
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          searchResult.snippet!.title!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        searchResult.snippet!.channelTitle!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12
                        ),
                      ),
                      Text(
                        Util.formatTimeago(searchResult.snippet!.publishedAt),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
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

/// video card for playlist
class VideoCardForPlaylist extends StatelessWidget {
  /// playlist
  final Playlist playlist;
  /// playlist response
  final PlaylistItemListResponse response;
  /// playlist items
  final List<PlaylistItem> items;
  /// current index
  final int idx;

  /// constructor
  VideoCardForPlaylist({
    required this.playlist,
    required this.response,
    required this.items,
    required this.idx,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => VideoScreen(
            playlist: playlist,
            response: response,
            items: items,
            idx: idx,
            isForPlaylist: true,
          ),
        ),
      ),
      child: items[idx].snippet!.thumbnails!.medium != null
      ? Container(
          height: 112,
          padding: const EdgeInsets.only(top: 8, right: 16, bottom: 8, left: 16),
          child: Row(
            children: <Widget>[
              Image.network(
                  items[idx].snippet!.thumbnails!.medium!.url!,
                  errorBuilder: (c, o, s) {
                    return AspectRatio(
                      child: Container(),
                      aspectRatio: 16/9,
                    );
                  },
              ),
              SizedBox(width: 16,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        items[idx].snippet!.title!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      Util.formatTimeago(items[idx].contentDetails!.videoPublishedAt),
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
        )
        : Container(),
    );
  }
}
