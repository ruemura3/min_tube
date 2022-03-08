import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:min_tube/api/api_service.dart';
import 'package:min_tube/screens/home_screen.dart';
import 'package:min_tube/screens/login_screen.dart';

/// search bar
class SearchBar extends StatefulWidget with PreferredSizeWidget {
  /// app bar text
  final String? title;
  /// should show title
  final bool shouldShowTitle;
  /// tab bar
  final TabBar? tabBar;
  /// should show back button
  final bool shouldShowBack;

  /// constructor
  SearchBar({this.title, this.shouldShowTitle = true, this.tabBar, this.shouldShowBack = true});

  @override
  Size get preferredSize {
    if (tabBar != null) {
      return Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
    }
    return Size.fromHeight(kToolbarHeight);
  }

  @override
  _SearchBarState createState() => _SearchBarState();
}

/// search bar state
class _SearchBarState extends State<SearchBar> {
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

  _showUnsubscribeButton() {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          content: Text("ログアウトしますか？"),
          actions: <Widget>[
            TextButton(
              child: Text("キャンセル"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("ログアウト"),
              onPressed: () async {
                await _api.logout();
                if (mounted) {
                  setState(() {
                    _currentUser = null;
                  });
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(),
                  )
                );
              },
            ),
          ],
        );
      },
    );
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
    if (_currentUser != null) {
      return [
        InkWell(
          onTap: () => _showUnsubscribeButton(),
          child: _currentUser!.photoUrl != null
          ? CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(_currentUser!.photoUrl!)
          )
          : CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blueGrey,
            child: Text(_currentUser!.displayName!.substring(0, 1)),
          )
        ),
        SizedBox(width: 24,),
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
    return [];
  }
}