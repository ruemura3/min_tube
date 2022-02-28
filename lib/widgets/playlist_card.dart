import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';

/// video card for playlist class
class PlaylistCard extends StatelessWidget {
  /// search result
  final Playlist playlist;

  /// constructor
  PlaylistCard({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onTap: () => Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => VideoScreen(
      //       videoId: playlistItem.contentDetails!.videoId!,
      //       videoTitle: playlistItem.snippet!.title!,
      //     ),
      //   ),
      // ),
      child: Container(
          height: 112,
          padding: EdgeInsets.only(top: 8, right: 16, bottom: 8, left: 16),
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 0, right: 16, bottom: 0, left: 0),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Image(
                      image: NetworkImage(playlist.snippet!.thumbnails!.medium!.url!),
                    ),
                    // Container(
                    //   padding: EdgeInsets.only(top: 0, right: 4, bottom: 4, left: 0),
                    //   child: Container(
                    //     color: video.liveBroadcastContent == 'live' ? Colors.red.withOpacity(0.8) : Colors.black.withOpacity(0.8),
                    //     padding: EdgeInsets.only(top: 1, right: 2, bottom: 1, left: 2),
                    //     child: Text(
                    //       video.formattedDuration(),
                    //       style: TextStyle(
                    //         fontSize: 13,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        playlist.snippet!.title!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      playlist.snippet!.channelTitle!,
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
    );
  }
}