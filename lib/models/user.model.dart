import '../models/subscription.model.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final SubscriptionModel subscription;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.subscription,
    required this.createdAt,
  });

  factory UserModel.fromFirebase(Map<String, dynamic> userData) {
    if (userData['uid'] == null || userData['email'] == null) {
      throw Exception('Missing required user data');
    }
    final SubscriptionModel subscription = SubscriptionModel();
    return UserModel(
      uid: userData['uid'],
      email: userData['email'],
      username: userData['username'] ?? 'Anonymous',
      subscription: subscription,
      createdAt: userData['createdAt'] != null
          ? DateTime.parse(userData['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'subscription': subscription.toJson(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? photoURL,
    String? username,
    SubscriptionModel? subscription,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      subscription: subscription ?? this.subscription,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
