import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_rental/database/database_helper.dart';
import 'package:vehicle_rental/models/user_model.dart';
import 'package:vehicle_rental/screens/book_screen.dart';
import 'package:vehicle_rental/screens/home_screen.dart';
import 'package:vehicle_rental/screens/notification_screen.dart';
import 'package:vehicle_rental/screens/profile_screen.dart';
import 'package:vehicle_rental/utils/appbar.dart';

class ScreenLayout extends StatefulWidget {
  final int page;

  const ScreenLayout({Key? key, this.page = 0}) : super(key: key);

  @override
  State<ScreenLayout> createState() => _ScreenLayoutState();
}

class _ScreenLayoutState extends State<ScreenLayout> {
  int _page = 0;
  late PageController pageController;
  final db = DatabaseHelper();
  UserModel? loggedInUser;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.page);
    onPageChanged(widget.page);
    loadUserFromDatabase();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  Future<void> loadUserFromDatabase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      UserModel? user = await db.getLoginUser(email);
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const HomeScreen(),
          const BookScreen(),
          const NotificationScreen(),
          ProfileScreen(user: loggedInUser)
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Tooltip(
              message: 'Home',
              child: Icon(
                Icons.home_outlined,
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Tooltip(
              message: 'Book',
              child: Icon(
                Icons.bookmark_outline,
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Tooltip(
              message: 'Notification',
              child: Icon(
                Icons.notifications_outlined,
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Tooltip(
              message: 'Profile',
              child: Icon(
                Icons.person_outline,
              ),
            ),
          ),
        ],
        onTap: navigationTapped,
        currentIndex: _page,
      ),
    );
  }
}
