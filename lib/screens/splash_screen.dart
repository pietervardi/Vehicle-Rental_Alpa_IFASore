import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_rental/responsive/screen_layout.dart';
import 'package:vehicle_rental/screens/onboard_screen.dart';
import 'package:vehicle_rental/utils/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startDelay();
  }

  _startDelay() async {
    await Future.delayed(const Duration(milliseconds: 3000), () {
      _checkFirstTimeOpen();
    });
  }

  _checkFirstTimeOpen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? isViewed = prefs.getInt('onBoard');
    
    Widget nextScreen;

    if (isViewed == null || isViewed == 0) {
      nextScreen = const OnBoardScreen();
    } else {
      nextScreen = const ScreenLayout();
    }

    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) => nextScreen,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteText,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Rent',
                    style: TextStyle(
                      color: gray2,
                      fontSize: 50,
                      fontWeight: FontWeight.w900
                    ),
                  ),
                  Text(
                    'ALPHA',
                    style: TextStyle(
                      color: purple,
                      fontSize: 50,
                      fontWeight: FontWeight.w900
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Text(
                'Drive Your Journey Forward',
                style: TextStyle(
                  color: gray,
                  fontSize: 18,
                  fontWeight: FontWeight.w400
                ),
              )
            ],
          ),
          Image.asset(
            'assets/car/aventador.png',
            width: 300,
          )
        ],
      ),
    );
  }
}