import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_rental/components/form_field.dart';
import 'package:vehicle_rental/database/database_helper.dart';
import 'package:vehicle_rental/models/user_model.dart';
import 'package:vehicle_rental/responsive/screen_layout.dart';
import 'package:vehicle_rental/utils/colors.dart';
import 'package:vehicle_rental/utils/helper.dart';
import 'package:vehicle_rental/utils/message.dart';
import 'package:vehicle_rental/utils/theme_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel? user;
  const EditProfileScreen({Key? key, this.user}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final db = DatabaseHelper();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController aboutCtrl = TextEditingController();

  updateProfile() async {
    String name = nameCtrl.text;
    String username = usernameCtrl.text;
    String email = emailCtrl.text;
    String about = aboutCtrl.text;

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      UserModel userModel = UserModel(
        id: widget.user!.id,
        name: name,
        username: username,
        email: email,
        password: widget.user!.password,
        about: about
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);

      int result = await db.updateUser(userModel);
      if (mounted) {
        if(result == -1) {
          alertDialog(context, 'Email or Username already exists');
        } else {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => const ScreenLayout(page: 3)
          ));
          ScaffoldMessenger.of(context).showSnackBar(
            buildSnackBarSuccess('Update Profile')
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user != null) {
      nameCtrl.text = widget.user!.name ?? '';
      usernameCtrl.text = widget.user!.username ?? '';
      emailCtrl.text = widget.user!.email ?? '';
      aboutCtrl.text = widget.user!.about ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Consumer<ThemeProvider>(
          builder: (context, provider, child) {
            final isDarkMode = provider.currentTheme == 'dark';

            return IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left_outlined,
                color: isDarkMode ? Colors.white : Colors.black,
                size: 28,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Center(
                child: Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ProfileFormField(
                  controller: nameCtrl,
                  icon: Icons.person,
                  inputType: TextInputType.name,
                  hintName: 'Name'),
              const SizedBox(
                height: 15,
              ),
              ProfileFormField(
                  controller: usernameCtrl,
                  icon: Icons.person_outline,
                  inputType: TextInputType.name,
                  hintName: 'Username'),
              const SizedBox(
                height: 15,
              ),
              ProfileFormField(
                  controller: emailCtrl,
                  icon: Icons.email_outlined,
                  inputType: TextInputType.emailAddress,
                  hintName: 'Email'),
              const SizedBox(
                height: 15,
              ),
              ProfileFormField(
                  controller: aboutCtrl,
                  icon: Icons.email_outlined,
                  inputType: TextInputType.emailAddress,
                  hintName: 'About'),
              const SizedBox(
                height: 15,
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
                    onPressed: updateProfile,
                    child: const Text(
                      'UPDATE',
                      style: TextStyle(fontSize: 18),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
