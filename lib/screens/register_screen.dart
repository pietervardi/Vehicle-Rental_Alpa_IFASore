import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
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
        alertDialog(context, 'global/password-mismatch'.i18n());
      } else if (passwd.length < 6) {
        alertDialog(context, 'register_screen/password-length'.i18n());
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
            alertDialog(context, 'global/email-password-exist'.i18n());
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
              ScaffoldMessenger.of(context).showSnackBar(buildSnackBarSuccess('register_screen/register'.i18n()));
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
                Semantics(
                  label: 'semantics/global/auth-image'.i18n(),
                  child: Image.asset(
                    'assets/illustration/form.jpg',
                    width: 251,
                    height: 274,
                  ),
                ),
                Semantics(
                  label: 'semantics/register_screen/title'.i18n(),
                  child: Text(
                    'register_screen/title'.i18n(),
                    style: GoogleFonts.roboto(
                      fontSize: 40,
                      color: signText,
                      fontWeight: FontWeight.bold
                    ),
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
                        Semantics(
                          label: 'semantics/global/name'.i18n(),
                          child: CustomTextFormField(
                            controller: nameCtrl,
                            icon: Icons.person,
                            inputType: TextInputType.name,
                            hintName: 'global/name'.i18n()
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Semantics(
                          label: 'semantics/global/username'.i18n(),
                          child: CustomTextFormField(
                            controller: usernameCtrl,
                            icon: Icons.person_outline,
                            inputType: TextInputType.name,
                            hintName: 'global/username'.i18n()
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Semantics(
                          label: 'semantics/global/email'.i18n(),
                          child: CustomTextFormField(
                            controller: emailCtrl,
                            icon: Icons.email_outlined,
                            inputType: TextInputType.emailAddress,
                            hintName: 'global/email'.i18n()
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Semantics(
                          label: 'semantics/global/password'.i18n(),
                          child: CustomTextFormField(
                            controller: passwordCtrl,
                            icon: Icons.lock_outlined,
                            isObscureText: true,
                            hintName: 'global/password'.i18n()
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Semantics(
                          label: 'semantics/register_screen/confirm-password'.i18n(),
                          child: CustomTextFormField(
                            controller: confirmPasswordCtrl,
                            icon: Icons.lock_outlined,
                            isObscureText: true,
                            hintName: 'global/confirm-password'.i18n()
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Semantics(
                  onTapHint: 'semantics/register_screen/register-button'.i18n(),
                  child: Padding(
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
                        child: Text(
                          'register_screen/title'.i18n(),
                          style: const TextStyle(fontSize: 20),
                        )),
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
                    Semantics(
                      label: 'semantics/register_screen/have-account'.i18n(),
                      child: Text('register_screen/have-account'.i18n())
                    ),
                    Semantics(
                      onTapHint: 'semantics/register_screen/have-account-button'.i18n(),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'register_screen/signin'.i18n(),
                          style: const TextStyle(color: primaryButton),
                        )
                      ),
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