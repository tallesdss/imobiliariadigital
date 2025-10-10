import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null && ApiService.isAuthenticated;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      if (ApiService.isAuthenticated) {
        _currentUser = await ApiService.getCurrentUser();
      }
    } catch (e) {
      _setError('Erro ao carregar dados do usuário: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await ApiService.login(
        email: email,
        password: password,
      );
      
      if (response['user'] != null) {
        _currentUser = User.fromJson(response['user']);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await ApiService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      
      if (response['user'] != null) {
        _currentUser = User.fromJson(response['user']);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? photo,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final updatedUser = await ApiService.updateUser(
        name: name,
        phone: phone,
        photo: photo,
      );
      
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await ApiService.logout();
    } catch (e) {
      // Ignora erros no logout
    } finally {
      _currentUser = null;
      _setLoading(false);
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
