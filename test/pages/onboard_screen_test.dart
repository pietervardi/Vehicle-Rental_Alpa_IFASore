import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_rental/screens/onboard_screen.dart';

void main() {
  group('OnBoardScreen Widget Test', () {
    testWidgets('OnBoardScreen render successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: OnBoardScreen(),
      ));

      expect(find.byType(OnBoardScreen), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Rent Your Adventure Today'), findsOneWidget);
      expect(find.text('Experience the thrill of the open road with our user-friendly vehicle rental app, making it easy to find the perfect ride for your next adventure.'), findsOneWidget);
    });

    testWidgets('Navigate through all OnboardScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: OnBoardScreen(),
      ));

      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.text('Skip'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Drive Your Dreams'), findsOneWidget);
      expect(find.text('Turn dreams into reality with our app\'s wide range of vehicles. Create unforgettable memories as you get behind the wheel.'), findsOneWidget);

      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.text('Skip'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Journey with Confidence'), findsOneWidget);
      expect(find.text('Explore the world with peace of mind using our app, known for its unwavering commitment to safety and quality, ensuring worry-free journeys.'), findsOneWidget);
      expect(find.text('GET STARTED'), findsOneWidget);
    });
  });
}