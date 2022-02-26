import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/screens/channel_screen.dart';
import 'package:min_tube/util/util.dart';

/// search result screen
class ProfileCard extends StatefulWidget {
  /// search query
  final Channel channel;

  /// constructor
  ProfileCard({required this.channel});

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

/// search result screen state class
class _ProfileCardState extends State<ProfileCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChannelScreen(channel: widget.channel,),
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {

                },
                child: Row(
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