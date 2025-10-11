import 'package:flutter/foundation.dart';
import '../models/realtor_model.dart';
import 'supabase_service.dart';
import '../config/supabase_config.dart';

class RealtorService {
  /// Busca todos os corretores ativos
  static Future<List<Realtor>> getActiveRealtors() async {
    try {
      final response = await SupabaseService.client
          .from(SupabaseConfig.realtorsTable)
          .select('*')
          .eq('is_active', true)
          .order('name');
      
      return response.map((json) => Realtor.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao carregar corretores: $e');
      }
      throw Exception('Erro de conexão. Tente novamente.');
    }
  }

  /// Busca todos os corretores (ativos e inativos)
  static Future<List<Realtor>> getAllRealtors() async {
    try {
      final response = await SupabaseService.client
          .from(SupabaseConfig.realtorsTable)
          .select('*')
          .order('name');
      
      return response.map((json) => Realtor.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao carregar todos os corretores: $e');
      }
      throw Exception('Erro de conexão. Tente novamente.');
    }
  }

  /// Busca um corretor por ID
  static Future<Realtor?> getRealtorById(String id) async {
    try {
      final response = await SupabaseService.client
          .from(SupabaseConfig.realtorsTable)
          .select('*')
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      return Realtor.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao buscar corretor por ID: $e');
      }
      return null;
    }
  }

  /// Cria um novo corretor
  static Future<Realtor> createRealtor(Realtor realtor) async {
    try {
      final response = await SupabaseService.client
          .from(SupabaseConfig.realtorsTable)
          .insert(realtor.toJson())
          .select()
          .single();
      
      return Realtor.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao criar corretor: $e');
      }
      throw Exception('Erro ao criar corretor. Tente novamente.');
    }
  }

  /// Atualiza um corretor existente
  static Future<Realtor> updateRealtor(Realtor realtor) async {
    try {
      final response = await SupabaseService.client
          .from(SupabaseConfig.realtorsTable)
          .update(realtor.toJson())
          .eq('id', realtor.id)
          .select()
          .single();
      
      return Realtor.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao atualizar corretor: $e');
      }
      throw Exception('Erro ao atualizar corretor. Tente novamente.');
    }
  }

  /// Desativa um corretor
  static Future<void> deactivateRealtor(String id) async {
    try {
      await SupabaseService.client
          .from(SupabaseConfig.realtorsTable)
          .update({'is_active': false})
          .eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao desativar corretor: $e');
      }
      throw Exception('Erro ao desativar corretor. Tente novamente.');
    }
  }

  /// Ativa um corretor
  static Future<void> activateRealtor(String id) async {
    try {
      await SupabaseService.client
          .from(SupabaseConfig.realtorsTable)
          .update({'is_active': true})
          .eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao ativar corretor: $e');
      }
      throw Exception('Erro ao ativar corretor. Tente novamente.');
    }
  }

  /// Busca estatísticas dos corretores
  static Future<Map<String, dynamic>> getRealtorStats() async {
    try {
      final response = await SupabaseService.client
          .from(SupabaseConfig.realtorsTable)
          .select('id, is_active, total_properties, sold_properties');
      
      final realtors = response.map((row) => {
        'is_active': row['is_active'] as bool? ?? true,
        'total_properties': row['total_properties'] as int? ?? 0,
        'sold_properties': row['sold_properties'] as int? ?? 0,
      }).toList();
      
      return {
        'total': realtors.length,
        'active': realtors.where((r) => r['is_active'] == true).length,
        'inactive': realtors.where((r) => r['is_active'] == false).length,
        'total_properties': realtors.fold(0, (sum, r) => sum + (r['total_properties'] as int)),
        'total_sold': realtors.fold(0, (sum, r) => sum + (r['sold_properties'] as int)),
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao carregar estatísticas dos corretores: $e');
      }
      throw Exception('Erro ao carregar estatísticas. Tente novamente.');
    }
  }
}
