// Model for user profiles in matching system
class ProfileModel {
  final String id;
  final String name;
  final int age;
  final String? bio;
  final String? photoUrl;
  final String? location;
  final List<String> interests;

  ProfileModel({
    required this.id,
    required this.name,
    required this.age,
    this.bio,
    this.photoUrl,
    this.location,
    this.interests = const [],
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? 'Unknown',
      age: json['age'] ?? 18,
      bio: json['bio'],
      photoUrl: json['photoUrl'],
      location: json['location'],
      interests: json['interests'] != null
          ? List<String>.from(json['interests'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'bio': bio,
      'photoUrl': photoUrl,
      'location': location,
      'interests': interests,
    };
  }
}
