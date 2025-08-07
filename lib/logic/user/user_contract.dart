import 'package:unstack/models/auth/user.model.dart';

abstract class IUserManagerContract {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<bool> isUserLoggedIn();
  Future<bool> deleteAccount();
  Future<void> updateUsername(String newUsername);
}
