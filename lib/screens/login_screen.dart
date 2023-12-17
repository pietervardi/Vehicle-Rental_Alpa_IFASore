import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vehicle_rental/components/form_field.dart';
import 'package:vehicle_rental/controllers/auth_controller.dart';
import 'package:vehicle_rental/database/database_helper.dart';
import 'package:vehicle_rental/models/user_model.dart';
import 'package:vehicle_rental/responsive/screen_layout.dart';
import 'package:vehicle_rental/screens/register_screen.dart';
import 'package:vehicle_rental/utils/colors.dart';
import 'package:vehicle_rental/utils/helper.dart';
import 'package:vehicle_rental/utils/message.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final db = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final AuthController _auth = AuthController();

  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }
  
  login() async {
    // validate input
    if (_formKey.currentState!.validate()) {
      String email = emailCtrl.text;
      String passwd = passwordCtrl.text;

      UserModel userModel = UserModel(
        email: email,
        password: passwd,
      );

      setState(() {
        isLoading = true;
      });

      // login to account
      var response = await db.login(userModel);
      if (response == true) {
        // if email and password match -> store the email in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        // Firebase Sign In
        User? user = await _auth.signin(email, passwd);
        if (user != null && mounted) {
          // navigate to ScreenLayout
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ScreenLayout()));
          // Success Message
          ScaffoldMessenger.of(context).showSnackBar(buildSnackBarSuccess('login_screen/login'.i18n()));
        }
      } else {
        // if doesnt match
        if (mounted) {
          alertDialog(context, 'login_screen/email-password-incorrect'.i18n());
        }
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: whiteText,
          body: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: 340,
                child: Column(children: [
                  const SizedBox(height: 25,),
                  Image.asset(
                    'assets/illustration/form.jpg',
                    width: 251,
                    height: 274,
                  ),
                  Text(
                    'login_screen/title'.i18n(),
                    style: GoogleFonts.roboto(
                      fontSize: 40, 
                      color: signText, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextFormField(
                            controller: emailCtrl,
                            icon: Icons.email_outlined,
                            inputType: TextInputType.emailAddress,
                            hintName: 'global/email'.i18n()
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextFormField(
                            controller: passwordCtrl,
                            icon: Icons.lock_outlined,
                            isObscureText: true,
                            hintName: 'global/password'.i18n()
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Visibility(
                      visible: !isLoading,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                          ),
                          backgroundColor: primaryButton,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 120, 
                            vertical: 20)
                          ),
                        onPressed: login,
                        child: Text(
                          'login_screen/button'.i18n(),
                          style: const TextStyle(fontSize: 20),
                        )
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isLoading,
                    child: const CircularProgressIndicator(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('login_screen/no-account'.i18n()),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'login_screen/signup'.i18n(),
                          style: const TextStyle(color: primaryButton),
                        )
                      )
                    ],
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}