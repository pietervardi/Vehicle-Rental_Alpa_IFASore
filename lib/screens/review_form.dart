import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_rental/controllers/app_permission_handler.dart';
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

  // Create Review Firestore
  Future<void> createReview() async {
    final docReview = FirebaseFirestore.instance.collection('reviews').doc();
    final User? currentUser = await _auth.getUser();

    String imageUrl = '';

    if (_image != null) {
      imageUrl = await _store.uploadImageToStorage('reviewImage', docReview.id, _image!);
    }

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
    final isDarkMode = Provider.of<ThemeProvider>(context).currentTheme == 'dark';

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'review_form/title'.i18n(),
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
              return Semantics(
                onTapHint: 'semantics/global/back-button'.i18n(),
                child: Tooltip(
                  message: 'screen_layout/tooltip/back'.i18n(),
                  child: IconButton(
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
                  ),
                ),
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
                        Semantics(
                          label: 'semantics/review_form/subtitle'.i18n(),
                          child: Text(
                            'review_form/subtitle'.i18n(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        const SizedBox(height: 20,),
                        Semantics(
                          onTapHint: 'semantics/review_form/rate'.i18n(),
                          child: Row(
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
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Semantics(
                  label: 'semantics/review_form/add-photo-title'.i18n(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      'review_form/add-photo'.i18n(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Semantics(
                  onTapHint: 'semantics/review_form/add-photo'.i18n(),
                  child: GestureDetector(
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.cloud_upload_rounded,
                                size: 40,
                              ),
                              const SizedBox(height: 5,),
                              Text(
                                'review_form/click-here-to-upload'.i18n(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                ),
                              )
                            ],
                          ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Semantics(
                  label: 'semantics/review_form/comment-title'.i18n(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      'review_form/your-comment'.i18n(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Semantics(
                  label: 'semantics/review_form/comment'.i18n(),
                  child: Padding(
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
                        hintText: 'review_form/type-your-comment-here'.i18n(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Semantics(
                  onTapHint: 'semantics/review_form/button'.i18n(),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        createReview();
                        Navigator.pushReplacement(context, NoAnimationPageRoute(
                          builder: (context) => const ScreenLayout(page: 2),
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(buildSnackBarSuccess('review_form/create-review'.i18n()));
                      }, 
                      child: Text(
                        'review_form/button'.i18n(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900
                        ),
                      )
                    ),
                  ),
                ),
                const SizedBox(height: 30),
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
          title: Semantics(
            label: 'semantics/global/image-dialog-title'.i18n(),
            child: Text(
              'global/title-dialog'.i18n(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                onTapHint: 'semantics/global/image-dialog-storage'.i18n(),
                child: ElevatedButton(
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
              ),
              const SizedBox(height: 5,),
              Semantics(
                onTapHint: 'semantics/global/image-dialog-camera'.i18n(),
                child: ElevatedButton(
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
                      const Icon(Icons.camera_alt, color: whiteText), // Icon
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
              ),
            ],
          ),
        );
      },
    );
  }
}