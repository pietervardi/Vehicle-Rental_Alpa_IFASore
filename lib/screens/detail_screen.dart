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

class CarDetailScreen extends StatelessWidget {
  final Car car;
  const CarDetailScreen({Key? key, required this.car}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // Update Data (patch)
    Future<void> updateBook(int vehicleId) async {
      final apiUrl = ApiUrl.updateVehicleUrl(vehicleId);
      try {
        final now = DateTime.now();
        final formattedDate = DateFormat('dd MMMM y - HH:mm').format(now);
        final data = {
          'book': true,
          'date': formattedDate,
        };
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
            builder: (context) => const ScreenLayout(page: 1),
          ));
          ScaffoldMessenger.of(context).showSnackBar(buildSnackBarSuccess('Book Car'));
        } else {
          throw Exception('Failed to update');
        }
      } catch (e) {
        rethrow;
      }
    }
    
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
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'SPECIFICATIONS',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: gray
                ),
              ),
            ),
            Container(
              height: 120,
              padding: const EdgeInsets.only(top: 8),
              margin: const EdgeInsets.only(top: 10),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: [
                  buildSpecificationCar(Icons.color_lens_outlined, 'Color', car.color),
                  buildSpecificationCar(Icons.directions_car_outlined, 'Gearbox', car.gearbox),
                  buildSpecificationCar(Icons.people_outlined, 'Seat', '( 1 - ${car.seat} )'),
                  buildSpecificationCar(Icons.local_gas_station_outlined, 'Fuel', car.fuel),
                  buildSpecificationCar(Icons.speed_outlined, 'Power', '${car.power} hp'),
                ],
              ),
            ),
            const SizedBox(height: 50,),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                ),
                onPressed: () {
                  updateBook(car.id);
                },
                child: const Text(
                  'BOOK',
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

  Widget buildSpecificationCar(IconData icon, String title, String data) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(right: 15),
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(
              icon,
              size: 40,
              color: purple2,
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            Text(
              data,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}