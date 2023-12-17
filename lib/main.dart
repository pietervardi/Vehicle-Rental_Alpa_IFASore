import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_rental/utils/theme_provider.dart';
import 'package:vehicle_rental/screens/splash_screen.dart';

int? isviewed;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedLanguageCode = prefs.getString('languageCode');
  String? savedCountryCode = prefs.getString('countryCode');

  runApp(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider()..initialize(),
      child: MyApp(
        savedLanguageCode: savedLanguageCode,
        savedCountryCode: savedCountryCode,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? savedLanguageCode;
  final String? savedCountryCode;
  const MyApp({Key? key, this.savedLanguageCode, this.savedCountryCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LocalJsonLocalization.delegate.directories = ['lib/i18n'];
    return Consumer<ThemeProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('id', 'ID'),
            Locale('zh', 'HK'),
            Locale('ja', 'JP'),
            Locale('ko', 'KR'),
            Locale('es', 'ES'),
            Locale('fr', 'FR'),
            Locale('ru', 'RU'),
          ],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            LocalJsonLocalization.delegate,
          ],
          locale: savedLanguageCode != null && savedCountryCode != null
            ? Locale(savedLanguageCode!, savedCountryCode!)
            : null,
          localeResolutionCallback: (locale, supportedLocales) {
            if (supportedLocales.contains(locale)) {
              return locale;
            }
            return const Locale('en', 'US');
          },
          scrollBehavior: MyCustomScrollBehavior(),
          debugShowCheckedModeBanner: false,
          title: 'Vehicle Rental App',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: provider.themeMode,
          home: const SplashScreen(),
        );
      }
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad
  };
}