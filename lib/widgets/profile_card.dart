import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/channel_screen/channel_screen.dart';
import 'package:min_tube/util/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// profile card for video screen
class ProfileCardForVideoScreen extends StatelessWidget {
  /// channel instance
  final Channel channel;

  /// constructor
  ProfileCardForVideoScreen({required this.channel});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChannelScreen(
              channel: channel,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  channel.snippet!.thumbnails!.medium!.url!
                ),
              ),
              SizedBox(width: 8,),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      channel.snippet!.title!,
                      overflow: TextOverflow.ellipsis,
                    ),
                    channel.statistics!.subscriberCount != null
                    ? Text(
                      Util.formatSubScriberCount(channel.statistics!.subscriberCount)!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13
                      ),
                    )
                    : Container(),
                  ],
                ),
              ),
              SubscribeButton(channel: channel,),
            ],
          ),
        ),
      ),
    );
  }
}

class SubscribeButton extends StatefulWidget {
  /// channel instance
  final Channel channel;

  /// constructor
  SubscribeButton({required this.channel});

  @override
  _SubscribeButtonState createState() => _SubscribeButtonState();
}

class _SubscribeButtonState extends State<SubscribeButton> {
  /// api service
  ApiService _api = ApiService.instance;
  /// is subscribed
  bool _isSubscribed = false;
  /// subscription
  Subscription? _subscription;
  /// is button enabled
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    Future(() async {
      final response = await _api.getSubscriptionResponse(forChannelId: widget.channel.id!);
      if (mounted) {
        setState(() {
          _isSubscribed = response.items!.length != 0;
          if (_isSubscribed) {
            _subscription = response.items![0];
          }
          _isEnabled = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _button();
  }

  Widget _button() {
    if (_isSubscribed) {
      return TextButton(
        onPressed: _isEnabled
        ? () => _showUnsubscribeButton()
        : null,
        style:  ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          minimumSize: MaterialStateProperty.all(Size.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          '登録済み',
          style: TextStyle(color: Colors.grey,),
        ),
      );
    } else {
      return TextButton(
        onPressed: _isEnabled
        ? () {
          setState(() {
            _isEnabled = false;
          });
          Future(() async {
            final response = await _api.insertSubscription(channel: widget.channel);
            if (mounted) {
              setState(() {
                _isSubscribed = true;
                _subscription = response;
                _isEnabled = true;
              });
            }
          });
        }
        : null,
        style:  ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          minimumSize: MaterialStateProperty.all(Size.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'チャンネル登録',
          style: TextStyle(
            color: Colors.red,
            fontSize: 13
          ),
        ),
      );
    }
  }

  _showUnsubscribeButton() {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          content: Text("${widget.channel.snippet!.title} のチャンネル登録を解除しますか？"),
          actions: <Widget>[
            TextButton(
              child: Text("キャンセル"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("登録解除"),
              onPressed: () {
                setState(() {
                  _isEnabled = false;
                });
                Future(() async {
                  await _api.deleteSubscription(subscription: _subscription!);
                  if (mounted) {
                    setState(() {
                      _isSubscribed = false;
                      _subscription = null;
                      _isEnabled = true;
                    });
                  }
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

class FavoriteButton extends StatefulWidget {
  /// subscription
  final String channelId;

  FavoriteButton({required this.channelId});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  /// is in favorites
  bool _isInFavorites = false;
  /// is button enabled
  bool _isEnabled = false;
  /// favorite ids
  List<String> _favoriteIds = [];
  late SharedPreferences _preferences;

  @override
  void initState() {
    super.initState();
    Future(() async {
      _preferences = await SharedPreferences.getInstance();
      _setFavoriteIdList();
      final id = _favoriteIds.firstWhere(
        (id) => id == widget.channelId,
        orElse: () => '',
      );
      setState(() {
        if (id != '') {
          _isInFavorites = true;
        }
      });
      _isEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _isEnabled
      ? () {
        setState(() {
          _isEnabled = false;
        });
        _onFavoriteButtonPressed();
      }
      : null,
      icon: _isInFavorites
      ? Icon(Icons.star)
      : Icon(Icons.star_border),
    );
  }

  void _setFavoriteIdList() {
    final favoriteIds = _preferences.getStringList('favorites');
    if (favoriteIds != null) {
      _favoriteIds = favoriteIds;
    }
  }

  Future<void> _onFavoriteButtonPressed() async {
    _setFavoriteIdList();
    if (_isInFavorites) {
      _favoriteIds.remove(widget.channelId);
      _preferences.setStringList('favorites', _favoriteIds);
      if (mounted) {
        setState(() {
          _isInFavorites = false;
          _isEnabled = true;
        });
      }
    } else {
      _favoriteIds.add(widget.channelId);
      _preferences.setStringList('favorites', _favoriteIds);
      if (mounted) {
        setState(() {
          _isInFavorites = true;
          _isEnabled = true;
        });
      }
    }
  }
}