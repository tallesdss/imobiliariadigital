import 'package:dio/dio.dart';
import '../models/alert_model.dart';
import 'api_service.dart';

class AlertService {
  static Future<List<PropertyAlert>> getUserAlerts() async {
    try {
      final response = await ApiService.dio.get('/alerts');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['alerts'] ?? response.data;
        return data.map((json) => PropertyAlert.fromJson(json)).toList();
      }
      throw Exception('Erro ao carregar alertas');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // Retorna lista vazia se não encontrar alertas
      } else {
        throw Exception('Erro de conexão. Tente novamente.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  static Future<PropertyAlert> createAlert({
    required String propertyId,
    required String propertyTitle,
    required AlertType type,
    double? targetPrice,
  }) async {
    try {
      final response = await ApiService.dio.post('/alerts', data: {
        'propertyId': propertyId,
        'propertyTitle': propertyTitle,
        'type': type.name,
        'targetPrice': targetPrice,
      });
      
      if (response.statusCode == 201) {
        return PropertyAlert.fromJson(response.data);
      }
      throw Exception('Erro ao criar alerta');
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Alerta já existe para este imóvel');
      } else {
        throw Exception('Erro de conexão. Tente novamente.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  static Future<void> deleteAlert(String alertId) async {
    try {
      final response = await ApiService.dio.delete('/alerts/$alertId');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erro ao remover alerta');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Alerta não encontrado');
      } else {
        throw Exception('Erro de conexão. Tente novamente.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  static Future<void> updateAlert(String alertId, {
    AlertType? type,
    double? targetPrice,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (type != null) data['type'] = type.name;
      if (targetPrice != null) data['targetPrice'] = targetPrice;
      if (isActive != null) data['isActive'] = isActive;

      final response = await ApiService.dio.put('/alerts/$alertId', data: data);
      
      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar alerta');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Alerta não encontrado');
      } else {
        throw Exception('Erro de conexão. Tente novamente.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  /// Obtém histórico de alertas do usuário
  static Future<List<AlertHistory>> getAlertHistory({
    int limit = 50,
    int offset = 0,
    String? alertId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      
      if (alertId != null) {
        queryParams['alertId'] = alertId;
      }

      final response = await ApiService.dio.get(
        '/alerts/history',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['history'] ?? response.data;
        return data.map((json) => AlertHistory.fromMap(json)).toList();
      }
      throw Exception('Erro ao carregar histórico de alertas');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // Retorna lista vazia se não encontrar histórico
      } else {
        throw Exception('Erro de conexão. Tente novamente.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  /// Marca um item do histórico como lido
  static Future<void> markHistoryAsRead(String historyId) async {
    try {
      final response = await ApiService.dio.put('/alerts/history/$historyId/read');
      
      if (response.statusCode != 200) {
        throw Exception('Erro ao marcar como lido');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Item do histórico não encontrado');
      } else {
        throw Exception('Erro de conexão. Tente novamente.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  /// Marca todos os itens do histórico como lidos
  static Future<void> markAllHistoryAsRead() async {
    try {
      final response = await ApiService.dio.put('/alerts/history/mark-all-read');
      
      if (response.statusCode != 200) {
        throw Exception('Erro ao marcar todos como lidos');
      }
    } on DioException {
      throw Exception('Erro de conexão. Tente novamente.');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  /// Obtém estatísticas dos alertas
  static Future<Map<String, dynamic>> getAlertStats() async {
    try {
      final response = await ApiService.dio.get('/alerts/stats');
      
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Erro ao carregar estatísticas');
    } on DioException {
      throw Exception('Erro de conexão. Tente novamente.');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  /// Cria alerta para redução de preço
  static Future<PropertyAlert> createPriceDropAlert({
    required String propertyId,
    required String propertyTitle,
    required double targetPrice,
  }) async {
    return createAlert(
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      type: AlertType.priceReduction,
      targetPrice: targetPrice,
    );
  }

  /// Cria alerta para imóvel vendido
  static Future<PropertyAlert> createSoldAlert({
    required String propertyId,
    required String propertyTitle,
  }) async {
    return createAlert(
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      type: AlertType.sold,
    );
  }

  /// Cria alerta para imóvel similar
  static Future<PropertyAlert> createSimilarPropertyAlert({
    required String propertyId,
    required String propertyTitle,
    double? targetPrice,
  }) async {
    return createAlert(
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      type: AlertType.newSimilar,
      targetPrice: targetPrice,
    );
  }

  /// Verifica se há redução de preço em um imóvel
  static Future<bool> checkPriceDrop({
    required String propertyId,
    required double currentPrice,
    required double previousPrice,
  }) async {
    try {
      final response = await ApiService.dio.post('/alerts/check-price-drop', data: {
        'propertyId': propertyId,
        'currentPrice': currentPrice,
        'previousPrice': previousPrice,
      });
      
      if (response.statusCode == 200) {
        return response.data['hasPriceDrop'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Verifica se um imóvel foi vendido
  static Future<bool> checkPropertySold({
    required String propertyId,
    required String currentStatus,
  }) async {
    try {
      final response = await ApiService.dio.post('/alerts/check-sold', data: {
        'propertyId': propertyId,
        'currentStatus': currentStatus,
      });
      
      if (response.statusCode == 200) {
        return response.data['isSold'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Busca imóveis similares com mesmo preço
  static Future<List<Map<String, dynamic>>> findSimilarProperties({
    required String propertyId,
    required double price,
    required String propertyType,
    required String city,
    double priceTolerance = 0.1, // 10% de tolerância
  }) async {
    try {
      final response = await ApiService.dio.post('/alerts/find-similar', data: {
        'propertyId': propertyId,
        'price': price,
        'propertyType': propertyType,
        'city': city,
        'priceTolerance': priceTolerance,
      });
      
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['similarProperties'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Processa alertas automaticamente
  static Future<void> processAlerts() async {
    try {
      final response = await ApiService.dio.post('/alerts/process');
      
      if (response.statusCode == 200) {
        // Alertas processados com sucesso
      }
    } catch (e) {
      // Erro ao processar alertas: $e
    }
  }
}
