import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

AppOpenAd? appOpenAd;
loadAppOpenAd() {
  AppOpenAd.load(
    adUnitId: Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/9257395921'
      : 'ca-app-pub-3940256099942544/5575463023', 
    request: const AdRequest(), 
    adLoadCallback: AppOpenAdLoadCallback(
      onAdLoaded: (ad) {
        appOpenAd = ad;
        appOpenAd!.show();
      }, 
      onAdFailedToLoad: (err) {
        return;
      }
    ), 
    orientation: AppOpenAd.orientationPortrait
  );
}