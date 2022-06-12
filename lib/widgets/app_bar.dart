import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/home_screen.dart';
import 'package:min_tube/screens/my_screen.dart';

/// search bar
class OriginalAppBar extends StatefulWidget with PreferredSizeWidget {
  /// app bar text
  final String? title;
  /// should show title
  final bool shouldShowTitle;
  /// should show home button
  final bool shouldShowProfileButton;
  /// tab bar
  final TabBar? tabBar;
  /// should show back button
  final bool shouldShowBack;

  /// constructor
  OriginalAppBar({
    this.title,
    this.shouldShowTitle = true,
    this.shouldShowProfileButton = true,
    this.tabBar,
    this.shouldShowBack = true
  });

  @override
  Size get preferredSize {
    if (tabBar != null) {
      return Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
    }
    return Size.fromHeight(kToolbarHeight);
  }

  @override
  _OriginalAppBarState createState() => _OriginalAppBarState();
}

/// search bar state
class _OriginalAppBarState extends State<OriginalAppBar> {
  /// api service
  ApiService _api = ApiService.instance;
  /// current user
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    Future(() async {
      final user = await _api.user;
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: _appBarTitle(),
      automaticallyImplyLeading: widget.shouldShowBack,
      actions: _appBarActions(),
      bottom: widget.tabBar,
    );
  }

  /// app bar title
  Widget _appBarTitle() {
    if (!widget.shouldShowTitle) {
      return Container();
    }
    if (widget.title != null) {
      return Text(
        widget.title!,
        style: TextStyle(
          fontSize: 18,
        ),
      );
    }
    return InkWell(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(),
        )
      ),
      child: Image.asset(
        Theme.of(context).brightness == Brightness.dark
        ? 'assets/images/logo_dark.png'
        : 'assets/images/logo_light.png',
        width: 120,
      ),
    );
  }

  /// profile Icon
  List<Widget> _appBarActions() {
    if (widget.shouldShowProfileButton) {
      if (_currentUser != null) {
        return [
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MyScreen(),
              ),
            ),
            child: _currentUser!.photoUrl != null
            ? CircleAvatar(
              backgroundImage: NetworkImage(_currentUser!.photoUrl!)
            )
            : CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Text(_currentUser!.displayName!.substring(0, 1)),
            )
          ),
          SizedBox(width: 16,),
        ];
      }
      Future(() async {
        final user = await _api.user;
        if (mounted) {
          setState(() {
            _currentUser = user;
          });
        }
      });
    }
    return [];
  }
}