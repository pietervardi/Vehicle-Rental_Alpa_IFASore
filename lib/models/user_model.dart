class UserModel {
  final int? id;
  final String? name;
  final String? username;
  final String? email;
  String? password;
  String? about;

  UserModel({
    this.id, 
    this.name, 
    this.username, 
    this.email, 
    this.password,
    this.about
  });

  factory UserModel.fromMap(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    name: json['name'], 
    username: json['username'], 
    email: json['email'], 
    password: json['password'],
    about: json['about']
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'username': username,
    'email': email,
    'password': password,
    'about': about
  };
}