class UserModel {
  final String id;
  final String username;

  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.username,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> userData) {
    if (userData['username'] == null ||
        userData['username'].toString().trim().isEmpty) {
      throw Exception('Missing required username');
    }

    return UserModel(
      id: userData['id'] ?? '',
      username: userData['username'],
      createdAt: userData['createdAt'] != null
          ? DateTime.parse(userData['createdAt'])
          : null,
    );
  }

  // Keep the old method for backward compatibility during transition
  factory UserModel.fromFirebase(Map<String, dynamic> userData) {
    return UserModel.fromJson(userData);
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
