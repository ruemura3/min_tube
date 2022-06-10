import 'package:flutter/material.dart';
import 'package:min_tube/screens/home_screen.dart';

/// search bar
class OriginalAppBar extends StatelessWidget with PreferredSizeWidget {
  /// app bar text
  final String? title;
  /// should show title
  final bool shouldShowTitle;
  /// should show home button
  final bool shouldShowHomeButton;
  /// tab bar
  final TabBar? tabBar;
  /// should show back button
  final bool shouldShowBack;

  /// constructor
  OriginalAppBar({
    this.title,
    this.shouldShowTitle = true,
    this.shouldShowHomeButton = true,
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
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: _appBarTitle(context),
      automaticallyImplyLeading: shouldShowBack,
      actions: _appBarActions(context),
      bottom: tabBar,
    );
  }

  /// app bar title
  Widget _appBarTitle(BuildContext context) {
    if (!shouldShowTitle) {
      return Container();
    }
    if (title != null) {
      return Text(
        title!,
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
        ),
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
  List<Widget> _appBarActions(BuildContext context) {
    if (!shouldShowHomeButton) {
      return [Container()];
    }
    return [
      IconButton(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(),
          ),
        ),
        icon: Icon(Icons.home)
      ),
      SizedBox(width: 16,),
    ];
  }
}
