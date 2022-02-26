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
      int intSubscriberCount = int.parse(subscriberCount!);
      if (intSubscriberCount < 10000) {
        return 'チャンネル登録者数 $subscriberCount 人';
      } else if (intSubscriberCount < 1000000) {
        return 'チャンネル登録者数 ${(intSubscriberCount / 10000).toString()} 万人';
      } else if (intSubscriberCount < 100000000) {
        return 'チャンネル登録者数 ${(intSubscriberCount / 10000).floor().toString()} 万人';
      } else {
        return 'チャンネル登録者数 ${(intSubscriberCount / 100000000).toString()} 億人';
      }
    } else {
      return null;
    }
  }
}
