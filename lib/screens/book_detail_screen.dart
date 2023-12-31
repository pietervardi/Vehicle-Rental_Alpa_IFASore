import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(buildSnackBarDanger('global/unbook-car'.i18n()));
        } else {
          throw Exception('global/failed-update'.i18n());
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

            return Semantics(
              onTapHint: 'semantics/global/back-button'.i18n(),
              child: Tooltip(
                message: 'screen_layout/tooltip/back'.i18n(),
                child: IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_left_outlined,
                    color: isDarkMode ? Colors.white : Colors.black,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: 'semantics/global/car-name'.i18n(),
              child: Text(
                car.name,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Semantics(
              label: 'semantics/global/car-brand'.i18n(),
              child: Text(
                car.brand,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Semantics(
              onTapHint: 'semantics/global/car-image'.i18n(),
              child: Image.asset(car.image)
            ),
            const SizedBox(height: 20),
            Semantics(
              label: 'semantics/book_detail_screen/pickup-return-information'.i18n(),
              child: Card(
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
                      Semantics(
                        label: 'semantics/book_detail_screen/pickup-return-title'.i18n(),
                        child: Text(
                          'book_detail_screen/pickup-return'.i18n(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: gray,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Semantics(
                        label: 'semantics/book_detail_screen/pickup-title'.i18n(),
                        child: Text(
                          'book_detail_screen/pickup'.i18n(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Semantics(
                        label: 'semantics/book_detail_screen/pickup-date'.i18n(),
                        child: Text(car.date ?? 'N/A')
                      ),
                      const SizedBox(height: 20),
                      Semantics(
                        label: 'semantics/book_detail_screen/return-title'.i18n(),
                        child: Text(
                          'book_detail_screen/return'.i18n(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Semantics(
                        label: 'semantics/book_detail_screen/return-date'.i18n(),
                        child: Text(returnDate)
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30,),
            Semantics(
              onTapHint: 'semantics/global/unbook-button'.i18n(),
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gray,
                    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                  ),
                  onPressed: () {
                    updateBook(car.id);
                  },
                  child: Text(
                    'global/unbook-button'.i18n(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17
                    ),
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}