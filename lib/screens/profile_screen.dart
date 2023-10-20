import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vehicle_rental/components/form_field.dart';
import 'package:vehicle_rental/components/profile_button.dart';
import 'package:vehicle_rental/database/database_helper.dart';
import 'package:vehicle_rental/models/user_model.dart';
import 'package:vehicle_rental/screens/edit_profile_screen.dart';
import 'package:vehicle_rental/screens/login_screen.dart';
import 'package:vehicle_rental/utils/colors.dart';
import 'package:vehicle_rental/utils/helper.dart';
import 'package:vehicle_rental/utils/message.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel? user;
  const ProfileScreen({Key? key, this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final db = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
  }

  Future<void> changePassword() async {
    String currentPassword = currentPasswordController.text;
    String newPassword = newPasswordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (_formKey.currentState!.validate()) {
      if (newPassword != confirmPassword) {
        return alertDialog(context, 'Password Mismatch');
      } else {
        _formKey.currentState!.save();
        
        final UserModel? user = await db.getLoginUser(widget.user!.email.toString());

        if (user != null) {
          final result = await db.updatePassword(user, currentPassword, newPassword);

          if (result == -1 && mounted) {
            return alertDialog(context, 'User Not Found');
          } else if (result == -2 && mounted) {
            return alertDialog(context, 'Incorrect Current Password');
          } else {
            if(mounted) {
              ScaffoldMessenger.of(context).showSnackBar(buildSnackBarSuccess('Password Changed Successfully'));
              Navigator.pop(context);
            }
          }
        }
      }
    }
  }

  Future<void> deleteAccount(String email) async {
    final UserModel? user = await db.getLoginUser(email);
    if (user != null) {
      final int result = await db.deleteUser(user.email.toString());
      if (mounted) {
        if (result > 0) {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          ScaffoldMessenger.of(context)
              .showSnackBar(buildSnackBarDanger('Account Deleted'));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(buildSnackBarDanger('Account Deletion Failed'));
        }
      }
    }
  }

  Future<void> clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
  }

  void deleteAccountWrapper() async {
    await clearSharedPreferences();
    await deleteAccount(widget.user!.email.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserModel?>(
        future: db.getLoginUser(widget.user!.email.toString()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: gray
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/profile/profile.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data!.name.toString(),
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            snapshot.data!.username.toString(),
                            style: const TextStyle(
                                fontSize: 18,
                                color: gray,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditProfileScreen(user: snapshot.data,)));
                            },
                            child: const MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Text(
                                'Edit Profile',
                                style: TextStyle(
                                  color: primaryButton,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  'About',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Text(
                  snapshot.data!.about.toString(),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(
                  height: 40,
                ),
                ProfileButton(
                  icon: Icons.lock_outlined,
                  title: 'Change Password',
                  onPressed: () {
                    showChangePasswordDialog(context);
                  },
                ),
                const SizedBox(height: 15),
                ProfileButton(
                  icon: Icons.logout_outlined,
                  title: 'Log Out',
                  onPressed: () {
                    showConfirmationDialog(context, 'Log Out', () async{
                      await clearSharedPreferences();
                      if(mounted) {
                        Navigator.push(context,MaterialPageRoute(builder: (_) => const LoginScreen()));
                        ScaffoldMessenger.of(context).showSnackBar(buildSnackBarDanger('Log Out'));
                      }
                    });
                  },
                ),
                const SizedBox(height: 15),
                ProfileButton(
                  icon: Icons.delete_outlined,
                  title: 'Delete Account',
                  onPressed: () async {
                    showConfirmationDialog(context, 'Delete Account', deleteAccountWrapper);
                  },
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  void showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            resetFormFields();
            return true;
          },
          child: AlertDialog(
            title: const Text('Change Password'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PasswordFormField(
                    controller: currentPasswordController,
                    labelText: 'Current Password',
                  ),
                  PasswordFormField(
                    controller: newPasswordController,
                    labelText: 'New Password',
                  ),
                  PasswordFormField(
                    controller: confirmPasswordController,
                    labelText: 'Confirm New Password',
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  resetFormFields();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  changePassword();
                },
                child: const Text('Change Password'),
              ),
            ],
          ),
        );
      },
    );
  }

  void resetFormFields() {
    currentPasswordController.text = '';
    newPasswordController.text = '';
    confirmPasswordController.text = '';
  }
}