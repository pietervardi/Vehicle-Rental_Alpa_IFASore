import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  late BannerAd _bannerAd;
  bool _isBannerReady = false;

  bool isPremium = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.page);
    onPageChanged(widget.page);
    checkPremiumStatus();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  // Page Changed
  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  // Navigation Tapped
  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  // Load Banner Ads
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-3940256099942544/6300978111",
      listener: BannerAdListener(onAdLoaded: (_) {
        setState(() {
          _isBannerReady = true;
        });
      }, onAdFailedToLoad: (ad, err) {
        _isBannerReady = false;
        ad.dispose();
      }),
      request: const AdRequest());
    _bannerAd.load();
  }

  // Check Premium Status
  Future<void> checkPremiumStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool premiumStatus = prefs.getBool('subscriptionStatus') ?? false;
    if (premiumStatus == false) {
      _loadBannerAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: buildAppBar(context, _page),
        body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView(
                  controller: pageController,
                  onPageChanged: onPageChanged,
                  physics: const NeverScrollableScrollPhysics(),
                  children: homeScreenItems,
                ),
              ),
            ],
          ),
          if (_isBannerReady && _page != 2)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
            ),
        ],
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