import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:localization/localization.dart';
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

  late InterstitialAd _interstitialAd;
  bool _isInterstitialReady = false;

  bool isPremium = false;

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
    checkPremiumStatus();
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
        return alertDialog(context, 'global/password-mismatch'.i18n());
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
            return alertDialog(context, 'profile_screen/user-not-found'.i18n());
          } else if (result == -2 && mounted) {
            return alertDialog(context, 'profile_screen/incorrect-current-password'.i18n());
          } else {
            if(mounted) {
              // Firebase Update Password
              _auth.updatePasswordFirebase(
                email: email,
                oldPassword: currentPassword,
                newPassword: newPassword
              );
              ScaffoldMessenger.of(context).showSnackBar(buildSnackBarSuccess('profile_screen/update-password'.i18n()));
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
          await _auth.deleteUserFirebase();
          if (_isInterstitialReady) {
            _interstitialAd.show();
          }
          if (mounted) {
            Navigator.push(
              context, MaterialPageRoute
              (builder: (_) => const LoginScreen())
            );
            ScaffoldMessenger.of(context).showSnackBar(buildSnackBarDanger('profile_screen/delete-account'.i18n()));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(buildSnackBarDanger('profile_screen/delete-account'.i18n()));
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

  // Load Interstitial Ads
  void _loadInterstitialAd() {
    InterstitialAd.load(
    adUnitId: "ca-app-pub-3940256099942544/1033173712",
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
      ad.fullScreenContentCallback = FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
        debugPrint("Close Interstitial Ad");
      });
      setState(() {
        _isInterstitialReady = true;
        _interstitialAd = ad;
      });
      }, onAdFailedToLoad: (err) {
        _isInterstitialReady = false;
        _interstitialAd.dispose();
      })
    );
  }

  // Check Premium Status
  Future<void> checkPremiumStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool premiumStatus = prefs.getBool('subscriptionStatus') ?? false;
    if (premiumStatus == false) {
      _loadInterstitialAd();
    }
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

                          return Semantics(
                            onTapHint: 'semantics/profile_screen/profile-picture'.i18n(),
                            child: GestureDetector(
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
                          Semantics(
                            label: 'semantics/profile_screen/account-name'.i18n(),
                            child: Text(
                              snapshot.data!.name.toString(),
                              style: const TextStyle(
                                fontSize: 22, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Semantics(
                            label: 'semantics/profile_screen/account-username'.i18n(),
                            child: Text(
                              '@${snapshot.data!.username.toString()}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: gray,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Semantics(
                            onTapHint: 'semantics/profile_screen/edit-profile'.i18n(),
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditProfileScreen(user: snapshot.data,)
                                  )
                                );
                              }, 
                              child: Text(
                                'global/edit-profile'.i18n(),
                                style: const TextStyle(
                                  color: primaryButton,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Semantics(
                  label: 'semantics/profile_screen/about'.i18n(),
                  child: Text(
                    'profile_screen/about'.i18n(),
                    style: const TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
                Semantics(
                  label: 'semantics/profile_screen/account-about'.i18n(),
                  child: SizedBox(
                    height: 100,
                    child: Text(
                      snapshot.data!.about.toString(),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Semantics(
                  onTapHint: 'semantics/profile_screen/change-password'.i18n(),
                  child: ProfileButton(
                    icon: Icons.lock_outlined,
                    title: 'profile_screen/change-password'.i18n(),
                    onPressed: () {
                      resetFormFields();
                      showChangePasswordDialog(context);
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Semantics(
                  onTapHint: 'semantics/profile_screen/logout'.i18n(),
                  child: ProfileButton(
                    icon: Icons.logout_outlined,
                    title: 'profile_screen/logout'.i18n(),
                    onPressed: () {
                      showConfirmationDialog(context, 'profile_screen/logout'.i18n(), () async {
                        await clearSharedPreferences();
                        if (_isInterstitialReady) {
                          _interstitialAd.show();
                        }
                        if (mounted) {
                          Navigator.push(context,MaterialPageRoute(builder: (_) => const LoginScreen()));
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Semantics(
                  onTapHint: 'semantics/profile_screen/delete-account'.i18n(),
                  child: ProfileButton(
                    icon: Icons.delete_outlined,
                    title: 'profile_screen/delete-account'.i18n(),
                    onPressed: () async {
                      showConfirmationDialog(context, 'profile_screen/delete-account'.i18n(), deleteAccountWrapper);
                    },
                  ),
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
            title: Semantics(
              label: 'semantics/profile_screen/change-password-title'.i18n(),
              child: Text('profile_screen/change-password'.i18n())
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    label: 'semantics/profile_screen/change-password-current-password'.i18n(),
                    child: PasswordFormField(
                      controller: currentPasswordController,
                      labelText: 'profile_screen/current-password'.i18n(),
                    ),
                  ),
                  Semantics(
                    label: 'semantics/profile_screen/change-password-new-password'.i18n(),
                    child: PasswordFormField(
                      controller: newPasswordController,
                      labelText: 'profile_screen/new-password'.i18n(),
                    ),
                  ),
                  Semantics(
                    label: 'semantics/profile_screen/change-password-confirm-new-password'.i18n(),
                    child: PasswordFormField(
                      controller: confirmPasswordController,
                      labelText: 'profile_screen/confirm-new-password'.i18n(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Semantics(
                onTapHint: 'semantics/global/cancel-button'.i18n(),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('global/cancel'.i18n()),
                ),
              ),
              Semantics(
                onTapHint: 'semantics/profile_screen/change-password-button'.i18n(),
                child: ElevatedButton(
                  onPressed: () {
                    changePassword();
                  },
                  child: Text('profile_screen/change-password'.i18n()),
                ),
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