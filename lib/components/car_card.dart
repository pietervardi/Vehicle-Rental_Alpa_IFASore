import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vehicle_rental/utils/colors.dart';

class CarCard extends StatelessWidget {
  final String name;
  final String brand;
  final String image;
  final int price;
  final VoidCallback onPressed;

  const CarCard({
    Key? key,
    required this.name,
    required this.brand,
    required this.image,
    required this.price,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp.');

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
            const SizedBox(height: 10,),
            Image.asset(
              image,
              width: 250,
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 5, left: 25),
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(20),
                        topLeft: Radius.circular(35)
                      ),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Book',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17
                    ),
                  )
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}