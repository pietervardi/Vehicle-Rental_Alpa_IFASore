import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:localization/localization.dart';
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
          SnackBar(
            content: Text('review_detail/error-posting'.i18n()),
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
          'review_detail/title'.i18n(),
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
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          ListTile(
            leading: Semantics(
              label: 'semantics/global/profile-picture'.i18n(),
              child: CircleAvatar(
                backgroundImage: NetworkImage(profilePicture)
              ),
            ),
            title: Row(
              children: [
                Semantics(
                  label: 'semantics/global/user-name'.i18n(),
                  child: Text(
                    '$name  •  ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    ),
                  ),
                ),
                Semantics(
                  label: 'semantics/global/time'.i18n(),
                  child: Text(
                    timeago.format(createdAt.toDate()),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300
                    ),
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            label: 'semantics/global/text'.i18n(),
            child: Padding(
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
          ),
          if (imageUrl.isNotEmpty)
            Semantics(
              label: 'semantics/global/review-image'.i18n(),
              child: Padding(
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
            ),
          const Divider(
            color: gray,
          ),
          StreamBuilder(
            stream: commentReference,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }
              if (snapshot.hasError) {
                Center(
                  child: Text('review_detail/error-fetching'.i18n()),
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
                    child: Semantics(
                      label: 'semantics/review_detail/answer'.i18n(),
                      child: Text(
                        "${'review_detail/answer'.i18n()} (${comments.length})",
                        style: TextStyle(
                          color: isDarkMode ? whiteText : black,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
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
                                    leading: Semantics(
                                      label: 'semantics/global/profile-picture'.i18n(),
                                      child: CircleAvatar(
                                        backgroundImage: user!.imageUrl.isNotEmpty
                                          ? NetworkImage(user.imageUrl) as ImageProvider<Object>?
                                          : const AssetImage('assets/profile/profile.png'),
                                      ),
                                    ),
                                    title: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Semantics(
                                        label: "${'semantics/global/user-name'.i18n()} and ${'semantics/global/time'.i18n()}",
                                        child: Text(
                                          '${user.name}  •  ${timeago.format(time)}',
                                          style: const TextStyle(
                                            fontSize: 14
                                          ),
                                        ),
                                      ),
                                    ),
                                    subtitle: Semantics(
                                      label: 'semantics/review_detail/user-comment'.i18n(),
                                      child: Text(
                                        comment['text'],
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                          color: isDarkMode ? whiteText : black
                                        ),
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
          const SizedBox(height: 60,)
        ],
      ),
      bottomSheet: Semantics(
        label: 'semantics/review_detail/comment-field'.i18n(),
        child: Padding(
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
                return 'review_detail/comment-empty'.i18n();
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
                        SnackBar(
                          content: Text(
                            'review_detail/comment-empty'.i18n()
                          ),
                        ),
                      );
                  }
                },
                icon: Semantics(
                  onTapHint: 'semantics/review_detail/send-button'.i18n(),
                  child: Tooltip(
                    message: 'screen_layout/tooltip/send'.i18n(),
                    child: const Icon(Icons.send_rounded)
                  ),
                ),
              ),
              contentPadding: const EdgeInsets.all(12),
              hintText: 'review_detail/write-comment'.i18n(),
              border: const UnderlineInputBorder(),
            ),
          ),
        ),
      ),
    );
  }
}