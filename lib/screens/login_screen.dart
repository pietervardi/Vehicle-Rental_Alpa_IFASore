import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vehicle_rental/components/form_field.dart';
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

  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
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

      // login to account
      var response = await db.login(userModel);
      if (response == true) {
        // if email and password match -> store the email in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);

        if (!mounted) return;
        // navigate to ScreenLayout
        Navigator.pushReplacement(
          context, MaterialPageRoute(
            builder: (context) => const ScreenLayout()
          )
        );
        // Success Message
        ScaffoldMessenger.of(context).showSnackBar(
          buildSnackBarSuccess('Login')
        );
      } else {
        // if doesnt match
        if (mounted) {
          alertDialog(context, 'Email or Password is Incorrect');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
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
                  'LOG IN',
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
                          hintName: 'Email'
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomTextFormField(
                          controller: passwordCtrl,
                          icon: Icons.lock_outlined,
                          isObscureText: true,
                          hintName: 'Password'
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
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
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(fontSize: 20),
                    )
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account ?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(color: primaryButton),
                      )
                    )
                  ],
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}