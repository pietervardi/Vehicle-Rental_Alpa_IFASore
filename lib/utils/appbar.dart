import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_rental/utils/colors.dart';
import 'package:vehicle_rental/utils/theme_provider.dart';

AppBar buildAppBar(BuildContext context) {
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

          return IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search_outlined,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          );
        },
      ),
    ],
  );
}