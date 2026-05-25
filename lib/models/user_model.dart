class UserModel {
  final String id;
  final String name;
  final String email;
  final String? bio;
  final String? avatarUrl;
  final List<String> stylePreferences;

  UserModel({required this.id, required this.name, required this.email,
      this.bio, this.avatarUrl, this.stylePreferences = const []});

  UserModel copyWith({String? id, String? name, String? email, String? bio,
      String? avatarUrl, List<String>? stylePreferences}) {
    return UserModel(id: id ?? this.id, name: name ?? this.name,
        email: email ?? this.email, bio: bio ?? this.bio,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        stylePreferences: stylePreferences ?? this.stylePreferences);
  }

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'email': email,
      'bio': bio, 'avatarUrl': avatarUrl, 'stylePreferences': stylePreferences};

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
      id: map['id'] ?? '', name: map['name'] ?? '', email: map['email'] ?? '',
      bio: map['bio'], avatarUrl: map['avatarUrl'],
      stylePreferences: List<String>.from(map['stylePreferences'] ?? []));
}
