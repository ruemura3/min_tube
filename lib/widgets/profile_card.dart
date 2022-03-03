import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/screens/channel_screen/channel_screen.dart';
import 'package:min_tube/util/util.dart';

/// profile card for search result
/// use only when kind is 'youtube#channel'
class ProfileCardForSearchResult extends StatelessWidget {
  /// search result
  final SearchResult searchResult;

  /// constructor
  ProfileCardForSearchResult({required this.searchResult});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChannelScreen(
            channelId: searchResult.snippet!.channelId!,
            channelTitle: searchResult.snippet!.title!,
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(
                  searchResult.snippet!.thumbnails!.medium!.url!
                ),
              ),
              SizedBox(width: 16,),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      searchResult.snippet!.title!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// profile card for video screen
class ProfileCardForVideoScreen extends StatefulWidget {
  /// search query
  final Channel channel;

  /// constructor
  ProfileCardForVideoScreen({required this.channel});

  @override
  _ProfileCardForVideoScreenState createState() => _ProfileCardForVideoScreenState();
}

/// profile card for video screen state
class _ProfileCardForVideoScreenState extends State<ProfileCardForVideoScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height:112,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChannelScreen(
                      channel: widget.channel,
                      channelTitle: widget.channel.snippet!.title!,
                    ),
                  ),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(
                    widget.channel.snippet!.thumbnails!.medium!.url!
                  ),
                ),
              ),
              SizedBox(width: 16,),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.channel.snippet!.title!,
                      overflow: TextOverflow.ellipsis,
                    ),
                    widget.channel.statistics!.subscriberCount != null
                    ? Text(
                      Util.formatSubScriberCount(widget.channel.statistics!.subscriberCount)!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey,),
                    )
                    : Container(),
                    SizedBox(height: 8,),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'チャンネル登録',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// profile card for channel screen
class ProfileCardForChannelScreen extends StatefulWidget {
  /// search query
  final Channel channel;

  /// constructor
  ProfileCardForChannelScreen({required this.channel});

  @override
  _ProfileCardForChannelScreenState createState() => _ProfileCardForChannelScreenState();
}

/// profile card for channel screen state
class _ProfileCardForChannelScreenState extends State<ProfileCardForChannelScreen> {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.channel.brandingSettings!.image != null
          ? Image.network(
            widget.channel.brandingSettings!.image!.bannerExternalUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
          )
          : Container(),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 24, right: 16, bottom: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: NetworkImage(
                    widget.channel.snippet!.thumbnails!.medium!.url!
                  ),
                ),
                SizedBox(height: 16,),
                Text(
                  widget.channel.snippet!.title!,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8,),
                widget.channel.statistics!.subscriberCount != null
                ? Text(
                  Util.formatSubScriberCount(widget.channel.statistics!.subscriberCount)!,
                  style: TextStyle(color: Colors.grey),
                )
                : Container(),
                SizedBox(height: 16,),
                ElevatedButton(
                  onPressed: () {},

                  child: Text('チャンネル登録'),
                ),
                widget.channel.snippet!.description! != ''
                ? Column(
                  children: [
                    SizedBox(height: 8,),
                    Divider(color: Colors.grey,),
                    SizedBox(height: 8,),
                    Util.getDescriptionWithUrl(widget.channel.snippet!.description!,),
                  ]
                )
                : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// profile card for search result
/// use only when kind is 'youtube#channel'
class ProfileCardForHomeScreen extends StatelessWidget {
  /// search result
  final Subscription subscription;

  /// constructor
  ProfileCardForHomeScreen({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChannelScreen(
            channelId: subscription.snippet!.resourceId!.channelId!,
            channelTitle: subscription.snippet!.title!,
            tabPage: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                subscription.snippet!.thumbnails!.medium!.url!
              ),
            ),
            SizedBox(width: 16,),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    subscription.snippet!.title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                    ),
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