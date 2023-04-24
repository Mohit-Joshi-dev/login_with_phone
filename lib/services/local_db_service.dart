import 'dart:convert';

import 'package:assessment/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDBService {
  /// saves user model in local db
  Future<bool> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = jsonEncode(user.toJson());
    return await prefs.setString('user', userData);
  }

  /// get user model from local db
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  /// delete user model from local db
  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
  }
}
