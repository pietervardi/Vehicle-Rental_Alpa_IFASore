import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localization/localization.dart';
import 'package:vehicle_rental/controllers/app_permission_handler.dart';
import 'package:vehicle_rental/controllers/auth_controller.dart';
import 'package:vehicle_rental/controllers/storage_controller.dart';
import 'package:vehicle_rental/responsive/screen_layout.dart';
import 'package:vehicle_rental/utils/animation.dart';
import 'package:vehicle_rental/utils/choose_image.dart';
import 'package:vehicle_rental/utils/colors.dart';
import 'package:vehicle_rental/utils/message.dart';

class ProfilePictureScreen extends StatefulWidget {
  final String imageUrl;
  const ProfilePictureScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<ProfilePictureScreen> createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends State<ProfilePictureScreen> {
  final AuthController _auth = AuthController();
  final StorageController _store = StorageController();
  Uint8List? _image;
  late final ScaffoldMessengerState messanger;

  // Update User Profile Picture to Firestore + Firebase Storage
  Future<void> updateProfilePicture() async {
    final User? currentUser = await _auth.getUser();
    final docUser = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

    String imageUrl = await _store.uploadImageToStorage('userImage', docUser.id, _image!);

    try {
      await docUser.update({
        'imageUrl': imageUrl,
      });
    } catch (error) {
      rethrow;
    }
  }

  // Select Image from Gallery
  Future<void> selectImage() async {
    Uint8List img = await chooseImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  // Take Picture from Camera
  Future<void> takePicture() async {
    Uint8List img = await chooseImage(ImageSource.camera);
    setState(() {
      _image = img;
    });
  }

  // Permission Handler Storage
  Future<void> storage() async {
    StoragePermissionHandler.handleStoragePermission(context, selectImage);
  }

  // Permission Handler Camera
  Future<void> camera() async {
    CameraPermissionHandler.handleCameraPermission(context, takePicture);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'profile_picture_screen/title'.i18n(),
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: black,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_left_outlined,
            size: 28,
          ),
          onPressed: () {
            Navigator.pushReplacement(context, NoAnimationPageRoute(
              builder: (context) => const ScreenLayout(page: 3),
            ));
          },
        ),
        actions: [
          IconButton(
            onPressed: _showImageDialog,
            icon: const Icon(
              Icons.edit_outlined,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.share_outlined,
            ),
          ),
        ],
      ),
      backgroundColor: black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
            child: SizedBox(
              height: 400,
              child: _image != null 
                ?
                  Image.memory(
                    _image!,
                    fit: BoxFit.contain,
                  )
                : 
                  widget.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.imageUrl,
                      fit: BoxFit.contain,
                    )
                  : Image.asset(
                      'assets/profile/profile.png',
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          if (_image != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  updateProfilePicture();
                  Navigator.pushReplacement(context, NoAnimationPageRoute(
                    builder: (context) => const ScreenLayout(page: 3),
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(buildSnackBarSuccess('profile_picture_screen/update-profile-picture'.i18n()));
                }, 
                child: Text(
                  'global/update'.i18n(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900
                  ),
                )
              ),
            )
        ],
      )
    );
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'global/title-dialog'.i18n(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  storage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image, color: whiteText),
                    const SizedBox(width: 8),
                    Text(
                      'global/choose-existing-photo'.i18n(), 
                      style: const TextStyle(
                        color: whiteText,
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                      )
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5,),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  camera();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt, color: whiteText),
                    const SizedBox(width: 8),
                    Text(
                      'global/take-photo'.i18n(), 
                      style: const TextStyle(
                        color: whiteText,
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}