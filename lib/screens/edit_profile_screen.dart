import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_rental/components/form_field.dart';
import 'package:vehicle_rental/controllers/auth_controller.dart';
import 'package:vehicle_rental/database/database_helper.dart';
import 'package:vehicle_rental/models/user_model.dart';
import 'package:vehicle_rental/responsive/screen_layout.dart';
import 'package:vehicle_rental/utils/animation.dart';
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
  final db = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final AuthController _auth = AuthController();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController aboutCtrl = TextEditingController();

  updateProfile() async {
    String name = nameCtrl.text;
    String username = usernameCtrl.text.toLowerCase();
    String email = emailCtrl.text;
    String about = aboutCtrl.text;

    // validate input
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
      
      // set new inputted email into SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);

      // store updated user data
      int result = await db.updateUser(userModel);
      if (mounted) {
        if(result == -1) {
          alertDialog(context, 'global/email-password-exist'.i18n());
        } else {
          // Update User Firestore
          updateUserFirestore(name, username, email, about);
          // navigate to ScreenLayout(ProfileScreen)
          Navigator.push(context, NoAnimationPageRoute(
            builder: (context) => const ScreenLayout(page: 3)
          ));
          // Success Message
          ScaffoldMessenger.of(context).showSnackBar(
            buildSnackBarSuccess('edit_profile_screen/update-profile'.i18n())
          );
        }
      }
    }
  }

  // Update User Firestore
  Future<void> updateUserFirestore(String name, String username, String email, String about) async {
    final User? currentUser = await _auth.getUser();
    final docUser = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);
    try {
      await docUser.update({
        'name': name,
        'username': username,
        'email': email,
        'about': about
      });
    } catch (error) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).currentTheme == 'dark';

    if (widget.user != null) {
      nameCtrl.text = widget.user!.name ?? '';
      usernameCtrl.text = widget.user!.username ?? '';
      emailCtrl.text = widget.user!.email ?? '';
      aboutCtrl.text = widget.user!.about ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'global/edit-profile'.i18n(),
          style: TextStyle(
            fontSize: 30, 
            fontWeight: FontWeight.bold,
            color: isDarkMode ? whiteText : black
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: Consumer<ThemeProvider>(
          builder: (context, provider, child) {
            return IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left_outlined,
                color: isDarkMode ? whiteText : black,
                size: 28,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                ProfileFormField(
                  controller: nameCtrl,
                  icon: Icons.person,
                  inputType: TextInputType.name,
                  hintName: 'global/name'.i18n()
                ),
                const SizedBox(
                  height: 20,
                ),
                ProfileFormField(
                  controller: usernameCtrl,
                  icon: Icons.person_outline,
                  inputType: TextInputType.name,
                  hintName: 'global/username'.i18n()
                ),
                const SizedBox(
                  height: 20,
                ),
                ProfileFormField(
                  controller: emailCtrl,
                  icon: Icons.email_outlined,
                  inputType: TextInputType.emailAddress,
                  hintName: 'global/email'.i18n()
                ),
                const SizedBox(
                  height: 20,
                ),
                ProfileFormField(
                  controller: aboutCtrl,
                  icon: Icons.info_outlined,
                  inputType: TextInputType.emailAddress,
                  line: 6,
                  hintName: 'edit_profile_screen/about'.i18n()
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                    ),
                    backgroundColor: primaryButton,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60, 
                      vertical: 20
                    )
                  ),
                  onPressed: updateProfile,
                  child: Text(
                    'global/update'.i18n(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700
                    ),
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}