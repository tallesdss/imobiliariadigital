import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'favorite_service.dart';
import 'supabase_service.dart';
import '../models/user_model.dart' as app_user;

class AuthService extends ChangeNotifier {
  app_user.User? _currentUser;
  bool _isLoading = false;
  String? _error;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  app_user.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null && SupabaseService.isAuthenticated;

  Future<void> initialize() async {
    _setLoading(true);
    _clearError();
    
    try {
      if (kDebugMode) {
        print('AuthService: Inicializando...');
        print('AuthService: Supabase autenticado: ${SupabaseService.isAuthenticated}');
      }
      
      if (SupabaseService.isAuthenticated) {
        final userId = SupabaseService.currentUserId;
        if (kDebugMode) {
          print('AuthService: ID do usuário autenticado: $userId');
        }
        
        _currentUser = await _getUserFromSupabase();
        if (kDebugMode) {
          print('AuthService: Usuário carregado: ${_currentUser?.name}');
          print('AuthService: Tipo do usuário: ${_currentUser?.type}');
        }
      } else {
        if (kDebugMode) {
          print('AuthService: Usuário não autenticado no Supabase');
        }
        _currentUser = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Erro na inicialização: $e');
        print('AuthService: Stack trace: ${StackTrace.current}');
      }
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
      final response = await SupabaseService.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        _currentUser = await _getUserFromSupabase();
        _clearError(); // Limpar qualquer erro anterior
        notifyListeners(); // Notificar todos os listeners sobre a mudança
        return true;
      }
      return false;
    } on AuthException catch (e) {
      // Tratamento específico para erros de autenticação do Supabase
      if (e.message.contains('Invalid login credentials')) {
        _setError('E-mail ou senha incorretos.');
      } else if (e.message.contains('Email not confirmed')) {
        _setError('E-mail não confirmado. Verifique sua caixa de entrada.');
      } else if (e.message.contains('over_email_send_rate_limit')) {
        _setError('Muitas tentativas de login. Aguarde alguns minutos.');
      } else {
        _setError('Erro no login: ${e.message}');
      }
      return false;
    } catch (e) {
      _setError('Erro inesperado: $e');
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
      final response = await SupabaseService.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'phone': phone,
        },
      );
      
      if (response.user != null) {
        // Criar perfil do usuário na tabela users
        await _createUserProfile(response.user!, name, phone);
        _currentUser = await _getUserFromSupabase();
        notifyListeners();
        return true;
      }
      return false;
    } on AuthException catch (e) {
      // Tratamento específico para erros de autenticação do Supabase
      if (e.message.contains('over_email_send_rate_limit')) {
        _setError('Muitas tentativas de cadastro. Aguarde alguns minutos antes de tentar novamente.');
      } else if (e.message.contains('User already registered')) {
        _setError('Este e-mail já está cadastrado. Tente fazer login.');
      } else if (e.message.contains('Invalid email')) {
        _setError('E-mail inválido. Verifique o formato.');
      } else if (e.message.contains('Password should be at least')) {
        _setError('A senha deve ter pelo menos 6 caracteres.');
      } else {
        _setError('Erro no cadastro: ${e.message}');
      }
      return false;
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Login com Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    
    try {
      // Iniciar o processo de login com Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // Usuário cancelou o login
        return false;
      }

      // Obter os detalhes de autenticação
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Fazer login no Supabase com o token do Google
      final AuthResponse response = await SupabaseService.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user != null) {
        // Verificar se o usuário já existe na tabela users
        final existingUser = await _getUserFromSupabase();
        
        if (existingUser == null) {
          // Criar perfil do usuário se não existir
          await _createUserProfile(
            response.user!,
            googleUser.displayName ?? 'Usuário',
            null,
            photoUrl: googleUser.photoUrl,
          );
        }
        
        _currentUser = await _getUserFromSupabase();
        _clearError(); // Limpar qualquer erro anterior
        notifyListeners(); // Notificar todos os listeners sobre a mudança
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erro no login com Google: $e');
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
      final userId = SupabaseService.currentUserId;
      if (userId == null) return false;

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (photo != null) updateData['photo'] = photo;

      await SupabaseService.updateData('users', userId, updateData);
      _currentUser = await _getUserFromSupabase();
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
      await SupabaseService.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignora erros no logout
    } finally {
      _currentUser = null;
      // Limpar cache de favoritos
      await FavoriteService.clearAllCache();
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

  /// Obtém dados do usuário da tabela users do Supabase
  Future<app_user.User?> _getUserFromSupabase() async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) {
        if (kDebugMode) {
          print('AuthService: Usuário não autenticado no Supabase');
        }
        return null;
      }

      if (kDebugMode) {
        print('AuthService: Buscando dados do usuário com ID: $userId');
      }

      final userData = await SupabaseService.getDataById('users', userId);
      if (userData != null) {
        if (kDebugMode) {
          print('AuthService: Dados do usuário encontrados: $userData');
        }
        
        try {
          final user = app_user.User.fromJson(userData);
          if (kDebugMode) {
            print('AuthService: Usuário criado com sucesso: ${user.name} (${user.type})');
          }
          return user;
        } catch (parseError) {
          if (kDebugMode) {
            print('AuthService: Erro ao fazer parse dos dados do usuário: $parseError');
            print('AuthService: Dados recebidos: $userData');
          }
          _setError('Erro ao processar dados do usuário: $parseError');
          return null;
        }
      } else {
        if (kDebugMode) {
          print('AuthService: Nenhum dado encontrado na tabela users para o ID: $userId');
          print('AuthService: Verificando se o usuário existe na tabela auth.users...');
        }
        
        // Verificar se o usuário existe na tabela auth.users mas não na tabela users
        final supabaseUser = SupabaseService.currentUser;
        if (supabaseUser != null) {
          if (kDebugMode) {
            print('AuthService: Usuário existe no auth mas não na tabela users. Criando perfil...');
          }
          
          // Criar perfil do usuário se não existir
          await _createUserProfile(
            supabaseUser,
            supabaseUser.userMetadata?['name'] ?? supabaseUser.email?.split('@')[0] ?? 'Usuário',
            supabaseUser.userMetadata?['phone'],
            photoUrl: supabaseUser.userMetadata?['avatar_url'],
          );
          
          // Tentar buscar novamente
          final newUserData = await SupabaseService.getDataById('users', userId);
          if (newUserData != null) {
            return app_user.User.fromJson(newUserData);
          }
        }
        
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Erro ao buscar dados do usuário: $e');
        print('AuthService: Stack trace: ${StackTrace.current}');
      }
      _setError('Erro ao carregar dados do usuário: $e');
      return null;
    }
  }

  /// Cria perfil do usuário na tabela users
  Future<void> _createUserProfile(
    User supabaseUser,
    String name,
    String? phone, {
    String? photoUrl,
  }) async {
    try {
      final userData = {
        'id': supabaseUser.id,
        'email': supabaseUser.email,
        'name': name,
        'phone': phone,
        'photo': photoUrl,
        'type': 'buyer', // Tipo padrão
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await SupabaseService.insertData('users', userData);
    } catch (e) {
      // Log do erro mas não falha o processo
      if (kDebugMode) {
        print('Erro ao criar perfil do usuário: $e');
      }
    }
  }
}
