import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class User {
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  final String id;
  final String email;
  final String name;
  final String? avatar;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

final authServiceProvider = StateNotifierProvider<AuthService, User?>((ref) {
  return AuthService();
});

class AuthService extends StateNotifier<User?> {
  AuthService() : super(null) {
    _loadUser();
  }

  static const String _userKey = 'current_user';

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        final userData = json.decode(userJson) as Map<String, dynamic>;
        state = User.fromJson(userData);
      }
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  Future<void> _saveUser(User? user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (user != null) {
        final userJson = json.encode(user.toJson());
        await prefs.setString(_userKey, userJson);
      } else {
        await prefs.remove(_userKey);
      }
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      // Simulate API call - in a real app, this would call your backend
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo purposes, accept any email/password combination
      if (email.isNotEmpty && password.isNotEmpty) {
        final user = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          email: email,
          name: email.split('@')[0], // Use email prefix as name
          createdAt: DateTime.now(),
        );
        
        state = user;
        await _saveUser(user);
        return true;
      }
      return false;
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      // Simulate API call - in a real app, this would call your backend
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo purposes, accept any valid email/name/password combination
      if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
        final user = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          email: email,
          name: name,
          createdAt: DateTime.now(),
        );
        
        state = user;
        await _saveUser(user);
        return true;
      }
      return false;
    } catch (e) {
      print('Error signing up: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    state = null;
    await _saveUser(null);
  }

  bool get isSignedIn => state != null;
  User? get currentUser => state;
}
