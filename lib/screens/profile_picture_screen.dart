import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Profile Photo',
          style: TextStyle(
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
                  ScaffoldMessenger.of(context).showSnackBar(buildSnackBarSuccess('Update Profile Picture'));
                }, 
                child: const Text(
                  'UPDATE',
                  style: TextStyle(
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
          title: const Text(
            'Choose an option',
            style: TextStyle(
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
                  selectImage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Background color
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, color: Colors.white), // Icon
                    SizedBox(width: 8),
                    Text(
                      'Choose existing photo', 
                      style: TextStyle(
                        color: Colors.white,
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
                  takePicture();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Background color
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.white), // Icon
                    SizedBox(width: 8),
                    Text(
                      'Take photo', 
                      style: TextStyle(
                        color: Colors.white,
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