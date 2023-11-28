import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vehicle_rental/components/skeleton_loader.dart';
import 'package:vehicle_rental/models/car_model.dart';
import 'package:vehicle_rental/components/car_card.dart';
import 'package:vehicle_rental/screens/detail_screen.dart';
import 'package:vehicle_rental/utils/api_url.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Car> loadedCars = [];
  List<Car> cars = [];
  final StreamController<List<Car>> _carStreamController = StreamController<List<Car>>();
  int initialLoadCount = 5;
  int totalLoadedCount = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialCars();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _carStreamController.close();
    _scrollController.dispose();
    super.dispose();
  }

  // Load Car
  Future<void> _loadInitialCars() async {
    try {
      final List<Car> apiCars = await fetchCarData();
      cars = apiCars;

      await Future.delayed(const Duration(seconds: 1));

      if (totalLoadedCount < cars.length) {
        int endIndex = totalLoadedCount + initialLoadCount;
        endIndex = endIndex > cars.length ? cars.length : endIndex;
        loadedCars.addAll(cars.sublist(totalLoadedCount, endIndex));
        totalLoadedCount = endIndex;
        _carStreamController.add(loadedCars);
      }
    } catch (error) {
      _carStreamController.addError(error);
    }
  }

  // Get Data from API
  Future<List<Car>> fetchCarData() async {
    final response = await http.get(Uri.parse(ApiUrl.getVehiclesUrl()));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Car> cars = data.map((json) => Car.fromJson(json)).toList();
      final unbookedCars = cars.where((car) => !car.book).toList();
      return unbookedCars;
    } else {
      throw Exception('Failed to load car data');
    }
  }

  // Load More Car
  Future<void> _loadMoreCars() async {
    await Future.delayed(const Duration(seconds: 1));

    if (totalLoadedCount < cars.length) {
      int endIndex = totalLoadedCount + initialLoadCount;
      endIndex = endIndex > cars.length ? cars.length : endIndex;
      loadedCars.addAll(cars.sublist(totalLoadedCount, endIndex));
      totalLoadedCount = endIndex;
      _carStreamController.add(loadedCars);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreCars();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
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
                    ' Choose ',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'a Car',
                    style: TextStyle(
                      fontSize: 28,
                    ),
                  )
                ],
              ),
              StreamBuilder<List<Car>>(
                stream: _carStreamController.stream,
                initialData: const [],
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
                            onPressed: _loadInitialCars,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  final List<Car> displayedCars = snapshot.data ?? [];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var car in displayedCars)
                        Column(
                          children: [
                            CarCard(
                              id: car.id,
                              name: car.name,
                              brand: car.brand,
                              image: car.image,
                              price: car.price,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CarDetailScreen(car: car),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      if (totalLoadedCount < cars.length)
                        const Center(
                          child: CircularProgressIndicator(),
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

  // Load Skeleton
  Widget _buildSkeletonLoader() {
    return Column(
      children: List.generate(initialLoadCount, (index) => const SkeletonLoader()),
    );
  }
}