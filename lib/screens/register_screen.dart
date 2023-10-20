import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';
import 'package:vehicle_rental/components/form_field.dart';
import 'package:vehicle_rental/database/database_helper.dart';
import 'package:vehicle_rental/models/user_model.dart';
import 'package:vehicle_rental/screens/login_screen.dart';
import 'package:vehicle_rental/utils/colors.dart';
import 'package:vehicle_rental/utils/helper.dart';
import 'package:vehicle_rental/utils/message.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final db = DatabaseHelper();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
  }

  register() async {
    String name = nameCtrl.text;
    String username = usernameCtrl.text;
    String email = emailCtrl.text;
    String passwd = passwordCtrl.text;
    String cpasswd = confirmPasswordCtrl.text;

    if (_formKey.currentState!.validate()) {
      if (passwd != cpasswd) {
        alertDialog(context, 'Password Mismatch');
      } else {
        _formKey.currentState!.save();

        UserModel userModel = UserModel(
          name: name,
          username: username,
          email: email,
          password: passwd,
          about: ''
        );

        int result = await db.signup(userModel);
        if (mounted) {
          if(result == -1) {
            alertDialog(context, 'Email or Username already exists');
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            ScaffoldMessenger.of(context).showSnackBar(
              buildSnackBarSuccess('Register')
            );
          }
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
                      fontWeight: FontWeight.bold),
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
                            hintName: 'Name'),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomTextFormField(
                            controller: usernameCtrl,
                            icon: Icons.person_outline,
                            inputType: TextInputType.name,
                            hintName: 'Username'),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomTextFormField(
                            controller: emailCtrl,
                            icon: Icons.email_outlined,
                            inputType: TextInputType.emailAddress,
                            hintName: 'Email'),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomTextFormField(
                            controller: passwordCtrl,
                            icon: Icons.lock_outlined,
                            isObscureText: true,
                            hintName: 'Password'),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomTextFormField(
                            controller: confirmPasswordCtrl,
                            icon: Icons.lock_outlined,
                            isObscureText: true,
                            hintName: 'Confirm Password'),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                      backgroundColor: primaryButton,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 15)),
                    onPressed: register,
                    child: const Text(
                      'REGISTER',
                      style: TextStyle(fontSize: 18),
                    )),
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
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}