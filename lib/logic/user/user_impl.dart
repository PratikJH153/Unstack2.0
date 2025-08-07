import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:unstack/logic/user/user_contract.dart';
import 'package:unstack/models/auth/user.model.dart';

import 'package:unstack/utils/app_logger.dart';
import 'package:uuid/v4.dart';

class UserManager implements IUserManagerContract {
  static const String _userKey = 'user_data';
  static const String _usernameKey = 'user_name';
  static const String _isLoggedInKey = 'is_logged_in';

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_userKey, userJson);
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_usernameKey, user.username);
      AppLogger.info('User saved successfully: ${user.username}');
    } catch (e) {
      AppLogger.error('Error saving user: $e');
      throw Exception('Failed to save user data');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson == null) {
        return null;
      }

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      AppLogger.error('Error getting user: $e');
      return null;
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      AppLogger.error('Error checking login status: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_usernameKey);
      await prefs.setBool(_isLoggedInKey, false);
      AppLogger.info('Account deleted successfully');
      return true;
    } catch (e) {
      AppLogger.error('Error deleting account: $e');
      return false;
    }
  }

  @override
  Future<void> updateUsername(String newUsername) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usernameKey, newUsername);

      // Also update the user data if it exists
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        userMap['username'] = newUsername;
        await prefs.setString(_userKey, jsonEncode(userMap));
      }

      AppLogger.info('Username updated successfully: $newUsername');
    } catch (e) {
      AppLogger.error('Error updating username: $e');
      throw Exception('Failed to update username');
    }
  }

  // Helper method to get username from SharedPreferences
  Future<String?> getUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_usernameKey);
    } catch (e) {
      AppLogger.error('Error getting username: $e');
      return null;
    }
  }

  // Helper method to save username to SharedPreferences
  Future<void> saveUsername(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usernameKey, username);
      AppLogger.info('Username saved successfully: $username');
    } catch (e) {
      AppLogger.error('Error saving username: $e');
      throw Exception('Failed to save username');
    }
  }

  // Helper method to check if username exists
  Future<bool> hasUsername() async {
    try {
      final username = await getUsername();
      return username != null && username.isNotEmpty;
    } catch (e) {
      AppLogger.error('Error checking username: $e');
      return false;
    }
  }

  // Helper method to create and save a user from username
  Future<void> createUserFromUsername(String username) async {
    try {
      final user = UserModel(
        id: UuidV4().toString(),
        username: username,
        createdAt: DateTime.now(),
      );
      await saveUser(user);
      AppLogger.info('User created from username: $username');
    } catch (e) {
      AppLogger.error('Error creating user from username: $e');
      throw Exception('Failed to create user');
    }
  }
}
