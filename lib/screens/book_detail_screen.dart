import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_rental/responsive/screen_layout.dart';
import 'package:vehicle_rental/utils/animation.dart';
import 'package:vehicle_rental/utils/api_url.dart';
import 'package:vehicle_rental/utils/colors.dart';
import 'package:vehicle_rental/utils/message.dart';
import 'package:vehicle_rental/utils/theme_provider.dart';
import 'package:vehicle_rental/models/car_model.dart';

class BookDetailScreen extends StatelessWidget {
  final Car car;
  const BookDetailScreen({Key? key, required this.car}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // Update Data (patch)
    Future<void> updateBook(int vehicleId) async {
      final apiUrl = ApiUrl.updateVehicleUrl(vehicleId);
      try {
        final data = {'book': false, 'date': null};
        final jsonData = jsonEncode(data);
        final response = await http.patch(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonData,
        );
        if (response.statusCode == 200 && context.mounted) {
          Navigator.of(context).pushReplacement(NoAnimationPageRoute(
            builder: (context) => const ScreenLayout(page: 0),
          ));
          ScaffoldMessenger.of(context).showSnackBar(buildSnackBarDanger('Unbook Car'));
        } else {
          throw Exception('Failed to update');
        }
      } catch (e) {
        rethrow;
      }
    }

    // Format Date
    final dateFormat = DateFormat('dd MMMM y - HH:mm');
    // Pickup Date
    final pickupDate = dateFormat.parse(car.date ?? 'N/A');
    // Return Date
    final returnDate = dateFormat.format(pickupDate.add(const Duration(days: 1)));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Consumer<ThemeProvider>(
          builder: (context, provider, child) {
            final isDarkMode = provider.currentTheme == 'dark';

            return IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left_outlined,
                color: isDarkMode ? Colors.white : Colors.black,
                size: 28,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              car.name,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              car.brand,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 15),
            Image.asset(car.image),
            const SizedBox(height: 20),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PICKUP & RETURN',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: gray,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Pickup',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(car.date ?? 'N/A'),
                    const SizedBox(height: 20),
                    const Text(
                      'Return',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(returnDate),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30,),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: gray,
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                ),
                onPressed: () {
                  updateBook(car.id);
                },
                child: const Text(
                  'UNBOOK',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17
                  ),
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}