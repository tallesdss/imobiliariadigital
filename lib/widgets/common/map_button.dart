import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

class MapButton extends StatelessWidget {
  final String address;
  final String city;
  final String state;
  final String? zipCode;
  final String? neighborhood;
  final String? buttonText;
  final IconData? icon;
  final bool isCompact;

  const MapButton({
    super.key,
    required this.address,
    required this.city,
    required this.state,
    this.zipCode,
    this.neighborhood,
    this.buttonText,
    this.icon,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return IconButton(
        onPressed: _openGoogleMaps,
        icon: Icon(icon ?? Icons.map_outlined),
        tooltip: buttonText ?? 'Exibir no mapa',
        style: IconButton.styleFrom(
          foregroundColor: AppTheme.primaryColor,
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: _openGoogleMaps,
      icon: Icon(icon ?? Icons.map_outlined),
      label: Text(buttonText ?? 'Exibir no mapa'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primaryColor,
        side: BorderSide(color: AppTheme.primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps() async {
    try {
      // Construir o endereço completo
      String fullAddress = address;
      if (neighborhood != null && neighborhood!.isNotEmpty) {
        fullAddress = '$fullAddress, $neighborhood';
      }
      fullAddress = '$fullAddress, $city, $state';
      if (zipCode != null && zipCode!.isNotEmpty) {
        fullAddress = '$fullAddress, $zipCode';
      }

      // Codificar o endereço para URL
      final encodedAddress = Uri.encodeComponent(fullAddress);
      
      // URLs para diferentes plataformas
      final googleMapsWebUrl = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
      final googleMapsAppUrl = 'comgooglemaps://?q=$encodedAddress';
      final appleMapsUrl = 'maps://?q=$encodedAddress';
      
      // Tentar abrir no app nativo primeiro (iOS/Android)
      if (await canLaunchUrl(Uri.parse(googleMapsAppUrl))) {
        await launchUrl(Uri.parse(googleMapsAppUrl));
      } else if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
        await launchUrl(Uri.parse(appleMapsUrl));
      } else if (await canLaunchUrl(Uri.parse(googleMapsWebUrl))) {
        // Fallback para o navegador web
        await launchUrl(
          Uri.parse(googleMapsWebUrl), 
          mode: LaunchMode.externalApplication
        );
      } else {
        debugPrint('Não foi possível abrir o Google Maps');
      }
    } catch (e) {
      debugPrint('Erro ao abrir Google Maps: $e');
    }
  }
}
