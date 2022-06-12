import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/screens/playlist_screen.dart';

/// playlist card for search result
/// use only when kind is 'youtube#playlist'
class PlaylistCardForSearchResult extends StatelessWidget {
  /// search result
  final SearchResult searchResult;

  /// constructor
  PlaylistCardForSearchResult({required this.searchResult});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlaylistScreen(
            playlistId: searchResult.id!.playlistId!,
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
                    alignment: Alignment.centerRight,
                    children: [
                      Image.network(
                        searchResult.snippet!.thumbnails!.medium!.url!,
                        errorBuilder: (c, o, s) {
                          return Container();
                        },
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.7),
                        width: 64,
                        height: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                            Text(
                              'プレイ\nリスト',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        searchResult.snippet!.channelTitle!,
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
          ),
          Divider(color: Colors.grey,),
        ],
      ),
    );
  }
}