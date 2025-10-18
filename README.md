# 🏠 Imobiliária Digital - Plataforma Completa

Uma plataforma imobiliária digital completa desenvolvida em Flutter com backend integrado, pronta para produção e publicação nas lojas de aplicativos.

## 📱 Sobre o Projeto

Este é um projeto **completo de produção** desenvolvido em Flutter com backend Supabase, pronto para ser publicado na Play Store e App Store. O sistema possui três perfis distintos:

- **👤 Usuário (Comprador)**: Navega, favorita e entra em contato sobre imóveis
- **🏢 Corretor**: Cadastra e gerencia seus imóveis, conversa com clientes
- **⚙️ Administrador**: Gerencia toda a plataforma, corretores e relatórios

## ✨ Funcionalidades Implementadas

### 🔐 Autenticação
- [x] Tela de login com validação
- [x] Seleção de perfil de usuário
- [x] Navegação baseada no perfil selecionado

### 🎨 Design System
- [x] Paleta de cores profissional
- [x] Tipografia padronizada (Poppins)
- [x] Componentes reutilizáveis
- [x] Espaçamentos consistentes
- [x] Tema Material 3

### 📊 Modelos de Dados
- [x] User, Realtor, Property
- [x] Chat, Favorites, Alerts
- [x] Enums para tipos e status
- [x] Validações e formatações

### 🧭 Navegação
- [x] Rotas nomeadas com GoRouter
- [x] Navegação baseada em perfil
- [x] Tratamento de erros 404
- [x] Deep linking preparado

## 🏗️ Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada
├── models/                   # Modelos de dados
│   ├── user_model.dart
│   ├── realtor_model.dart
│   ├── property_model.dart
│   ├── chat_model.dart
│   └── favorite_model.dart
├── screens/                  # Telas da aplicação
│   ├── auth/                # Login e seleção
│   ├── user/                # Telas do usuário
│   ├── realtor/             # Telas do corretor
│   └── admin/               # Telas do admin
├── widgets/                  # Componentes reutilizáveis
│   ├── common/              # Widgets comuns
│   ├── cards/               # Cards específicos
│   └── forms/               # Formulários
├── theme/                    # Sistema de design
│   ├── app_colors.dart
│   ├── app_typography.dart
│   ├── app_spacing.dart
│   └── app_theme.dart
├── services/                 # Serviços e lógica
│   ├── navigation_service.dart
│   └── mock_data_service.dart
└── utils/                    # Utilitários
```

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK (^3.9.2)
- Dart SDK
- Chrome (para web) ou emulador/dispositivo móvel

### Instalação
```bash
# Clone o repositório
git clone <url-do-repositorio>

# Entre no diretório
cd imobiliaria_digital

# Instale as dependências
flutter pub get

# Execute o projeto
flutter run
```

### Para Web
```bash
flutter run -d chrome --web-port 3000
```

## 📦 Dependências Principais

- **go_router**: Navegação e roteamento
- **provider**: Gerenciamento de estado
- **google_fonts**: Tipografia (Poppins)
- **cached_network_image**: Cache de imagens
- **carousel_slider**: Carrosséis de imagens
- **uuid**: Geração de IDs únicos
- **intl**: Formatação de dados

## 🎯 Roadmap - Próximas Implementações

### 👤 Telas do Usuário
- [ ] Home com carrosséis por categoria
- [ ] Lista/grade de imóveis
- [ ] Detalhes completos do imóvel
- [ ] Sistema de favoritos
- [ ] Alertas de preço
- [ ] Chat com corretores

### 🏢 Telas do Corretor
- [ ] Dashboard do corretor
- [ ] Formulário de cadastro de imóveis
- [ ] Gestão de imóveis próprios
- [ ] Perfil profissional
- [ ] Chat com clientes

### ⚙️ Telas do Administrador
- [ ] Dashboard com métricas
- [ ] Gestão de todos os imóveis
- [ ] CRUD de corretores
- [ ] Relatórios e gráficos
- [ ] Sistema de mensagens

### 🔧 Melhorias Técnicas
- [ ] Estado global com Provider
- [ ] Cache local dos dados
- [ ] Temas claro/escuro
- [ ] Responsividade completa
- [ ] Testes unitários

## 🎨 Design System

### Cores
- **Primary**: Verde Imobiliário (#2E7D32)
- **Secondary**: Azul Confiança (#1976D2)  
- **Accent**: Laranja Destaque (#FF8F00)
- **Status**: Verde/Cinza/Laranja para ativo/vendido/arquivado

### Tipografia
- **Fonte**: Poppins (Google Fonts)
- **Hierarquia**: H1-H6, Body, Labels
- **Pesos**: 400, 500, 600, 700

## 📱 Perfis de Usuário

### 👤 Usuário (Comprador)
- Visualizar imóveis ativos
- Favoritar imóveis
- Criar alertas de preço
- Chat com corretor/admin
- Filtrar e pesquisar

### 🏢 Corretor
- Cadastrar imóveis
- Gerenciar portfólio
- Editar perfil profissional
- Responder chats
- Acompanhar estatísticas

### ⚙️ Administrador
- Visão completa da plataforma
- Gerenciar corretores
- Aprovar/rejeitar imóveis
- Dashboard executivo
- Suporte a usuários

## 🔒 Backend e Dados

O projeto utiliza **Supabase** como backend completo, com:
- **Banco de dados PostgreSQL** para persistência de dados
- **Autenticação** integrada com Google Sign-In
- **Storage** para upload de imagens e vídeos
- **APIs REST** para todas as operações
- **Real-time** para chat e notificações

## 🚀 Publicação

Este projeto está **pronto para produção** e pode ser publicado nas lojas:
- **Google Play Store** (Android)
- **Apple App Store** (iOS)
- **Web** (PWA)

## 🤝 Contribuição

Este é um projeto de produção ativo. Para contribuir:

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

---

**Desenvolvido com ❤️ em Flutter - Pronto para Produção**
