import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/navigation_service.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar serviços
  await ApiService.initialize();
  
  runApp(const ImobiliariaDigitalApp());
}

class ImobiliariaDigitalApp extends StatelessWidget {
  const ImobiliariaDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp.router(
        title: 'Imobiliária Digital',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: NavigationService.router,
      ),
    );
  }
}
