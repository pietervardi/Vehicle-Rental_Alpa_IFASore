import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vehicle_rental/controllers/auth_controller.dart';
import 'package:vehicle_rental/responsive/screen_layout.dart';
import 'package:vehicle_rental/screens/login_screen.dart';

class DirectLogin extends StatefulWidget {
  const DirectLogin({Key? key}) : super(key: key);

  @override
  State<DirectLogin> createState() => _DirectLoginState();
}

class _DirectLoginState extends State<DirectLogin> {
  final AuthController _auth = AuthController();

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
