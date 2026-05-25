import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  final AuthService _authService = AuthService();

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  Future<void> checkAuthStatus() async {
    _isLoading = true; notifyListeners();
    _currentUser = await _authService.getCurrentUser();
    _isLoading = false; notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true; _error = null; notifyListeners();
    final result = await _authService.login(email, password);
    _isLoading = false;
    if (result['success'] == true) {
      _currentUser = result['user'] as UserModel;
      notifyListeners(); return true;
    }
    _error = result['message'] as String;
    notifyListeners(); return false;
  }

  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true; _error = null; notifyListeners();
    final result = await _authService.signup(name, email, password);
    _isLoading = false;
    if (result['success'] == true) {
      _currentUser = result['user'] as UserModel;
      notifyListeners(); return true;
    }
    _error = result['message'] as String;
    notifyListeners(); return false;
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null; _error = null; notifyListeners();
  }

  Future<void> updateProfile({String? name, String? bio, List<String>? stylePreferences}) async {
    if (_currentUser == null) return;
    _isLoading = true; notifyListeners();
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (bio != null) updates['bio'] = bio;
      if (stylePreferences != null) updates['stylePreferences'] = stylePreferences;

      final data = await ApiService.put(ApiConfig.profile, updates);
      // Refresh user from API response
      if (data['user'] != null) {
        _currentUser = UserModel.fromMap(data['user']);
      } else {
        // Apply locally
        _currentUser = _currentUser!.copyWith(name: name, bio: bio, stylePreferences: stylePreferences);
      }
    } catch (_) {
      // Apply locally on failure
      _currentUser = _currentUser!.copyWith(name: name, bio: bio, stylePreferences: stylePreferences);
    }
    _isLoading = false; notifyListeners();
  }

  void clearError() { _error = null; notifyListeners(); }
}
