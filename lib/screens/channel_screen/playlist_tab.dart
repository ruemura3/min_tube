import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';

/// playlist tab
class PlaylistTab extends StatefulWidget {
  /// channel instance
  final Channel? channel;

  PlaylistTab({this.channel});

  @override
  _PlaylistTabState createState() => _PlaylistTabState();
}

class _PlaylistTabState extends State<PlaylistTab> {
  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.blue,
    );
  }
}