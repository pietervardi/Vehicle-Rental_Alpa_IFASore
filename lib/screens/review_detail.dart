import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_rental/models/user_firebase_model.dart';
import 'package:vehicle_rental/responsive/screen_layout.dart';
import 'package:vehicle_rental/utils/animation.dart';
import 'package:vehicle_rental/utils/colors.dart';
import 'package:vehicle_rental/utils/theme_provider.dart';

class ReviewDetail extends StatefulWidget {
  final String id;
  final String name;
  final String text;
  final String profilePicture;
  final String imageUrl;
  final Timestamp createdAt;
  const ReviewDetail({
    Key? key,
    required this.id,
    required this.name,
    required this.text,
    required this.profilePicture,
    required this.imageUrl,
    required this.createdAt,
  }) : super(key: key);

  @override
  State<ReviewDetail> createState() => _ReviewDetailState();
}

class _ReviewDetailState extends State<ReviewDetail> {
  final commentCtrl = TextEditingController();
  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    commentCtrl.dispose();
    super.dispose();
  }

  // Post Reply Comment
  Future<void> postComment(String text) async {
    try {
      await FirebaseFirestore.instance
        .collection('reviews')
        .doc(widget.id)
        .update(
      {
        'comments': FieldValue.arrayUnion([
          {
            'userId': userId,
            'text': text,
            'time': Timestamp.now(),
          }
        ])
      },
      ).then((value) => commentCtrl.clear());
    } on FirebaseException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error posting comment'),
          ),
        );
      }     
    }
  }

  // Get Single User by ID
  Stream<UserFirebase?> readUser(String id) async* {
    final docUser = FirebaseFirestore.instance.collection('users').doc(id);

    yield* docUser.snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserFirebase.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).currentTheme == 'dark';

    final String name = widget.name;
    final String text = widget.text;
    final String profilePicture = widget.profilePicture;
    final String imageUrl = widget.imageUrl;
    final Timestamp createdAt = widget.createdAt;
    
    final commentReference = FirebaseFirestore.instance
      .collection('reviews')
      .doc(widget.id)
      .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Reply',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? whiteText : black
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(profilePicture)
            ),
            title: Row(
              children: [
                Text(
                  '$name  •  ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
                ),
                Text(
                  GetTimeAgo.parse(DateTime.parse(createdAt.toDate().toString())),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 5
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 260),
            child: Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const Divider(
            color: gray,
          ),
          StreamBuilder(
            stream: commentReference,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator()
                );
              }
              if (snapshot.hasError) {
                const Center(
                  child: Text('There was an error fetching comments'),
                );
              }

              List comments = snapshot.data['comments'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    child: Text(
                      'Answer (${comments.length})',
                      style: TextStyle(
                        color: isDarkMode ? whiteText : black,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Column(
                    children: List.generate(
                      snapshot.data.data()['comments'].length,
                      (index) {
                        final comment = snapshot.data
                          .data()['comments']
                          .toList()[index];
                        DateTime time = comment['time'].toDate();
                        return Column(
                          children: [
                            StreamBuilder<UserFirebase?>(
                              stream: readUser(comment['userId']),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final user = snapshot.data;

                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: user!.imageUrl.isNotEmpty
                                        ? NetworkImage(user.imageUrl) as ImageProvider<Object>?
                                        : const AssetImage('assets/profile/profile.png'),
                                    ),
                                    title: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Text(
                                        '${user.name}  •  ${GetTimeAgo.parse(DateTime.parse(time.toString()))}',
                                        style: const TextStyle(
                                          fontSize: 14
                                        ),
                                      ),
                                    ),
                                    subtitle: Text(
                                      comment['text'],
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                        color: isDarkMode ? whiteText : black
                                      ),
                                    ),
                                  );
                                }
                                return Container();
                              }
                            ),
                            const SizedBox(height: 5,),
                            const Divider(
                              color: gray,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: commentCtrl,
          textInputAction: TextInputAction.send,
          keyboardType: TextInputType.multiline,
          maxLines: 5,
          minLines: 1,
          style: const TextStyle(
            fontSize: 17,
          ),
          validator: (text) {
            if (text == null || text.isEmpty) {
              return 'Comment is Empty!';
            }
            return null;
          },
          onFieldSubmitted: ((value) {
            if (commentCtrl.text.isNotEmpty) {
              postComment(commentCtrl.text);
              FocusScope.of(context).unfocus();
            }
          }),
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {
                if (commentCtrl.text.isNotEmpty) {
                  postComment(commentCtrl.text);
                  FocusScope.of(context).unfocus();
                } else {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Comment is Empty!'
                        ),
                      ),
                    );
                }
              },
              icon: const Icon(Icons.send_rounded),
            ),
            contentPadding: const EdgeInsets.all(12),
            hintText: "Write your comment...",
            border: const UnderlineInputBorder(),
          ),
        ),
      ),
    );
  }
}