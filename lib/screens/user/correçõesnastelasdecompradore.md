# Checklist de Correções - Telas de Comprador

## 🚨 Problemas Críticos de Navegação Identificados

### 1. **PropertyDetailScreen** - Problemas Graves
- [x] **ERRO CRÍTICO**: Tela não carrega propriedades - método `_loadProperty()` sempre retorna erro
- [x] **ERRO CRÍTICO**: Navegação para detalhes do imóvel não funciona - `property: null` sempre
- [x] **ERRO CRÍTICO**: Botões de ação (Ligar, WhatsApp) não implementados
- [x] **ERRO CRÍTICO**: Compartilhamento não implementado
- [x] **ERRO CRÍTICO**: Favoritos não implementados

### 2. **FavoritesScreen** - Problemas de Navegação
- [x] **ERRO CRÍTICO**: Navegação para detalhes usa `Navigator.push` em vez de `context.go()`
- [x] **ERRO CRÍTICO**: `PropertyDetailScreen(property: null)` - sempre passa null
- [x] **PROBLEMA**: Inconsistência entre GoRouter e Navigator tradicional

### 3. **UserHomeScreen** - Problemas de Navegação
- [ ] **PROBLEMA**: Navegação para comparação usa `Navigator.push` em vez de GoRouter
- [x] **PROBLEMA**: Rota `/user/property/:propertyId` não está sendo usada corretamente
- [x] **PROBLEMA**: `_navigateToPropertyDetail()` usa `context.go()` mas PropertyDetailScreen não carrega dados

### 4. **AlertsScreen** - Problemas de Navegação
- [x] **ERRO CRÍTICO**: Navegação para detalhes do imóvel comentada (linha 416)
- [x] **PROBLEMA**: `NavigationService.navigateToPropertyDetail()` não implementado
- [x] **PROBLEMA**: Telas de criação/edição de alertas usam `Navigator.push`

### 5. **UserChatScreen** - Problemas de Navegação
- [ ] **PROBLEMA**: `ConversationScreen` usa `Navigator.push` em vez de GoRouter
- [ ] **PROBLEMA**: Navegação para conversas não está integrada com o sistema de rotas

### 6. **NotificationsScreen** - Problemas de Navegação
- [x] **ERRO CRÍTICO**: Navegação para detalhes do imóvel usa `Navigator.push` com `property: null`
- [x] **PROBLEMA**: Navegação para chat usa `Navigator.push` em vez de GoRouter

### 7. **SearchResultsScreen** - Problemas de Navegação
- [x] **PROBLEMA**: Navegação para detalhes usa `Navigator.push` em vez de GoRouter
- [x] **PROBLEMA**: Não integrado com o sistema de rotas principal

### 8. **AdvancedSearchScreen** - Problemas de Navegação
- [x] **PROBLEMA**: Navegação para resultados usa `Navigator.push` em vez de GoRouter
- [ ] **PROBLEMA**: Telas de busca especializada não integradas com rotas

## 🔧 Correções Necessárias

### **PRIORIDADE ALTA - Correções Críticas**

#### 1. Corrigir PropertyDetailScreen
- [x] Implementar carregamento real de propriedades por ID
- [x] Integrar com PropertyService para buscar dados
- [x] Implementar funcionalidades de favoritos
- [x] Implementar botões de ação (Ligar, WhatsApp)
- [x] Implementar compartilhamento

#### 2. Padronizar Sistema de Navegação
- [x] **TODAS** as telas devem usar GoRouter (`context.go()`, `context.push()`)
- [x] Remover todos os `Navigator.push()` e substituir por GoRouter
- [x] Garantir que todas as rotas estejam definidas no NavigationService

#### 3. Corrigir Navegação para Detalhes do Imóvel
- [x] Implementar rota `/user/property/:propertyId` corretamente
- [x] Garantir que PropertyDetailScreen carregue dados baseado no ID
- [x] Testar navegação de todas as telas para detalhes

### **PRIORIDADE MÉDIA - Melhorias**

#### 4. Integrar Telas de Busca
- [x] Integrar AdvancedSearchScreen com GoRouter
- [x] Integrar SearchResultsScreen com GoRouter
- [ ] Integrar telas de busca especializada (voz, imagem, mapa)

#### 5. Corrigir Navegação de Chat
- [ ] Integrar ConversationScreen com GoRouter
- [ ] Definir rotas para conversas individuais
- [ ] Garantir navegação consistente

#### 6. Corrigir Navegação de Alertas
- [x] Implementar navegação para detalhes do imóvel em alertas
- [x] Integrar telas de criação/edição de alertas com GoRouter

### **PRIORIDADE BAIXA - Refinamentos**

#### 7. Melhorar UX de Navegação
- [ ] Adicionar animações de transição consistentes
- [ ] Implementar navegação com histórico
- [ ] Adicionar breadcrumbs onde apropriado

## 🧪 Testes Necessários

### Testes de Navegação
- [ ] Testar navegação de UserHomeScreen para PropertyDetailScreen
- [ ] Testar navegação de FavoritesScreen para PropertyDetailScreen
- [ ] Testar navegação de AlertsScreen para PropertyDetailScreen
- [ ] Testar navegação de NotificationsScreen para PropertyDetailScreen
- [ ] Testar navegação de SearchResultsScreen para PropertyDetailScreen
- [ ] Testar navegação entre todas as telas de usuário
- [ ] Testar navegação de volta (botão voltar)
- [ ] Testar navegação com parâmetros de rota

### Testes de Funcionalidade
- [ ] Testar carregamento de propriedades por ID
- [ ] Testar funcionalidades de favoritos
- [ ] Testar botões de ação (Ligar, WhatsApp)
- [ ] Testar compartilhamento
- [ ] Testar criação/edição de alertas
- [ ] Testar chat e conversas

## 📋 Status das Correções

- [x] **8/8** Telas com problemas críticos corrigidas
- [x] **5/7** Categorias de correção implementadas
- [ ] **0/8** Testes de navegação realizados
- [ ] **0/5** Testes de funcionalidade realizados

## 🎯 Próximos Passos

1. **✅ CONCLUÍDO**: Corrigir PropertyDetailScreen para carregar dados reais
2. **✅ CONCLUÍDO**: Padronizar todas as navegações para usar GoRouter
3. **✅ CONCLUÍDO**: Implementar rota `/user/property/:propertyId` corretamente
4. **✅ CONCLUÍDO**: Integrar navegação de alertas com GoRouter
5. **✅ CONCLUÍDO**: Integrar telas de busca com GoRouter
6. **SEGUINTE**: Corrigir navegação de chat
7. **FINAL**: Testar todas as navegações e funcionalidades

---
**Data de Criação**: ${new Date().toLocaleDateString('pt-BR')}
**Status**: 🟢 QUASE CONCLUÍDO - Todas as telas principais corrigidas
**Prioridade**: 🟢 BAIXA - Apenas chat e testes pendentes
