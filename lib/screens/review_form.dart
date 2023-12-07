import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_rental/controllers/auth_controller.dart';
import 'package:vehicle_rental/controllers/storage_controller.dart';
import 'package:vehicle_rental/database/database_helper.dart';
import 'package:vehicle_rental/models/review_model.dart';
import 'package:vehicle_rental/responsive/screen_layout.dart';
import 'package:vehicle_rental/utils/animation.dart';
import 'package:vehicle_rental/utils/choose_image.dart';
import 'package:vehicle_rental/utils/colors.dart';
import 'package:vehicle_rental/utils/message.dart';
import 'package:vehicle_rental/utils/theme_provider.dart';

class ReviewForm extends StatefulWidget {
  const ReviewForm({Key? key}) : super(key: key);

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final AuthController _auth = AuthController();
  final StorageController _store = StorageController();
  final db = DatabaseHelper();
  double rating = 0;
  Uint8List? _image;
  TextEditingController textCtrl = TextEditingController();
  

  @override
  void dispose() {
    textCtrl.dispose();
    super.dispose();
  }

  // Rating Text
  String getRatingText(double rating) {
    if (rating == 5) {
      return 'Wow!';
    } else if (rating >= 4) {
      return 'Great!';
    } else if (rating >= 3) {
      return 'Good!';
    } else if (rating >= 2) {
      return 'Okay';
    } else if (rating >= 1) {
      return 'Not Good';
    } else {
      return '';
    }
  }

  // get Current Email stored in SharedPreferences
  Future<String?> getEmailFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    return email;
  }

  // Create Review Firestore
  Future<void> createReview() async {
    final docReview = FirebaseFirestore.instance.collection('reviews').doc();
    final User? currentUser = await _auth.getUser();

    String imageUrl = await _store.uploadImageToStorage('reviewImage', docReview.id, _image!);

    final review = Review(
      id: docReview.id,
      rate: rating,
      text: textCtrl.text,
      imageUrl: imageUrl,
      userId: currentUser!.uid,
      likes: [],
      comments: [],
      createdAt: Timestamp.now()
    );

    final json = review.toJson();
    await docReview.set(json);
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
    final isDarkMode = Provider.of<ThemeProvider>(context).currentTheme == 'dark';

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'Write a Review',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
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
                  Navigator.pushReplacement(context, NoAnimationPageRoute(
                    builder: (context) => const ScreenLayout(page: 2),
                  ));
                },
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 30
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          " What's Your Rate?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RatingBar.builder(
                              minRating: 1,
                              maxRating: 5,
                              initialRating: rating,
                              itemSize: 40,
                              itemBuilder: (context, _) => const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                              ),
                              updateOnDrag: true,
                              onRatingUpdate: (rating) => setState(() {
                                this.rating = rating;
                              })
                            ),
                            Text(
                              getRatingText(rating),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: gray
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    'Add Photo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: _showImageDialog,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 150,
                      child: _image != null 
                      ?
                        Image.memory(
                          _image!,
                        )
                      : 
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_rounded,
                              size: 40,
                            ),
                            SizedBox(height: 5,),
                            Text(
                              'Click here to upload',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                              ),
                            )
                          ],
                        ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    'Your Comment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: TextField(
                    controller: textCtrl,
                    maxLines: 6,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDarkMode ? null : whiteText,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'Type your comment here...',
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      createReview();
                      Navigator.pushReplacement(context, NoAnimationPageRoute(
                        builder: (context) => const ScreenLayout(page: 2),
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(buildSnackBarSuccess('Create Review'));
                    }, 
                    child: const Text(
                      'Submit Review',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900
                      ),
                    )
                  ),
                )
              ],
            ),
          ),
        ),
      ),
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