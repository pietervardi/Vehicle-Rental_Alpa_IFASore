import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vehicle_rental/components/form_field.dart';
import 'package:vehicle_rental/components/profile_button.dart';
import 'package:vehicle_rental/components/skeleton_loader.dart';
import 'package:vehicle_rental/controllers/auth_controller.dart';
import 'package:vehicle_rental/controllers/storage_controller.dart';
import 'package:vehicle_rental/database/database_helper.dart';
import 'package:vehicle_rental/models/user_firebase_model.dart';
import 'package:vehicle_rental/models/user_model.dart';
import 'package:vehicle_rental/screens/edit_profile_screen.dart';
import 'package:vehicle_rental/screens/login_screen.dart';
import 'package:vehicle_rental/screens/profile_picture_screen.dart';
import 'package:vehicle_rental/utils/animation.dart';
import 'package:vehicle_rental/utils/colors.dart';
import 'package:vehicle_rental/utils/helper.dart';
import 'package:vehicle_rental/utils/message.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final db = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final AuthController _auth = AuthController();
  final StorageController _store = StorageController();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
  }

  // get Current Email stored in SharedPreferences
  Future<String?> getEmailFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    return email;
  }

  // change New Password
  Future<void> changePassword() async {
    String currentPassword = currentPasswordController.text;
    String newPassword = newPasswordController.text;
    String confirmPassword = confirmPasswordController.text;

    // validate input
    if (_formKey.currentState!.validate()) {
      // check if password match
      if (newPassword != confirmPassword) {
        return alertDialog(context, 'Password Mismatch');
      } else {
        _formKey.currentState!.save();
        
        // get Login User data
        String? email = await getEmailFromSharedPreferences();
        final UserModel? user = await db.getLoginUser(email.toString());

        if (user != null) {
          // Store new Password
          final result = await db.updatePassword(
            user, 
            currentPassword, 
            newPassword
          );
          if (result == -1 && mounted) {
            return alertDialog(context, 'User Not Found');
          } else if (result == -2 && mounted) {
            return alertDialog(context, 'Incorrect Current Password');
          } else {
            if(mounted) {
              // Firebase Update Password
              _auth.updatePasswordFirebase(
                email: email,
                oldPassword: currentPassword,
                newPassword: newPassword
              );
              ScaffoldMessenger.of(context).showSnackBar(buildSnackBarSuccess('Update Password'));
              Navigator.pop(context);
            }
          }
        }
      }
    }
  }

  // Delete Account
  Future<void> deleteAccount(String email) async {
    final UserModel? user = await db.getLoginUser(email);

    if (user != null) {
      // delete account by email
      final int result = await db.deleteUser(user.email.toString());
      if (mounted) {
        if (result > 0) {
          // Firestore Delete User
          await deleteUserFirestore();
          // Firebase Delete Account
          _auth.deleteUserFirebase();
          if (mounted) {
            Navigator.push(
              context, MaterialPageRoute
              (builder: (_) => const LoginScreen())
            );
            ScaffoldMessenger.of(context).showSnackBar(buildSnackBarDanger('Delete Account'));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(buildSnackBarDanger('Delete Account'));
        }
      }
    }
  }

  // Clear email in SharedPreferences
  Future<void> clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    // Firebase Log Out
    _auth.logout();
  }

  // Wrapper function
  void deleteAccountWrapper() async {
    String? email = await getEmailFromSharedPreferences();
    await deleteAccount(email.toString());
    await clearSharedPreferences();
  }

  // Get Single User by ID
  Stream<UserFirebase?> readUser() async* {
    final User? currentUser = await _auth.getUser();
    final docUser = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

    yield* docUser.snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserFirebase.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  // Delete User From Firestore
  Future<void> deleteUserFirestore() async {
    final User? currentUser = await _auth.getUser();
    _store.deleteImage('userImage', currentUser!.uid);
    await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserModel?>(
        future: getEmailFromSharedPreferences().then((email) => db.getLoginUser(email.toString())),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator()
            );
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
                    StreamBuilder<UserFirebase?>(
                      stream: readUser(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SkeletonLoaderProfileScreen();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if(snapshot.hasData) {
                          final user = snapshot.data;

                          return GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(context, NoAnimationPageRoute(
                                builder: (context) => ProfilePictureScreen(imageUrl: user.imageUrl),
                              ));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: gray,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: gray
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: user!.imageUrl.isEmpty
                                  ? Image.asset(
                                      'assets/profile/profile.png',
                                      width: 100,
                                      height: 100,
                                    )
                                  : Image.network(
                                      user.imageUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                              ),
                            ),
                          );
                        }
                        return Container();
                      }
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data!.name.toString(),
                            style: const TextStyle(
                              fontSize: 22, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                            '@${snapshot.data!.username.toString()}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: gray,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditProfileScreen(user: snapshot.data,)
                                )
                              );
                            }, 
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: primaryButton,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: Text(
                    snapshot.data!.about.toString(),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 10),
                ProfileButton(
                  icon: Icons.lock_outlined,
                  title: 'Change Password',
                  onPressed: () {
                    resetFormFields();
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

  // Dialog for Change Password
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

  // Reset Form Field
  void resetFormFields() {
    currentPasswordController.text = '';
    newPasswordController.text = '';
    confirmPasswordController.text = '';
  }
}