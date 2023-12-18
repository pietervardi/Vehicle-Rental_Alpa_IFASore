import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:localization/localization.dart';
import 'package:vehicle_rental/responsive/screen_layout.dart';
import 'package:vehicle_rental/utils/animation.dart';
import 'package:vehicle_rental/utils/api_url.dart';
import 'package:vehicle_rental/utils/colors.dart';
import 'package:vehicle_rental/utils/message.dart';

class CarCard extends StatelessWidget {
  final int id;
  final String name;
  final String brand;
  final String image;
  final int price;
  final VoidCallback onPressed;

  const CarCard({
    Key? key,
    required this.id,
    required this.name,
    required this.brand,
    required this.image,
    required this.price,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // Format Rupiah
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp.');

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
          ScaffoldMessenger.of(context).showSnackBar(buildSnackBarSuccess('global/book-car'.i18n()));
        } else {
          throw Exception('global/failed-update'.i18n());
        }
      } catch (e) {
        rethrow;
      }
    }

    return GestureDetector(
      onTap: onPressed,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 25, right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Semantics(
                    label: 'semantics/global/car-name'.i18n(),
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        fontFamily: "arial"
                      ),
                    ),
                  ),
                  Semantics(
                    label: 'semantics/global/car-brand'.i18n(),
                    child: Text(
                      brand,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        color: gray,
                        fontSize: 18,
                        fontFamily: "arial"
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Semantics(
              label: 'semantics/global/car-image'.i18n(),
              child: Image.asset(
                image,
                width: 250,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 5, left: 25),
                  child: Semantics(
                    label: 'semantics/car_card/car-price'.i18n(),
                    child: Row(
                      children: [
                        Text(
                          currencyFormat.format(price),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: "arial"
                          ),
                        ),
                        const Text(
                          ' /day',
                          style: TextStyle(
                            fontSize: 13, 
                            fontFamily: "arial"
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Semantics(
                  onTapHint: 'semantics/global/book-button'.i18n(),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40, 
                        vertical: 15
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20),
                          topLeft: Radius.circular(35)
                        ),
                      ),
                    ),
                    onPressed: () {
                      updateBook(id);
                    },
                    child: Text(
                      'global/book-button'.i18n(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900, 
                        fontSize: 17
                      ),
                    )),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}