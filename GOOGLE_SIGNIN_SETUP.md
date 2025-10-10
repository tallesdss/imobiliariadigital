# Configuração do Google Sign-In

Este documento explica como configurar o Google Sign-In no projeto Imobiliária Digital.

## Pré-requisitos

1. Conta do Google
2. Acesso ao Google Cloud Console
3. Projeto Flutter configurado

## Passo a Passo

### 1. Configurar o Google Cloud Console

1. Acesse o [Google Cloud Console](https://console.cloud.google.com/)
2. Crie um novo projeto ou selecione um existente
3. Habilite a API do Google Sign-In:
   - Vá para "APIs & Services" > "Library"
   - Procure por "Google Sign-In API"
   - Clique em "Enable"

### 2. Configurar OAuth 2.0

1. Vá para "APIs & Services" > "Credentials"
2. Clique em "Create Credentials" > "OAuth 2.0 Client IDs"
3. Configure para cada plataforma:

#### Android
- Application type: Android
- Package name: `com.example.imobiliaria_digital` (ou seu package name)
- SHA-1 certificate fingerprint: Obtenha com o comando:
  ```bash
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  ```

#### iOS
- Application type: iOS
- Bundle ID: `com.example.imobiliariaDigital` (ou seu bundle ID)

#### Web
- Application type: Web application
- Authorized redirect URIs: Adicione as URLs necessárias

### 3. Configurar o Supabase

1. Acesse o painel do Supabase
2. Vá para "Authentication" > "Providers"
3. Habilite o Google provider
4. Adicione os Client IDs e Client Secrets obtidos no passo anterior

### 4. Atualizar o Código

1. Edite o arquivo `lib/config/google_config.dart`
2. Substitua os valores placeholder pelos seus Client IDs:
   ```dart
   static const String androidClientId = 'SEU_ANDROID_CLIENT_ID.apps.googleusercontent.com';
   static const String iosClientId = 'SEU_IOS_CLIENT_ID.apps.googleusercontent.com';
   static const String webClientId = 'SEU_WEB_CLIENT_ID.apps.googleusercontent.com';
   ```

### 5. Configurar o Android

1. Adicione o SHA-1 fingerprint no Google Cloud Console
2. O arquivo `android/app/src/main/AndroidManifest.xml` já está configurado

### 6. Configurar o iOS

1. Adicione o Bundle ID no Google Cloud Console
2. Configure o `ios/Runner/Info.plist` se necessário

## Testando

1. Execute o app
2. Tente fazer login com Google
3. Verifique se o usuário é criado no Supabase

## Troubleshooting

### Erro: "Sign in failed"
- Verifique se o SHA-1 fingerprint está correto
- Confirme se o package name está correto
- Verifique se a API está habilitada

### Erro: "Client ID not found"
- Verifique se o Client ID está correto no código
- Confirme se o projeto está ativo no Google Cloud Console

### Erro: "Invalid redirect URI"
- Verifique as URLs configuradas no Google Cloud Console
- Confirme se o domínio está correto

## Recursos Adicionais

- [Documentação do Google Sign-In](https://developers.google.com/identity/sign-in/android)
- [Documentação do Supabase Auth](https://supabase.com/docs/guides/auth)
- [Flutter Google Sign-In Plugin](https://pub.dev/packages/google_sign_in)
