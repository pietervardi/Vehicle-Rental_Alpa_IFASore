import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_rental/controllers/auth_controller.dart';
import 'package:vehicle_rental/responsive/screen_layout.dart';
import 'package:vehicle_rental/screens/login_screen.dart';
import 'package:vehicle_rental/utils/load_app_open_ad.dart';

class DirectLogin extends StatefulWidget {
  const DirectLogin({Key? key}) : super(key: key);

  @override
  State<DirectLogin> createState() => _DirectLoginState();
}

class _DirectLoginState extends State<DirectLogin> {
  final AuthController _auth = AuthController();

  @override
  void initState() {
    super.initState();
    checkPremiumStatus();
  }

  // Check Premium Status
  Future<void> checkPremiumStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool premiumStatus = prefs.getBool('subscriptionStatus') ?? false;
    if (premiumStatus == false) {
      loadAppOpenAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _auth.getUser(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(backgroundColor: Colors.white,);
        } 
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } 
        // Check if the user is logged in or not
        if (snapshot.data != null) {
          return const ScreenLayout();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}