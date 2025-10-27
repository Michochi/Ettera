class User {
  final String id;
  final String name;
  final String email;
  final String? bio;
  final String? photoUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.bio,
    this.photoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      bio: json['bio'],
      photoUrl: json['photoUrl'],
    );
  }
}
