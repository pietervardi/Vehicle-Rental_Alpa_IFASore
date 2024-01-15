import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_rental/screens/premium_screen.dart';
import 'package:vehicle_rental/utils/theme_provider.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('PremiumScreen Widget Tests', () {
    testWidgets('PremiumScreen should show purchase button when not premium', (WidgetTester tester) async {
      final MockSharedPreferences mockSharedPreferences = MockSharedPreferences();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>(
              create: (_) => ThemeProvider(),
            ),
            Provider<SharedPreferences>(
              create: (_) => mockSharedPreferences,
            ),
          ],
          child: const MaterialApp(
            home: PremiumScreen(),
          ),
        ),
      );

      expect(find.byType(IconButton), findsOneWidget);
      expect(find.text('ALL LOCATIONS'), findsOneWidget);
      expect(find.text('Connect through any of our locations all over the world for unparalleled anonymity.'), findsOneWidget);
      expect(find.text('TOP SPEED'), findsOneWidget);
      expect(find.text('Don\'t let safety in the way of enjoying app content at the highest level of quality.'), findsOneWidget);
      expect(find.text('NO ADS'), findsOneWidget);
      expect(find.text('Get rid of all those banners and videos when you open the app.'), findsOneWidget);
      expect(find.text('Rp.240.000,00 / month'), findsOneWidget);
    });
  });
}