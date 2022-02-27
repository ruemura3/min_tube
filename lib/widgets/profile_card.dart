import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/screens/channel_screen.dart';
import 'package:min_tube/util/util.dart';

/// profile card for search result class
/// use only when kind is 'youtube#channel'
class ProfileCardForSearchResult extends StatefulWidget {
  /// search result
  final SearchResult searchResult;

  /// constructor
  ProfileCardForSearchResult({required this.searchResult});

  @override
  _ProfileCardForSearchResultState createState() => _ProfileCardForSearchResultState();
}

/// profile card for search result state class
class _ProfileCardForSearchResultState extends State<ProfileCardForSearchResult> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChannelScreen(
            channelId: widget.searchResult.snippet!.channelId!,
            channelTitle: widget.searchResult.snippet!.title!,
          ),
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(widget.searchResult.snippet!.thumbnails!.medium!.url!),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 16, left: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.searchResult.snippet!.title!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      // _subscriber(widget.searchResult.statistics!.subscriberCount),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// profile card for video screen class
class ProfileCardForVideoScreen extends StatefulWidget {
  /// search query
  final Channel channel;

  /// constructor
  ProfileCardForVideoScreen({required this.channel});

  @override
  _ProfileCardForVideoScreenState createState() => _ProfileCardForVideoScreenState();
}

/// profile card for video screen state class
class _ProfileCardForVideoScreenState extends State<ProfileCardForVideoScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChannelScreen(
              channel: widget.channel,
              channelTitle: widget.channel.snippet!.title!,
            ),
          ),
        ),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(widget.channel.snippet!.thumbnails!.medium!.url!),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.channel.snippet!.title!,
                          overflow: TextOverflow.ellipsis,
                        ),
                        _subscriber(widget.channel.statistics!.subscriberCount),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// profile card for channel screen class
class ProfileCardForChannelScreen extends StatefulWidget {
  /// search query
  final Channel channel;

  /// constructor
  ProfileCardForChannelScreen({required this.channel});

  @override
  _ProfileCardForChannelScreenState createState() => _ProfileCardForChannelScreenState();
}

/// profile card for channel screen state class
class _ProfileCardForChannelScreenState extends State<ProfileCardForChannelScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(widget.channel.snippet!.thumbnails!.medium!.url!),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.channel.snippet!.title!,
                        overflow: TextOverflow.ellipsis,
                      ),
                      _subscriber(widget.channel.statistics!.subscriberCount),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// subscriber count
/// return empty container when private
Widget _subscriber(String? subscriberCount) {
  String? formattedSubscriberCount = Util.formatSubScriberCount(subscriberCount);
  if (formattedSubscriberCount != null) {
    return Text(
    formattedSubscriberCount,
      style: TextStyle(
        color: Colors.grey,
        fontSize: 13,
        fontWeight: FontWeight.w300,
      )
    );
  } else {
    return Container();
  }
}

