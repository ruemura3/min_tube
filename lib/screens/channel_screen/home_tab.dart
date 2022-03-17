import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube/widgets/profile_card.dart';

/// channel home tab
class HomeTab extends StatelessWidget {
  /// channel instance
  final Channel channel;
  /// is mine
  final bool isMine;

  /// constructor
  HomeTab({required this.channel, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ProfileCardForChannelScreen(channel: channel, isMine: isMine),
    );
  }
}