import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/search_model.dart';
import '../models/property_model.dart';

class LocationService {
  static const double _defaultRadius = 10.0; // km
  static const int _maxResults = 100;

  /// Verifica se o serviço de localização está habilitado
  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao verificar serviço de localização: $e');
      }
      return false;
    }
  }

  /// Verifica permissões de localização
  static Future<LocationPermission> checkLocationPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao verificar permissão: $e');
      }
      return LocationPermission.denied;
    }
  }

  /// Solicita permissão de localização
  static Future<LocationPermission> requestLocationPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao solicitar permissão: $e');
      }
      return LocationPermission.denied;
    }
  }

  /// Obtém a localização atual do usuário
  static Future<LocationData?> getCurrentLocation() async {
    try {
      // Verificar se o serviço está habilitado
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Serviço de localização desabilitado');
      }

      // Verificar permissões
      LocationPermission permission = await checkLocationPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestLocationPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização negada permanentemente');
      }

      // Obter posição atual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Fazer geocoding reverso para obter endereço
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          address: _formatAddress(placemark),
          city: placemark.locality ?? '',
          state: placemark.administrativeArea ?? '',
          zipCode: placemark.postalCode ?? '',
          neighborhood: placemark.subLocality ?? placemark.locality,
        );
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: 'Localização atual',
        city: '',
        state: '',
        zipCode: '',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao obter localização: $e');
      }
      return null;
    }
  }

  /// Formata endereço a partir do placemark
  static String _formatAddress(Placemark placemark) {
    final parts = <String>[];
    
    if (placemark.street != null && placemark.street!.isNotEmpty) {
      parts.add(placemark.street!);
    }
    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      parts.add(placemark.subLocality!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
      parts.add(placemark.administrativeArea!);
    }
    
    return parts.join(', ');
  }

  /// Busca endereço por texto (geocoding)
  static Future<List<LocationData>> searchAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      final results = <LocationData>[];

      for (final location in locations) {
        final placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          results.add(LocationData(
            latitude: location.latitude,
            longitude: location.longitude,
            address: _formatAddress(placemark),
            city: placemark.locality ?? '',
            state: placemark.administrativeArea ?? '',
            zipCode: placemark.postalCode ?? '',
            neighborhood: placemark.subLocality ?? placemark.locality,
          ));
        }
      }

      return results;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro na busca de endereço: $e');
      }
      return [];
    }
  }

  /// Calcula distância entre duas coordenadas
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // em km
  }

  /// Obtém imóveis próximos a uma localização
  static Future<List<PropertyWithDistance>> getNearbyProperties(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      // Em uma implementação real, isso seria uma consulta otimizada no banco
      // Por enquanto, simulamos com dados mockados
      final nearbyProperties = <PropertyWithDistance>[];
      
      // Simular propriedades próximas
      for (int i = 0; i < 20; i++) {
        final offsetLat = (Random().nextDouble() - 0.5) * 0.1; // ~5km
        final offsetLon = (Random().nextDouble() - 0.5) * 0.1;
        
        final propertyLat = latitude + offsetLat;
        final propertyLon = longitude + offsetLon;
        
        final distance = calculateDistance(latitude, longitude, propertyLat, propertyLon);
        
        if (distance <= radiusKm) {
          // Simular propriedade
          final property = _createMockProperty(propertyLat, propertyLon, i);
          nearbyProperties.add(PropertyWithDistance(
            property: property,
            distance: distance,
          ));
        }
      }
      
      // Ordenar por distância
      nearbyProperties.sort((a, b) => a.distance.compareTo(b.distance));
      
      return nearbyProperties.take(_maxResults).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao obter propriedades próximas: $e');
      }
      return [];
    }
  }

  /// Cria propriedade mockada para teste
  static Property _createMockProperty(double lat, double lon, int index) {
    // Esta é uma implementação mockada - em produção viria do banco
    return Property(
      id: 'mock_$index',
      title: 'Imóvel ${index + 1}',
      description: 'Descrição do imóvel ${index + 1}',
      price: 200000 + (index * 50000),
      type: PropertyType.values[index % PropertyType.values.length],
      status: PropertyStatus.active,
      transactionType: PropertyTransactionType.sale,
      address: 'Rua Mock ${index + 1}, ${index + 100}',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '01234-${index.toString().padLeft(3, '0')}',
      photos: [],
      videos: [],
      attributes: {
        'bedrooms': 2 + (index % 3),
        'bathrooms': 1 + (index % 2),
        'area': 50.0 + (index * 10),
        'parking_spaces': index % 2,
      },
      realtorId: 'realtor_${index % 5}',
      realtorName: 'Corretor ${index % 5 + 1}',
      realtorPhone: '(11) 99999-${index.toString().padLeft(4, '0')}',
      adminContact: 'admin@imobiliaria.com',
      createdAt: DateTime.now().subtract(Duration(days: index)),
      updatedAt: DateTime.now().subtract(Duration(days: index)),
    );
  }

  /// Obtém pontos de interesse próximos
  static Future<List<PointOfInterest>> getNearbyPointsOfInterest(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      // Em uma implementação real, isso usaria APIs como Google Places
      // Por enquanto, simulamos com dados mockados
      final pois = <PointOfInterest>[];
      
      final poiTypes = [
        'Escola', 'Hospital', 'Shopping', 'Supermercado', 'Farmácia',
        'Banco', 'Posto de Gasolina', 'Parque', 'Restaurante', 'Academia'
      ];
      
      for (int i = 0; i < 15; i++) {
        final offsetLat = (Random().nextDouble() - 0.5) * 0.05; // ~2.5km
        final offsetLon = (Random().nextDouble() - 0.5) * 0.05;
        
        final poiLat = latitude + offsetLat;
        final poiLon = longitude + offsetLon;
        
        final distance = calculateDistance(latitude, longitude, poiLat, poiLon);
        
        if (distance <= radiusKm) {
          pois.add(PointOfInterest(
            name: '${poiTypes[i % poiTypes.length]} ${i + 1}',
            type: poiTypes[i % poiTypes.length],
            latitude: poiLat,
            longitude: poiLon,
            distance: distance,
            address: 'Endereço do ${poiTypes[i % poiTypes.length]} ${i + 1}',
          ));
        }
      }
      
      // Ordenar por distância
      pois.sort((a, b) => a.distance.compareTo(b.distance));
      
      return pois.take(20).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao obter pontos de interesse: $e');
      }
      return [];
    }
  }

  /// Calcula rota entre duas localizações
  static Future<RouteInfo?> calculateRoute(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) async {
    try {
      // Em uma implementação real, isso usaria APIs como Google Directions
      // Por enquanto, simulamos com cálculo de distância em linha reta
      
      final distance = calculateDistance(startLat, startLon, endLat, endLon);
      final estimatedTime = (distance * 2).round(); // ~2 min por km
      
      return RouteInfo(
        distance: distance,
        estimatedTime: estimatedTime,
        polyline: _generateMockPolyline(startLat, startLon, endLat, endLon),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao calcular rota: $e');
      }
      return null;
    }
  }

  /// Gera polyline mockada
  static String _generateMockPolyline(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    // Em uma implementação real, isso viria da API de rotas
    // Por enquanto, retornamos uma polyline simples
    return 'mock_polyline_${startLat}_${startLon}_${endLat}_${endLon}';
  }

  /// Obtém informações de trânsito
  static Future<TrafficInfo?> getTrafficInfo(
    double latitude,
    double longitude,
  ) async {
    try {
      // Em uma implementação real, isso usaria APIs de trânsito
      // Por enquanto, simulamos
      
      final trafficLevel = Random().nextInt(5); // 0-4
      final delay = trafficLevel * 2; // 0-8 minutos de atraso
      
      return TrafficInfo(
        level: trafficLevel,
        delay: delay,
        description: _getTrafficDescription(trafficLevel),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao obter informações de trânsito: $e');
      }
      return null;
    }
  }

  /// Obtém descrição do nível de trânsito
  static String _getTrafficDescription(int level) {
    switch (level) {
      case 0:
        return 'Trânsito livre';
      case 1:
        return 'Trânsito fluido';
      case 2:
        return 'Trânsito moderado';
      case 3:
        return 'Trânsito lento';
      case 4:
        return 'Trânsito congestionado';
      default:
        return 'Informação não disponível';
    }
  }
}

/// Classe para propriedade com distância
class PropertyWithDistance {
  final Property property;
  final double distance;

  const PropertyWithDistance({
    required this.property,
    required this.distance,
  });
}

/// Classe para ponto de interesse
class PointOfInterest {
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final double distance;
  final String address;

  const PointOfInterest({
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.address,
  });
}

/// Classe para informações de rota
class RouteInfo {
  final double distance; // em km
  final int estimatedTime; // em minutos
  final String polyline;

  const RouteInfo({
    required this.distance,
    required this.estimatedTime,
    required this.polyline,
  });
}

/// Classe para informações de trânsito
class TrafficInfo {
  final int level; // 0-4
  final int delay; // em minutos
  final String description;

  const TrafficInfo({
    required this.level,
    required this.delay,
    required this.description,
  });
}
