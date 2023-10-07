import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vehicle_rental/utils/data.dart';
import 'package:vehicle_rental/models/car_model.dart';
import 'package:vehicle_rental/components/car_card.dart';
import 'package:vehicle_rental/screens/detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Car> loadedCars = [];
  List<Car> cars = getCarList();
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

  Future<void> _loadInitialCars() async {
    await Future.delayed(const Duration(seconds: 2));

    if (totalLoadedCount < cars.length) {
      int endIndex = totalLoadedCount + initialLoadCount;
      endIndex = endIndex > cars.length ? cars.length : endIndex;
      loadedCars.addAll(cars.sublist(totalLoadedCount, endIndex));
      totalLoadedCount = endIndex;
      _carStreamController.add(loadedCars);
    }
  }

  Future<void> _loadMoreCars() async {
    await Future.delayed(const Duration(seconds: 2));

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
                  SizedBox(height: 50,),
                  Text(
                    ' Choose ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold
                    ),
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
                    return _buildSkeletonLoader(context);
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
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

  Widget _buildSkeletonLoader(BuildContext context) {
    return Column(
      children: List.generate(
        initialLoadCount, (index) =>  skeletonLoader(context)
      ),
    );
  }

  Widget skeletonLoader(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;

    Color baseColor;
    Color highlightColor;

    if (brightness == Brightness.dark) {
      baseColor = Colors.white.withOpacity(0.1);
      highlightColor = Colors.white.withOpacity(0.05);
    } else {
      baseColor = Colors.grey.shade300;
      highlightColor = Colors.grey.shade100;
    }

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}