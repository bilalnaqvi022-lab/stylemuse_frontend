import '../models/user_model.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final data = await ApiService.post(ApiConfig.login,
          {'email': email.trim(), 'password': password}, auth: false);
      if (data['success'] == true) {
        await ApiService.saveToken(data['token']);
        return {'success': true, 'user': UserModel.fromMap(data['user'])};
      }
      return {'success': false, 'message': data['message'] ?? 'Login failed'};
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (_) {
      return {'success': false, 'message': 'Connection failed. Is the backend running?'};
    }
  }

  Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    try {
      final data = await ApiService.post(ApiConfig.register,
          {'name': name.trim(), 'email': email.trim(), 'password': password}, auth: false);
      if (data['success'] == true) {
        await ApiService.saveToken(data['token']);
        return {'success': true, 'user': UserModel.fromMap(data['user'])};
      }
      return {'success': false, 'message': data['message'] ?? 'Signup failed'};
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (_) {
      return {'success': false, 'message': 'Connection failed. Is the backend running?'};
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      if (!await ApiService.hasToken()) return null;
      final data = await ApiService.get(ApiConfig.me);
      if (data['success'] == true) return UserModel.fromMap(data['user']);
      return null;
    } catch (_) { return null; }
  }

  Future<bool> isLoggedIn() async => ApiService.hasToken();
  Future<void> logout() async => ApiService.clearToken();

  Future<void> updateUser(UserModel user) async {
    await ApiService.put(ApiConfig.profile, {
      'name': user.name, 'bio': user.bio, 'stylePreferences': user.stylePreferences,
    });
  }
}
