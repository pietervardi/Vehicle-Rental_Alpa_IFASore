import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:localization/localization.dart';
import 'package:vehicle_rental/utils/global_variable.dart';
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

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.page);
    onPageChanged(widget.page);
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: buildAppBar(context, _page),
        body: PageView(
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
          children: homeScreenItems,
        ),
        bottomNavigationBar: CupertinoTabBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Tooltip(
                message: 'screen_layout/tooltip/home'.i18n(),
                child: const Icon(
                  Icons.home_outlined,
                ),
              ),
            ),
            BottomNavigationBarItem(
              icon: Tooltip(
                message: 'screen_layout/tooltip/book'.i18n(),
                child: const Icon(
                  Icons.bookmark_outline,
                ),
              ),
            ),
            BottomNavigationBarItem(
              icon: Tooltip(
                message: 'screen_layout/tooltip/review'.i18n(),
                child: const Icon(
                  Icons.reviews_outlined,
                ),
              ),
            ),
            BottomNavigationBarItem(
              icon: Tooltip(
                message: 'screen_layout/tooltip/profile'.i18n(),
                child: const Icon(
                  Icons.person_outline,
                ),
              ),
            ),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
        ),
      ),
    );
  }
}