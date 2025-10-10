class GoogleConfig {
  // Configurações do Google Sign-In
  // Para usar o Google Sign-In, você precisa:
  // 1. Criar um projeto no Google Cloud Console
  // 2. Habilitar a API do Google Sign-In
  // 3. Configurar o OAuth 2.0
  // 4. Adicionar o SHA-1 fingerprint do seu app
  
  // Para desenvolvimento, você pode usar estes valores padrão
  // Em produção, substitua pelos valores do seu projeto
  
  /// Client ID do Google (Android)
  /// Obtenha em: https://console.developers.google.com/
  static const String androidClientId = 'YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com';
  
  /// Client ID do Google (iOS)
  /// Obtenha em: https://console.developers.google.com/
  static const String iosClientId = 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com';
  
  /// Client ID do Google (Web)
  /// Obtenha em: https://console.developers.google.com/
  static const String webClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
  
  /// Scopes solicitados para o Google Sign-In
  static const List<String> scopes = [
    'email',
    'profile',
  ];
  
  /// Configurações específicas para diferentes plataformas
  static const Map<String, dynamic> platformConfig = {
    'android': {
      'clientId': androidClientId,
    },
    'ios': {
      'clientId': iosClientId,
    },
    'web': {
      'clientId': webClientId,
    },
  };
}
