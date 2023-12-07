import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vehicle_rental/components/form_field.dart';
import 'package:vehicle_rental/controllers/auth_controller.dart';
import 'package:vehicle_rental/database/database_helper.dart';
import 'package:vehicle_rental/models/user_firebase_model.dart';
import 'package:vehicle_rental/models/user_model.dart';
import 'package:vehicle_rental/responsive/screen_layout.dart';
import 'package:vehicle_rental/utils/colors.dart';
import 'package:vehicle_rental/utils/helper.dart';
import 'package:vehicle_rental/utils/message.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final db = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final AuthController _auth = AuthController();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    usernameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }

  register() async {
    String name = nameCtrl.text;
    String username = usernameCtrl.text.toLowerCase();
    String email = emailCtrl.text;
    String passwd = passwordCtrl.text;
    String cpasswd = confirmPasswordCtrl.text;

    // validate input
    if (_formKey.currentState!.validate()) {
      // check if password match & minimum length 6 characters
      if (passwd != cpasswd) {
        alertDialog(context, 'Password Mismatch');
      } else if (passwd.length < 6) {
        alertDialog(context, 'Password must be at least 6 characters');
      } else {
        _formKey.currentState!.save();

        UserModel userModel = UserModel(
          name: name,
          username: username,
          email: email,
          password: passwd,
          about: '-'
        );

        setState(() {
          isLoading = true;
        });

        // Firebase Sign Up
        User? user = await _auth.signup(email, passwd);
        if (user != null) {
          // create user account
          int result = await db.signup(userModel);
          if (result == -1 && mounted) {
            alertDialog(context, 'Email or Username already exists');
          } else {
            // if email and password match -> store the email in SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('email', email);
            // Create User Firestore
            createUser(name, username, email);
            if (mounted) {
              // navigate to ScreenLayout
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ScreenLayout()));
              // Success Message
              ScaffoldMessenger.of(context).showSnackBar(buildSnackBarSuccess('Register'));
            }
          }
        }

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Create User Firestore
  Future<void> createUser(String name, String username, String email) async {
    final User? currentUser = await _auth.getUser();
    final docUser = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

    final user = UserFirebase(
      id: docUser.id,
      name: name,
      username: username,
      email: email,
      about: '-',
      imageUrl: '',
      createdAt: Timestamp.now()
    );

    final json = user.toJson();
    await docUser.set(json);
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
                const SizedBox(
                  height: 25,
                ),
                Image.asset(
                  'assets/illustration/form.jpg',
                  width: 251,
                  height: 274,
                ),
                Text(
                  'REGISTER',
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
                          controller: nameCtrl,
                          icon: Icons.person,
                          inputType: TextInputType.name,
                          hintName: 'Name'
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomTextFormField(
                          controller: usernameCtrl,
                          icon: Icons.person_outline,
                          inputType: TextInputType.name,
                          hintName: 'Username'
                        ),
                        const SizedBox(
                          height: 10,
                        ),
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
                        const SizedBox(
                          height: 10,
                        ),
                        CustomTextFormField(
                          controller: confirmPasswordCtrl,
                          icon: Icons.lock_outlined,
                          isObscureText: true,
                          hintName: 'Confirm Password'
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
                          horizontal: 110, 
                          vertical: 20
                        )
                      ),
                      onPressed: register,
                      child: const Text(
                        'REGISTER',
                        style: TextStyle(fontSize: 20),
                      )),
                  ),
                ),
                Visibility(
                  visible: isLoading,
                  child: const CircularProgressIndicator(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account ?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Sign in',
                        style: TextStyle(color: primaryButton),
                      )
                    )
                  ],
                ),
                const SizedBox(height: 20,)
              ]),
            ),
          ),
        ),
      ),
    );
  }
}