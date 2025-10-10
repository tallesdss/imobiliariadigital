import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api'; // Ajuste conforme sua API
  static late Dio _dio;
  static String? _authToken;

  // Getter para expor o Dio para outros serviços
  static Dio get dio => _dio;

  static Future<void> initialize() async {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Interceptor para adicionar token de autenticação
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expirado ou inválido
          _clearAuthToken();
        }
        handler.next(error);
      },
    ));

    // Carregar token salvo
    await _loadAuthToken();
  }

  static Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  static Future<void> _saveAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> _clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['token'] != null) {
          await _saveAuthToken(data['token']);
        }
        return data;
      }
      throw Exception('Erro no login');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('E-mail ou senha incorretos');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Usuário não encontrado');
      } else {
        throw Exception('Erro de conexão. Tente novamente.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      });

      if (response.statusCode == 201) {
        final data = response.data;
        if (data['token'] != null) {
          await _saveAuthToken(data['token']);
        }
        return data;
      }
      throw Exception('Erro no registro');
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('E-mail já cadastrado');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Dados inválidos');
      } else {
        throw Exception('Erro de conexão. Tente novamente.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  static Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me');
      
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      throw Exception('Erro ao carregar dados do usuário');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else {
        throw Exception('Erro ao carregar dados do usuário');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  static Future<User> updateUser({
    String? name,
    String? phone,
    String? photo,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (photo != null) data['photo'] = photo;

      final response = await _dio.put('/users/update', data: data);
      
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      throw Exception('Erro ao atualizar dados do usuário');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Dados inválidos');
      } else {
        throw Exception('Erro ao atualizar dados do usuário');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  static Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      // Ignora erros no logout
    } finally {
      await _clearAuthToken();
    }
  }

  static bool get isAuthenticated => _authToken != null;
}
