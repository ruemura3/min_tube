import 'package:flutter/material.dart';
import 'package:min_tube/widgets/app_bar.dart';

class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OriginalAppBar(
        shouldShowBack: false,
        shouldShowProfileButton: false,
      ),
      body: Center(
        child: Text('YouTubeとの通信でエラーが起きました'),
      ),
    );
  }
}