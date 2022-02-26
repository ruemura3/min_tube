import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/screens/video_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

/// search result video card class
/// note that use only when kind: 'youtube#video'
class SearchResultVideoCard extends StatelessWidget {
  /// search result
  final SearchResult searchResult;

  /// constructor
  SearchResultVideoCard({required this.searchResult});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoScreen(videoId: searchResult.id!.videoId!,),
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
              'https://i.ytimg.com/vi/NihpPvvVt5k/mqdefault.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    searchResult.snippet!.title!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8,),
                  Text(
                    searchResult.snippet!.channelTitle!,
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    timeago.format(searchResult.snippet!.publishedAt!),
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