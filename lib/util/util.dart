import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:min_tube/util/color_util.dart';
import 'package:url_launcher/url_launcher.dart';

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
    } else if (sec < 604800) {
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
    final RegExp urlRegExp = RegExp(
      r'((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?'
    );
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
          text: url.length > 30
          ? url.substring(0, 30) + '...'
          : url,
          style: TextStyle(color: Colors.lightBlue),
          recognizer: TapGestureRecognizer()..onTap = () {
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
}
