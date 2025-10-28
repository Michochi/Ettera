class User {
  final String id;
  final String name;
  final String email;
  final String? bio;
  final String? photoUrl;
  final String? gender;
  final DateTime? birthday;
  final int? age;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.bio,
    this.photoUrl,
    this.gender,
    this.birthday,
    this.age,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      bio: json['bio'],
      photoUrl: json['photoUrl'],
      gender: json['gender'],
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'])
          : null,
      age: json['age'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'bio': bio,
      'photoUrl': photoUrl,
      'gender': gender,
      'birthday': birthday?.toIso8601String(),
      'age': age,
    };
  }
}
