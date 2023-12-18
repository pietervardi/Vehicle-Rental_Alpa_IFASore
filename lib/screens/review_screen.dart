import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_rental/controllers/storage_controller.dart';
import 'package:vehicle_rental/models/review_model.dart';
import 'package:vehicle_rental/models/user_firebase_model.dart';
import 'package:vehicle_rental/screens/review_detail.dart';
import 'package:vehicle_rental/screens/review_form.dart';
import 'package:vehicle_rental/utils/animation.dart';
import 'package:vehicle_rental/utils/bottom_sheet.dart';
import 'package:vehicle_rental/utils/colors.dart';
import 'package:vehicle_rental/utils/theme_provider.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({Key? key}) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final StorageController _store = StorageController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Read Collection Review
  Stream<List<Review>> readReviews() => _firestore
    .collection('reviews')
    .orderBy('createdAt', descending: true)
    .snapshots()
    .map((snapshot) => snapshot.docs.map(
      (doc) => Review.fromJson(doc.data())).toList()
    );

  // Get Single User by ID
  Future<UserFirebase?> readUser(String id) async {
    final docUser = _firestore.collection('users').doc(id);

    try {
      final snapshot = await docUser.get();
      if (snapshot.exists) {
        return UserFirebase.fromJson(snapshot.data()!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Calculate Rating
  double calculateAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) {
      return 0.0;
    }
    double sum = 0.0;
    for (var review in reviews) {
      sum += review.rate;
    }
    return sum / reviews.length;
  }

  // Like Function
  Future<void> likeReview(BuildContext context, String id) async {
    try {
      await FirebaseFirestore.instance
        .collection('reviews')
        .doc(id)
        .update(
          {
            'likes': FieldValue.arrayUnion([userId])
          },
        );
    } on FirebaseException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('review_screen/error-like'.i18n()),
          ),
        );
      }
    }
  }

  // Dislike Function
  Future<void> dislikeReview(BuildContext context, String id) async {
    try {
      await FirebaseFirestore.instance
        .collection('reviews')
        .doc(id)
        .update(
          {
            'likes': FieldValue.arrayRemove([userId])
          },
        );
    } on FirebaseException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('review_screen/error-dislike'.i18n()),
          ),
        );
      }
    }
  }

  // Delete Review on Firestore + Firebase Storage
  Future<void> deleteReview(String id) async {
    _store.deleteImage('reviewImage', id);
    await FirebaseFirestore.instance
      .collection('reviews')
      .doc(id)
      .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Review>>(
        stream: readReviews(),
        builder: (context, snapshot1) {
          if (snapshot1.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator()
            );
          }
          if (snapshot1.hasError) {
            return Center(
              child: Text('Error: ${snapshot1.error}'),
            );
          }
          if (snapshot1.hasData) {
            final reviews = snapshot1.data!;
            double averageRating = calculateAverageRating(reviews);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10
                  ),
                  child: Semantics(
                    label: 'semantics/review_screen/title'.i18n(),
                    child: Text(
                      'review_screen/title'.i18n(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 25
                      ),
                    ),
                  ),
                ),
                Semantics(
                  label: 'semantics/review_screen/rate'.i18n(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 40,
                        ),
                        const SizedBox(width: 3,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 30
                              ),
                            ),
                            const Text(
                              '/5.0',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                                color: gray
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20,),
                        Text(
                          "${'review_screen/from'.i18n()} ${snapshot1.data!.length} ${'review_screen/people'.i18n()}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Expanded(
                  child: ListView(
                    children: reviews.map(buildReview).toList(),
                  ),
                ),
              ],
            );
          }
          return Container();
        },
      ),
      floatingActionButton: Semantics(
        onTapHint: 'semantics/review_screen/add-button'.i18n(),
        child: Tooltip(
          message: 'screen_layout/tooltip/add'.i18n(),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pushReplacement(context, NoAnimationPageRoute(
                builder: (context) => const ReviewForm(),
              ));
            },
            child: const Icon(Icons.add_outlined),
          ),
        ),
      ),
    );
  }

  Widget buildReview(Review review) {
    final isDarkMode = Provider.of<ThemeProvider>(context).currentTheme == 'dark';

    return Semantics(
      onTapHint: 'semantics/review_screen/detail'.i18n(),
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () async {
          UserFirebase? user = await readUser(review.userId);
          if (user != null && mounted) {
            Navigator.push(
              context,
              NoAnimationPageRoute(
                builder: (context) => ReviewDetail(
                  id: review.id,
                  name: user.name,
                  text: review.text,
                  profilePicture: user.imageUrl,
                  imageUrl: review.imageUrl,
                  createdAt: review.createdAt,
                ),
              ),
            );
          }
        },
        child: Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<UserFirebase?>(
                future: readUser(review.userId),
                builder: (context, snapshot2) {
                  if(snapshot2.hasData) {
                    final user = snapshot2.data;
    
                    return ListTile(
                      leading: Semantics(
                        label: 'semantics/global/profile-picture'.i18n(),
                        child: CircleAvatar(
                          backgroundImage: user!.imageUrl.isNotEmpty
                            ? NetworkImage(user.imageUrl) as ImageProvider<Object>?
                            : const AssetImage('assets/profile/profile.png'),
                        ),
                      ),
                      title: Semantics(
                        label: 'semantics/global/user-name'.i18n(),
                        child: Text(
                          user.name.isEmpty
                            ? 'review_screen/user-deleted'.i18n()
                            : user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      subtitle: Semantics(
                        label: 'semantics/review_screen/info'.i18n(),
                        child: Text(
                          "${review.comments.length.toString()} ${'review_screen/reply'.i18n()}  •  ${review.likes.length.toString()} ${'review_screen/helped'.i18n()}",
                          style: const TextStyle(
                            fontSize: 13
                          ),
                        ),
                      ),
                      trailing: Semantics(
                        onTapHint: 'semantics/review_screen/more'.i18n(),
                        child: GestureDetector(
                          onTap: () {
                            showCustomModalBottomSheet(context, isDarkMode, userId, review.userId, review.id, (reviewId) =>
                              deleteReview(reviewId)
                            );
                          },
                          child: const Icon(
                            Icons.more_vert_outlined
                          )
                        ),
                      ),
                    );
                  }
                  return const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                    ),
                    title: Text(''),
                    subtitle: Text(''),
                    trailing: Icon(
                      Icons.more_vert_outlined
                    )
                  );
                }
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Semantics(
                      label: 'semantics/review_screen/rating'.i18n(),
                      child: RatingBar.builder(
                        initialRating: review.rate,
                        ignoreGestures: true,
                        itemSize: 25,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                        ), 
                        onRatingUpdate: (rating) {},
                      ),
                    ),
                    const SizedBox(width: 5,),
                    Semantics(
                      label: 'semantics/global/time'.i18n(),
                      child: Text(
                        timeago.format(review.createdAt.toDate()),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w300
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 15,),
              Semantics(
                label: 'semantics/global/text'.i18n(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16
                  ),
                  child: Text(
                    review.text,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              if (review.imageUrl.isNotEmpty)
                Semantics(
                  label: 'semantics/global/review-image'.i18n(),
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Image.network(
                                review.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          review.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18
                ),
                child: Row(
                  children: [
                    Semantics(
                      hint: review.likes.contains(userId)
                        ? 'semantics/review_screen/dislike'.i18n()
                        : 'semantics/review_screen/like'.i18n(),
                      child: GestureDetector(
                        onTap: () {
                          if (review.likes.contains(userId)) {
                            dislikeReview(context, review.id);
                          } else {
                            likeReview(context, review.id);
                          }
                        },
                        child: review.likes.contains(userId)
                          ? Icon(
                              Icons.thumb_up_rounded,
                              size: 17,
                              color: isDarkMode ? whiteText : black,
                            )
                          : const Icon(
                              Icons.thumb_up_outlined,
                              size: 17,
                            ),
                      ),
                    ),
                    const SizedBox(width: 5,),
                    Text(review.likes.length.toString()),
                    const SizedBox(width: 15,),
                    GestureDetector(
                      onTap: () async {
                        UserFirebase? user = await readUser(review.userId);
                        if (user != null && mounted) {
                          Navigator.push(
                            context,
                            NoAnimationPageRoute(
                              builder: (context) => ReviewDetail(
                                id: review.id,
                                name: user.name,
                                text: review.text,
                                profilePicture: user.imageUrl,
                                imageUrl: review.imageUrl,
                                createdAt: review.createdAt,
                              ),
                            ),
                          );
                        }
                      },
                      child: Semantics(
                        label: 'semantics/review_screen/comment'.i18n(),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          size: 17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5,),
                    Text(review.comments.length.toString())
                  ],
                ),
              ),
              const SizedBox(height: 15,)
            ],
          ),
        ),
      ),
    );
  }
}