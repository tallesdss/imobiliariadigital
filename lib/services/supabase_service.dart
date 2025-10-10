import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  /// Inicializa o Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  /// Verifica se o usuário está autenticado
  static bool get isAuthenticated => client.auth.currentUser != null;

  /// Obtém o usuário atual
  static User? get currentUser => client.auth.currentUser;

  /// Obtém o ID do usuário atual
  static String? get currentUserId => currentUser?.id;

  /// Faz login com email e senha
  static Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Registra um novo usuário
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  /// Faz logout
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Obtém dados de uma tabela
  static Future<List<Map<String, dynamic>>> getTableData(
    String tableName, {
    String? select,
  }) async {
    return await client.from(tableName).select(select ?? '*');
  }

  /// Obtém dados de uma tabela com filtros
  static Future<List<Map<String, dynamic>>> getTableDataWithFilters(
    String tableName,
    Map<String, dynamic> filters, {
    String? select,
  }) async {
    var query = client.from(tableName).select(select ?? '*');
    
    for (var entry in filters.entries) {
      query = query.eq(entry.key, entry.value);
    }
    
    return await query;
  }

  /// Insere dados em uma tabela
  static Future<List<Map<String, dynamic>>> insertData(
    String tableName,
    Map<String, dynamic> data,
  ) async {
    return await client.from(tableName).insert(data).select();
  }

  /// Atualiza dados em uma tabela
  static Future<List<Map<String, dynamic>>> updateData(
    String tableName,
    String id,
    Map<String, dynamic> data,
  ) async {
    return await client.from(tableName).update(data).eq('id', id).select();
  }

  /// Remove dados de uma tabela
  static Future<void> deleteData(String tableName, String id) async {
    await client.from(tableName).delete().eq('id', id);
  }

  /// Obtém dados por ID
  static Future<Map<String, dynamic>?> getDataById(
    String tableName,
    String id,
  ) async {
    final result = await client.from(tableName).select().eq('id', id).single();
    return result;
  }

  /// Escuta mudanças em tempo real em uma tabela
  static RealtimeChannel listenToTable(
    String tableName,
    void Function(PostgresChangePayload) callback,
  ) {
    return client
        .channel('public:$tableName')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: tableName,
          callback: callback,
        )
        .subscribe();
  }

  /// Para de escutar mudanças em tempo real
  static Future<void> stopListening(RealtimeChannel channel) async {
    await client.removeChannel(channel);
  }
}