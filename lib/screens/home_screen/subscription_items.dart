import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/channel_screen/channel_screen.dart';
import 'package:min_tube/widgets/video_card.dart';

/// subscription items
class SubscriptionItems extends StatefulWidget {
  /// subscription instance
  final Subscription subscription;

  /// constructor
  SubscriptionItems({required this.subscription});

  @override
  _SubscriptionItemsState createState() => _SubscriptionItemsState();
}

/// subscription items state
class _SubscriptionItemsState extends State<SubscriptionItems> {
  /// api service
  ApiService _api = ApiService.instance;
  ///  search result list
  List<SearchResult> _items = [];

  @override
  void initState() {
    super.initState();
    Future(() async {
      final response = await _api.getSearchResponse(
        channelId: widget.subscription.snippet!.resourceId!.channelId!,
        order: 'date',
      );
      if (mounted) {
        setState(() {
          _items = response.items!;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8,),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 16,),
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                  widget.subscription.snippet!.thumbnails!.medium!.url!
                ),
              ),
              SizedBox(width: 16,),
              Text(
                widget.subscription.snippet!.title!,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 8,),
          Container(
            height: MediaQuery.of(context).size.width*0.7,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _items.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == _items.length) {
                  return _watchMore();
                }
                return VideoCardForHome(searchResult: _items[index],);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _watchMore() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChannelScreen(
            channelId: widget.subscription.snippet!.resourceId!.channelId!,
            channelTitle: widget.subscription.snippet!.title!,
            tabPage: 1,
          ),
        ),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width*0.4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_forward_rounded),
            Text('もっと見る')
          ],
        ),
      )
    );
  }
}