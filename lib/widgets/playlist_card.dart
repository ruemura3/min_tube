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
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  Image(
                    image: NetworkImage(
                      playlist.snippet!.thumbnails!.medium!.url!
                    ),
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.7),
                    width: 84,
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 8,),
                        Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8,),
                        Text(
                          '${playlist.contentDetails!.itemCount!.toString()}本の動画',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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