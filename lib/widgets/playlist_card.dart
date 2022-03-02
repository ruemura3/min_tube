import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';

/// playlist card
class PlaylistCard extends StatelessWidget {
  /// playlist instance
  final Playlist playlist;

  /// constructor
  PlaylistCard({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
          height: 112,
          padding: const EdgeInsets.only(top: 8, right: 16, bottom: 8, left: 16),
          child: Row(
            children: <Widget>[
              Image(
                image: NetworkImage(
                  playlist.snippet!.thumbnails!.medium!.url!
                ),
              ),
              SizedBox(width: 16,),
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