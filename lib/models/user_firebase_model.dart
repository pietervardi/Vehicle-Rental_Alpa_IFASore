import 'package:cloud_firestore/cloud_firestore.dart';

class UserFirebase {
  final String id;
  final String name;
  final String username;
  final String email;
  final String about;
  final String imageUrl;
  final Timestamp createdAt;

  UserFirebase({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.about,
    required this.imageUrl,
    required this.createdAt
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'email': email,
    'about': about,
    'imageUrl': imageUrl,
    'createdAt': createdAt,
  };

  static UserFirebase fromJson(Map<String, dynamic> json) => UserFirebase(
    id: json['id'],
    name: json['name'],
    username: json['username'],
    email: json['email'],
    about: json['about'],
    imageUrl: json['imageUrl'],
    createdAt: json['createdAt'],
  );
}