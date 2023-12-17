import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_rental/main.dart';
import 'package:vehicle_rental/responsive/screen_layout.dart';
import 'package:vehicle_rental/utils/animation.dart';
import 'package:vehicle_rental/utils/colors.dart';
import 'package:vehicle_rental/utils/theme_provider.dart';

AppBar buildAppBar(BuildContext context, int currentPage) {
  return AppBar(
    title: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Rent',
          style: TextStyle(
            color: gray2,
            fontSize: 30,
            fontWeight: FontWeight.w900
          ),
        ),
        Text(
          'ALPHA',
          style: TextStyle(
            color: purple,
            fontSize: 30,
            fontWeight: FontWeight.w900
          ),
        ),
      ],
    ),
    elevation: 0,
    backgroundColor: Colors.transparent,
    leading: Consumer<ThemeProvider>(
      builder: (context, provider, child) {
        final isDarkMode = provider.currentTheme == 'dark';

        return IconButton(
          icon: isDarkMode 
            ? const Icon(
                Icons.dark_mode_sharp,
                color: blue,
              ) 
            : const Icon(
                Icons.light_mode_sharp,
                color: lightMode,
              ),
          onPressed: () {
            final newTheme = isDarkMode ? 'light' : 'dark';
            provider.changeTheme(newTheme);
          },
        );
      },
    ),
    actions: [
      Consumer<ThemeProvider>(
        builder: (context, provider, child) {
          final isDarkMode = provider.currentTheme == 'dark';

          return PopupMenuButton(
            icon: Icon(
              Icons.language,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onSelected: (value) {
              _changeLanguage(context, currentPage, value['languageCode'], value['countryCode']);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: {'languageCode': 'en', 'countryCode': 'US'},
                child: Row(
                  children: [
                    Text('🇺🇸'),
                    SizedBox(width: 8,),
                    Text('English'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: {'languageCode': 'id', 'countryCode': 'ID'},
                child: Row(
                  children: [
                    Text('🇮🇩'),
                    SizedBox(width: 8,),
                    Text('Bahasa Indonesia'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: {'languageCode': 'zh', 'countryCode': 'HK'},
                child: Row(
                  children: [
                    Text('🇨🇳'),
                    SizedBox(width: 8,),
                    Text('China'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: {'languageCode': 'ja', 'countryCode': 'JP'},
                child: Row(
                  children: [
                    Text('🇯🇵'),
                    SizedBox(width: 8,),
                    Text('Japan'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: {'languageCode': 'ko', 'countryCode': 'KR'},
                child: Row(
                  children: [
                    Text('🇰🇷'),
                    SizedBox(width: 8,),
                    Text('Korea'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: {'languageCode': 'es', 'countryCode': 'ES'},
                child: Row(
                  children: [
                    Text('🇪🇸'),
                    SizedBox(width: 8,),
                    Text('Espanyol'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: {'languageCode': 'fr', 'countryCode': 'FR'},
                child: Row(
                  children: [
                    Text('🇫🇷'),
                    SizedBox(width: 8,),
                    Text('France'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: {'languageCode': 'ru', 'countryCode': 'RU'},
                child: Row(
                  children: [
                    Text('🇷🇺'),
                    SizedBox(width: 8,),
                    Text('Rusia'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ],
  );
}

void _changeLanguage(BuildContext context, int currentPage, String? languageCode, String? countryCode) async {
  if (languageCode == null || countryCode == null) {
    return;
  }

  LocalJsonLocalization.delegate.load(Locale(languageCode, countryCode));

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('languageCode', languageCode);
  await prefs.setString('countryCode', countryCode);

  navigatorKey.currentState?.pushReplacement(NoAnimationPageRoute(builder: (context) => ScreenLayout(page: currentPage,)));
}