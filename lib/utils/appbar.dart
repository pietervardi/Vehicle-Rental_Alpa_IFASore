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

        return Tooltip(
          message: 'screen_layout/tooltip/theme'.i18n(),
          child: Semantics(
            hint: isDarkMode
              ? 'semantics/appbar/light-mode'.i18n()
              : 'semantics/appbar/dark-mode'.i18n(),
            child: IconButton(
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
            ),
          ),
        );
      },
    ),
    actions: [
      Consumer<ThemeProvider>(
        builder: (context, provider, child) {
          final isDarkMode = provider.currentTheme == 'dark';

          return Tooltip(
            message: 'screen_layout/tooltip/language'.i18n(),
            child: Semantics(
              onTapHint: 'semantics/appbar/language'.i18n(),
              child: PopupMenuButton(
                icon: Icon(
                  Icons.language,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                onSelected: (value) {
                  _changeLanguage(context, currentPage, value['languageCode'], value['countryCode']);
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: const {'languageCode': 'en', 'countryCode': 'US'},
                    child: Semantics(
                      onTapHint: 'semantics/appbar/english'.i18n(),
                      child: const Row(
                        children: [
                          Text('🇺🇸'),
                          SizedBox(width: 8,),
                          Text('English'),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: const {'languageCode': 'id', 'countryCode': 'ID'},
                    child: Semantics(
                      onTapHint: 'semantics/appbar/bahasa-indonesia'.i18n(),
                      child: const Row(
                        children: [
                          Text('🇮🇩'),
                          SizedBox(width: 8,),
                          Text('Bahasa Indonesia'),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: const {'languageCode': 'zh', 'countryCode': 'CN'},
                    child: Semantics(
                      onTapHint: 'semantics/appbar/mandarin'.i18n(),
                      child: const Row(
                        children: [
                          Text('🇨🇳'),
                          SizedBox(width: 8,),
                          Text('Mandarin'),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: const {'languageCode': 'ja', 'countryCode': 'JP'},
                    child: Semantics(
                      onTapHint: 'semantics/appbar/japanese'.i18n(),
                      child: const Row(
                        children: [
                          Text('🇯🇵'),
                          SizedBox(width: 8,),
                          Text('Japanese'),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: const {'languageCode': 'ko', 'countryCode': 'KR'},
                    child: Semantics(
                      onTapHint: 'semantics/appbar/korean'.i18n(),
                      child: const Row(
                        children: [
                          Text('🇰🇷'),
                          SizedBox(width: 8,),
                          Text('Korean'),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: const {'languageCode': 'es', 'countryCode': 'ES'},
                    child: Semantics(
                      onTapHint: 'semantics/appbar/espanyol'.i18n(),
                      child: const Row(
                        children: [
                          Text('🇪🇸'),
                          SizedBox(width: 8,),
                          Text('Espanyol'),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: const {'languageCode': 'fr', 'countryCode': 'FR'},
                    child: Semantics(
                      onTapHint: 'semantics/appbar/french'.i18n(),
                      child: const Row(
                        children: [
                          Text('🇫🇷'),
                          SizedBox(width: 8,),
                          Text('French'),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: const {'languageCode': 'ru', 'countryCode': 'RU'},
                    child: Semantics(
                      onTapHint: 'semantics/appbar/russian'.i18n(),
                      child: const Row(
                        children: [
                          Text('🇷🇺'),
                          SizedBox(width: 8,),
                          Text('Russian'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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