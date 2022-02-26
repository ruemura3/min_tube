import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/util/util.dart';

/// search result screen
class ProfileCardForVideoScreen extends StatefulWidget {
  /// search query
  final Channel channel;

  /// constructor
  ProfileCardForVideoScreen({required this.channel});

  @override
  _ProfileCardForVideoScreenState createState() => _ProfileCardForVideoScreenState();
}

/// search result screen state class
class _ProfileCardForVideoScreenState extends State<ProfileCardForVideoScreen> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onTap: () => Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => ChannelScreen(channelId: ,),
      //   ),
      // ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(widget.channel.snippet!.thumbnails!.medium!.url!),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 16, left: 16),
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
}