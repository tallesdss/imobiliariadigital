import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/navigation_service.dart';

void main() {
  runApp(const ImobiliariaDigitalApp());
}

class ImobiliariaDigitalApp extends StatelessWidget {
  const ImobiliariaDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Imobiliária Digital',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: NavigationService.router,
    );
  }
}
