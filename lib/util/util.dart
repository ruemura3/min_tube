import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:min_tube/screens/channel_screen/channel_screen.dart';
import 'package:min_tube/screens/playlist_screen.dart';
import 'package:min_tube/screens/video_screen.dart';
import 'package:min_tube/util/color_util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// util
class Util {
  /// format view count
  static String formatViewCount(String viewCount) {
    int intViewCount = int.parse(viewCount);
    if (intViewCount < 10000) {
      return viewCount + ' 回視聴';
    } else if (intViewCount < 100000) {
      return ((intViewCount / 10000 * 10).floor() / 10).toString() + '万 回視聴';
    } else if (intViewCount < 100000000) {
      return (intViewCount / 10000).floor().toString() + '万 回視聴';
    } else {
      return (intViewCount / 100000000).floor().toString() + '億 回視聴';
    }
  }

  /// format subscriber count
  /// return null when private
  static String? formatSubScriberCount(String? subscriberCount) {
    if (subscriberCount != null) {
      int intSubscriberCount = int.parse(subscriberCount);
      if (intSubscriberCount < 10000) {
        return 'チャンネル登録者数 $subscriberCount 人';
      } else if (intSubscriberCount < 1000000) {
        return 'チャンネル登録者数 ${(intSubscriberCount / 10000).toString()} 万人';
      } else if (intSubscriberCount < 100000000) {
        return 'チャンネル登録者数 ${(intSubscriberCount / 10000).floor().toString()} 万人';
      } else {
        return 'チャンネル登録者数 ${(intSubscriberCount / 100000000).toString()} 億人';
      }
    }
    return null;
  }

  /// format timeago
  static String formatTimeago(DateTime date) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(date);
    int sec = difference.inSeconds;
    if (sec < 60) {
      return '$sec 秒前';
    } else if (sec < 3600) {
      return '${difference.inMinutes} 分前';
    } else if (sec < 86400) {
      return '${difference.inHours} 時間前';
    } else if (sec < 1209600) {
      return '${difference.inDays} 日前';
    } else if (sec < 3024000) {
      return '${(difference.inDays / 7).floor()} 週間前';
    } else {
      DateTime tmp = new DateTime(now.year - 1, now.month, now.day);
      if (tmp.isBefore(date)) {
        for (int month = 1; true; month++) {
          tmp = new DateTime(now.year, now.month - month, now.day);
          if (tmp.isBefore(date)) {
            return '${month - 1} か月前';
          }
        }
      } else {
        for (int year = 2; true; year++) {
          tmp = new DateTime(now.year - year, now.month, now.day);
          if (tmp.isBefore(date)) {
            return '${year - 1} 年前';
          }
        }
      }
    }
  }

  /// format view count and timeago
  static String viewsAndTimeago(String viewCount, DateTime timeago) {
    return '${Util.formatViewCount(viewCount)}・${Util.formatTimeago(timeago)}';
  }

  /// get description with url
  static RichText getDescriptionWithUrl(String description, BuildContext context) {
    final RegExp urlRegExp = RegExp(r"https?://[\w!\?/\+\-_~=;\.,\*&@#\$%\(\)'\[\]]+");
    final Iterable<RegExpMatch> urlMatches = urlRegExp.allMatches(description);
    String tmpMessage = description;
    List<TextSpan> textSpans = [];
    for (RegExpMatch urlMatch in urlMatches) {
      final String url = description.substring(urlMatch.start, urlMatch.end);
      var tmp = tmpMessage.split(url);
      textSpans.add(
        TextSpan(
          text: tmp[0],
          style: TextStyle(color: ColorUtil.textColor(context)),
        ),
      );
      textSpans.add(
        TextSpan(
          text: url.length > 37
          ? url.substring(0, 37) + '...'
          : url,
          style: TextStyle(color: Colors.lightBlue),
          recognizer: TapGestureRecognizer()..onTap = () {
            final videoId = convertUrlToVideoId(url);
            if (videoId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoScreen(
                    videoId: videoId,
                  ),
                ),
              );
              return;
            }
            final channelId = convertUrlToChannelId(url);
            if (channelId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChannelScreen(
                    channelId: channelId,
                  ),
                ),
              );
              return;
            }
            final playlistId = convertUrlToPlaylistId(url);
            if (playlistId != null) {
              print(playlistId);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlaylistScreen(
                    playlistId: playlistId,
                  ),
                ),
              );
              return;
            }
            launch(url);
          },
        ),
      );
      if (tmp.length > 1) {
        tmpMessage = tmp[1];
      }
    }
    textSpans.add(
      TextSpan(
        text: tmpMessage,
        style: TextStyle(color: ColorUtil.textColor(context)),
      ),
    );
    return RichText(
      text: TextSpan(
        children: textSpans,
      )
    );
  }

  /// convert youtube url to video id
  /// return null when url is not youtube video url
  static String? convertUrlToVideoId(String url,) {
    for (var exp in [
      RegExp(r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(r"^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(r"^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$")
    ]) {
      Match? match = exp.firstMatch(url);
      if (match != null && match.groupCount >= 1) return match.group(1);
    }
    return null;
  }

  /// convert youtube url to channel id
  /// return null when url is not youtube channel url
  static String? convertUrlToChannelId(String url,) {
    for (var exp in [
      RegExp(r"^https:\/\/(?:www\.|m\.)?youtube\.com\/channel\/([_\-a-zA-Z0-9]{24}).*$"),
    ]) {
      Match? match = exp.firstMatch(url);
      if (match != null && match.groupCount >= 1) return match.group(1);
    }
    return null;
  }

  /// convert youtube url to playlist\?list= id
  /// return null when url is not youtube playlist\?list= url
  static String? convertUrlToPlaylistId(String url,) {
    for (var exp in [
      RegExp(r"^https:\/\/(?:www\.|m\.)?youtube\.com\/playlist\?list=([_\-a-zA-Z0-9]{34}).*$"),
    ]) {
      Match? match = exp.firstMatch(url);
      if (match != null && match.groupCount >= 1) return match.group(1);
    }
    return null;
  }
}