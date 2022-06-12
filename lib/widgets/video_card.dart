import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/screens/video_screen.dart';
import 'package:min_tube/util/util.dart';

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
