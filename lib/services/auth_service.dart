import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_service.dart';

// Login, Signup, Logout এর কাজ এখানে
class AuthService {
  static int? currentUserId;
  static String currentUserName = '';

  // পাসওয়ার্ড সরাসরি সেভ না করে hash করে সেভ করা হয়
  static String _hash(String email, String password) =>
      sha256.convert(utf8.encode('$email:$password')).toString();

  static Future<void> _saveSession(int id, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('uid', id);
    await prefs.setString('uname', name);
    currentUserId = id;
    currentUserName = name;
  }

  // অ্যাপ খুললে আগে লগইন করা ছিল কিনা দেখা
  static Future<bool> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('uid');
    if (id == null) return false;
    currentUserId = id;
    currentUserName = prefs.getString('uname') ?? '';
    return true;
  }

  // সফল হলে null, ভুল হলে error message ফেরত দেয়
  static Future<String?> signup(String name, String email, String password) async {
    email = email.trim().toLowerCase();
    final exists = await DatabaseService.instance.getUserByEmail(email);
    if (exists != null) return 'An account with this email already exists';

    final id = await DatabaseService.instance.insertUser(
      AppUser(name: name.trim(), email: email, password: _hash(email, password)),
    );
    await _saveSession(id, name.trim());
    return null;
  }

  static Future<String?> login(String email, String password) async {
    email = email.trim().toLowerCase();
    final user = await DatabaseService.instance.getUserByEmail(email);
    if (user == null || user.password != _hash(email, password)) {
      return 'Incorrect email or password';
    }
    await _saveSession(user.id!, user.name);
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    currentUserId = null;
    currentUserName = '';
  }
}