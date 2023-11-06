import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vehicle_rental/components/booked_card.dart';
import 'package:vehicle_rental/components/skeleton_loader.dart';
import 'package:vehicle_rental/models/car_model.dart';
import 'package:vehicle_rental/screens/book_detail_screen.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({Key? key}) : super(key: key);

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  List<Car> cars = [];

  // Get Data from API
  Future<List<Car>> fetchCarData() async {
    final response = await http.get(Uri.parse('http://localhost:5000/vehicles'));
    await Future.delayed(const Duration(seconds: 1));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Car> cars = data.map((json) => Car.fromJson(json)).toList();
      final bookedCars = cars.where((car) => car.book).toList();
      return bookedCars;
    } else {
      throw Exception('Failed to load car data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    ' Booked ',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Car',
                    style: TextStyle(
                      fontSize: 28,
                    ),
                  )
                ],
              ),
              FutureBuilder<List<Car>>(
                future: fetchCarData(),
                builder: (BuildContext context, AsyncSnapshot<List<Car>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildSkeletonLoader();
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Text('Error: ${snapshot.error}'),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: fetchCarData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  final List<Car> displayedCars = snapshot.data ?? [];

                  if (displayedCars.isEmpty) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height/1.5,
                      child: const Center(
                        child: Text(
                          'No Cars Booked',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var car in displayedCars)
                        Column(
                          children: [
                            BookedCard(
                              id: car.id,
                              name: car.name,
                              brand: car.brand,
                              image: car.image,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => BookDetailScreen(car: car),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Column(
      children: List.generate(5, (index) => const SkeletonLoader()),
    );
  }
}