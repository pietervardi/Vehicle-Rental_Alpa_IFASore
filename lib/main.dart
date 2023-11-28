import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_rental/utils/theme_provider.dart';
import 'package:vehicle_rental/screens/splash_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

int? isviewed;
void main() {
  // sqfliteFfiInit();
  // databaseFactory = databaseFactoryFfi;
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider()..initialize(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
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