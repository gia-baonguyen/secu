import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_response.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final SharedPreferences _prefs;
  final ApiService _apiService;

  String? _token;
  User? _currentUser;
  bool _isLoading = false;

  AuthService(this._prefs) : _apiService = ApiService() {
    _loadToken();
  }

  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null && _currentUser != null;
  bool get isLoading => _isLoading;

  void _loadToken() {
    _token = _prefs.getString('auth_token');
    final userId = _prefs.getString('user_id');
    final username = _prefs.getString('username');
    final email = _prefs.getString('email');
    final role = _prefs.getString('role');

    if (_token != null && userId != null && username != null && role != null) {
      _currentUser = User(
        userId: userId,
        username: username,
        email: email,
        role: role,
      );
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(username, password);

      if (response.success && response.data != null) {
        _token = response.data!.accessToken;
        await _prefs.setString('auth_token', _token!);
        await _prefs.setString('user_id', response.data!.userId);
        await _prefs.setString('username', response.data!.email);
        await _prefs.setString('email', response.data!.email);
        await _prefs.setString('role', response.data!.role);

        // Load user profile
        await loadProfile();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadProfile() async {
    if (_token == null) return;

    try {
      final response = await _apiService.getProfile(_token!);
      if (response.success && response.data != null) {
        _currentUser = response.data;
        await _prefs.setString('user_id', _currentUser!.userId);
        await _prefs.setString('username', _currentUser!.username);
        if (_currentUser!.email != null) {
          await _prefs.setString('email', _currentUser!.email!);
        }
        await _prefs.setString('role', _currentUser!.role);
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      await _apiService.logout(_token!);
    }

    _token = null;
    _currentUser = null;

    await _prefs.remove('auth_token');
    await _prefs.remove('user_id');
    await _prefs.remove('username');
    await _prefs.remove('email');
    await _prefs.remove('role');

    notifyListeners();
  }
}

