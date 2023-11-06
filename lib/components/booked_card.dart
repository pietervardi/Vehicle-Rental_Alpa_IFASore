import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vehicle_rental/responsive/screen_layout.dart';
import 'package:vehicle_rental/utils/animation.dart';
import 'package:vehicle_rental/utils/colors.dart';
import 'package:vehicle_rental/utils/message.dart';

class BookedCard extends StatelessWidget {
  final int id;
  final String name;
  final String brand;
  final String image;
  final VoidCallback onPressed;

  const BookedCard({
    Key? key,
    required this.id,
    required this.name,
    required this.brand,
    required this.image,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // Update Data (patch)
    Future<void> updateBook(int vehicleId) async {
      final apiUrl = 'http://localhost:5000/vehicles/$vehicleId';
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
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontFamily: "arial"
                    ),
                  ),
                  Text(
                    brand,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      color: gray,
                      fontSize: 18,
                      fontFamily: "arial"
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 5,),
            Image.asset(
              image,
              width: 250,
            ),
            const SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gray,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20)
                        ),
                      ),
                    ),
                    onPressed: () {
                      updateBook(id);
                    },
                    child: const Text(
                      'UNBOOK',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17
                      ),
                    )
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}