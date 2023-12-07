import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  String id;
  final double rate;
  final String text;
  final String imageUrl;
  final List likes;
  final List comments;
  final String userId;
  final Timestamp createdAt;

  Review({
    this.id = '',
    required this.rate,
    required this.text,
    required this.imageUrl,
    required this.userId,
    required this.likes,
    required this.comments,
    required this.createdAt
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'rate': rate,
    'text': text,
    'imageUrl': imageUrl,
    'userId': userId,
    'likes': likes,
    'comments': comments,
    'createdAt': createdAt,
  };

  static Review fromJson(Map<String, dynamic> json) => Review(
    id: json['id'],
    rate: json['rate'],
    text: json['text'],
    imageUrl: json['imageUrl'],
    userId: json['userId'],
    likes: json['likes'],
    comments: json['comments'],
    createdAt: json['createdAt'],
  );
}