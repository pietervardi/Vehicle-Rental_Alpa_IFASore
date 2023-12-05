import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_rental/models/review_model.dart';
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

  Stream<List<Review>> readReviews() => FirebaseFirestore.instance
    .collection('reviews')
    .orderBy('createdAt', descending: true)
    .snapshots()
    .map((snapshot) => snapshot.docs.map(
      (doc) => Review.fromJson(doc.data())).toList()
    );

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
          const SnackBar(
            content: Text('Error liking post'),
          ),
        );
      }
    }
  }

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
          const SnackBar(
            content: Text('Error disliking post'),
          ),
        );
      }
    }
  }

  Future<void> deleteReview(String id) async {
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
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator()
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData) {
            final reviews = snapshot.data!;
            double averageRating = calculateAverageRating(reviews);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10
                  ),
                  child: Text(
                    'App Review',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 25
                    ),
                  ),
                ),
                Padding(
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
                        'from ${snapshot.data!.length} people',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400
                        ),
                      ),
                    ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(context, NoAnimationPageRoute(
            builder: (context) => const ReviewForm(),
          ));
        },
        child: const Icon(Icons.add_outlined),
      ),
    );
  }

  Widget buildReview(Review review) {
    final isDarkMode = Provider.of<ThemeProvider>(context).currentTheme == 'dark';

    return InkWell(
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        Navigator.push(
          context,
          NoAnimationPageRoute(
            builder: ((context) => ReviewDetail(
              id: review.id,
              name: review.name,
              text: review.text,
              imageUrl: review.imageUrl,
              createdAt: review.createdAt,
            )),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const CircleAvatar(
                backgroundImage: AssetImage('assets/profile/profile.png')
              ),
              title: Text(
                review.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              subtitle: Text(
                '${review.comments.length.toString()} reply  •  ${review.likes.length.toString()} helped',
                style: const TextStyle(
                  fontSize: 13
                ),
              ),
              trailing: GestureDetector(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  RatingBar.builder(
                    initialRating: review.rate,
                    ignoreGestures: true,
                    itemSize: 25,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                    ), 
                    onRatingUpdate: (rating) {},
                  ),
                  const SizedBox(width: 5,),
                  Text(
                    GetTimeAgo.parse(DateTime.parse(review.createdAt.toDate().toString())),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 15,),
            Padding(
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
            const SizedBox(height: 20,),
            Container(
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
            const SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18
              ),
              child: Row(
                children: [
                  GestureDetector(
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
                  const SizedBox(width: 5,),
                  Text(review.likes.length.toString()),
                  const SizedBox(width: 15,),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        NoAnimationPageRoute(
                          builder: ((context) => ReviewDetail(
                            id: review.id,
                            name: review.name,
                            text: review.text,
                            imageUrl: review.imageUrl,
                            createdAt: review.createdAt,
                          )),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      size: 17,
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
    );
  }
}