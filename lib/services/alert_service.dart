import 'package:dio/dio.dart';
import '../models/favorite_model.dart';
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
}
