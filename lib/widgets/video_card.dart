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
        MaterialPageRoute(
          builder: (_) => VideoScreen(
            videoId: searchResult.id!.videoId!,
          ),
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Image.network(
              searchResult.snippet!.thumbnails!.medium!.url!,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    child: Text(
                      searchResult.snippet!.title!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 8,),
                  Text(
                    searchResult.snippet!.channelTitle!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    Util.formatTimeago(searchResult.snippet!.publishedAt!),
                    style: TextStyle(color: Colors.grey),
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

/// video card for playlist
class VideoCardForPlaylist extends StatelessWidget {
  /// search result
  final PlaylistItem playlistItem;

  /// constructor
  VideoCardForPlaylist({required this.playlistItem});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoScreen(
            videoId: playlistItem.contentDetails!.videoId!,
          ),
        ),
      ),
      child: Container(
          height: 112,
          padding: const EdgeInsets.only(top: 8, right: 16, bottom: 8, left: 16),
          child: Row(
            children: <Widget>[
              playlistItem.snippet!.thumbnails!.medium != null
              ? Image(
                image: NetworkImage(
                  playlistItem.snippet!.thumbnails!.medium!.url!
                ),
              )
              : AspectRatio(
                aspectRatio: 320/180,
                child: Container(),
              ),
              SizedBox(width: 16,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        playlistItem.snippet!.title!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      Util.formatTimeago(playlistItem.contentDetails!.videoPublishedAt),
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
