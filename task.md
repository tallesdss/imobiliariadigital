# 📌 PRD – Projeto Flutter (Template Imobiliária Digital SaaS – Somente Frontend)

---

## Etapa 1 — Objetivo
- [x] Criar um **template funcional em Flutter** (somente frontend).
- [x] Tema: **Imobiliária Digital SaaS** com perfis distintos:
  - Usuário (comprador)
  - Corretor imobiliário
  - Administrador (gestor da plataforma)
- [x] Implementar navegação completa entre telas.
- [x] Usar **LocalState / PageState** como armazenamento temporário (mock).
- [x] Preparar design system padronizado.

---

## Etapa 2 — Estrutura do Projeto
- [x] Criar projeto Flutter do zero.
- [x] Configurar arquitetura (screens, widgets, models, state).
- [x] Definir rotas nomeadas para navegação.
- [x] Criar design system (cores, tipografia, spacing, ícones).

### Subitens Design System
- [x] Tipografia (ex.: Poppins).
- [x] Paleta de cores.
- [x] Botões globais.
- [x] Inputs padronizados.
- [x] Cards para imóveis.
- [x] Chat bubbles.
- [x] Badge de status (ativo, arquivado, vendido).

---

## Etapa 3 — Telas & Funções — Usuário (Comprador)
- [x] **Login / Cadastro** (mock).
- [x] **Seleção de Perfil** → Usuário / Corretor / Administrador.
- [x] **Home Usuário**
  - [x] Carrosséis horizontais por categoria (Lançamentos, Casas, Apts, Comerciais).
  - [x] Lista/grade vertical com todos os imóveis ativos.
  - [x] Filtro / Pesquisa (layout mock).
- [x] **Detalhe do Imóvel**
  - [x] Carrossel de fotos.
  - [x] Playlist de vídeos.
  - [x] Descrição completa.
  - [x] Preço e status.
  - [x] Botões:
    - ⭐ Favoritar
    - [x] 🔔 Criar Alerta (baixa preço / vendido)
    - [x] 💬 Mandar mensagem (chat com corretor e/ou ADM)
    - [x] 📞 Ligar para corretor (mock)
  - [x] Mostrar contatos:
    - Nome + contato do **Corretor**
    - [x] Nome + contato do **Administrador**
- [x] **Chat (Usuário)**
  - [x] Conversas com corretores ou ADM.
- [x] **Meus Favoritos**
- [x] **Meus Alertas**

---

## Etapa 4 — Telas & Funções — Corretor Imobiliário
- [x] **Cadastro de Corretor**
  - [x] Perfil com dados básicos (nome, foto, telefone, email, CRECI).
- [x] **Home Corretor**
  - [x] Listagem de imóveis que ele cadastrou.
  - [x] Ações rápidas por item: Editar / Arquivar / Excluir.
  - [x] Botão ➕ Cadastrar Novo Imóvel.
- [x] **Cadastro de Imóvel**
  - [x] Formulário mock (título, descrição, preço, endereço, atributos).
  - [x] Upload fake de fotos.
  - [x] Upload fake de vídeos (playlist).
- [x] **Detalhe do Imóvel (Corretor)**
  - [x] Igual ao do usuário, mas com botões de gestão.
  - [x] Ações: Editar, Arquivar, Excluir.
- [x] **Perfil do Corretor**
  - [x] Foto, bio, contato.
  - [x] Lista de imóveis cadastrados.
- [x] **Chat (Corretor)**
  - [x] Conversas com usuários interessados nos seus imóveis.

---

## Etapa 5 — Telas & Funções — Administrador
- [x] **Home Administrador**
  - [x] Listagem de todos os imóveis cadastrados (por corretores ou ADM).
  - [x] Filtros por status (Ativo / Arquivado / Vendido).
  - [x] Ações: Editar, Arquivar, Excluir, Ativar.
- [x] **Cadastro de Imóvel (ADM)**
  - [x] Igual ao do corretor (formulário + upload mock).
- [x] **Gestão de Corretores**
  - [x] Listagem de corretores cadastrados.
  - [x] Ações: 
    - ➕ Adicionar novo corretor (mock de cadastro)
    - ✏️ Editar dados do corretor
    - 🚫 Suspender corretor
    - ❌ Excluir corretor
- [x] **Dashboard Administrativo**
  - [x] Estatísticas gerais:
    - Total de imóveis ativos / vendidos / arquivados
    - Total de corretores ativos
  - [x] Ranking de corretores:
    - Quantidade de imóveis cadastrados
    - Quantidade de imóveis vendidos (mock)
    - Status dos imóveis (ativos/arquivados)
  - [x] Gráficos mock de desempenho por corretor.
- [x] **Mensagens (ADM)**
  - [x] Conversas com usuários ou corretores.
  - [x] Chat vinculado ao imóvel ou usuário.

---

## Etapa 6 — Permissões & Regras
- [x] **Usuário (Comprador)**
  - [x] Ver imóveis ativos.
  - [x] Favoritar / criar alertas.
  - [x] Mandar mensagem para corretor ou ADM.
- [x] **Corretor**
  - [x] Criar, editar, arquivar, excluir imóveis próprios.
  - [x] Gerenciar perfil (dados pessoais).
  - [x] Responder mensagens de usuários.
- [x] **Administrador**
  - [x] Criar, editar, arquivar, excluir qualquer imóvel.
  - [x] Adicionar / editar / excluir corretores.
  - [x] Acompanhar desempenho de corretores (dashboard).
  - [x] Responder mensagens de usuários ou corretores.

### Regras de visibilidade
- [x] Imóvel arquivado = invisível para usuários.
- [x] Imóvel vendido = aparece como "Vendido" (histórico).
- [x] Cada imóvel mostra **contato do corretor** (dono) e **contato do administrador**.

---

## Etapa 7 — Componentes Reutilizáveis
### Globais
- [x] AppBar customizada.
- [x] Bottom Navigation (usuário).
- [x] Drawer lateral (corretor e ADM).
- [x] Card de imóvel.
- [x] Botões globais.
- [x] Inputs customizados.

### Usuário
- [x] Carrossel horizontal.
- [x] Feed vertical.
- [x] Galeria + playlist.
- [x] Chat bubble.

### Corretor
- [x] Lista de imóveis do corretor.
- [x] Formulário de cadastro/edição.
- [x] Perfil do corretor.

### Administrador
- [x] Tabela/lista de imóveis com ações rápidas.
- [x] Listagem de corretores.
- [x] Dashboard de desempenho (gráficos mock).
- [x] Badge de status.

---

## Etapa 8 — Fluxos e Navegação
- [x] Login → Seleção Perfil → Home (Usuário / Corretor / ADM).
- [x] Usuário → Home → Detalhe → Chat com corretor/ADM → Favoritos/Alertas.
- [x] Corretor → Home Corretor → Cadastrar/Editar/Arquivar → Perfil → Chat com usuários.
- [x] Administrador → Home ADM → Imóveis / Corretores / Dashboard / Mensagens.

---

## Etapa 9 — Avisos Finais (O que NÃO deve ser feito)
- [x] Nenhuma lógica de autenticação real.
- [x] Nenhuma integração com API ou backend.
- [x] Não implementar lógica de telefonia real.
- [x] Tudo deve ser mock/fake em LocalState/PageState.

## Etapa 10 -  Funcionalidades da Drawer.
# 📂 Funcionalidades do Drawer

## 📱 Para Corretores

- [x] **Meus Imóveis** — Lista de imóveis cadastrados  
- [x] **Cadastrar Imóvel** — Formulário para adicionar um novo imóvel  
- [x] **Meu Perfil** — Dados pessoais e estatísticas de desempenho  
- [x] **Mensagens** — Chat com usuários interessados  
- [ ] **Relatórios** — Visualização e análise de desempenho individual  
- [ ] **Ajuda** — Acesso a suporte e documentação  

---

## 👨‍💼 Para Administradores

- [x] **Dashboard** — Visão geral e estatísticas da plataforma  
- [x] **Gestão de Imóveis** — Controle de todos os imóveis da plataforma  
- [x] **Gestão de Corretores** — CRUD (criar, ler, atualizar e deletar) de corretores  
- [x] **Cadastrar Imóvel** — Adicionar imóveis como administrador  
- [x] **Mensagens** — Chat com usuários e corretores  
- [x] **Relatórios** — Análises gerais da plataforma  
- [x] **Configurações** — Ajustes e preferências do sistema  
- [x] **Ajuda** — Suporte administrativo e documentação  

## Etapa 11 -  Responsividade.
- [x] **Responsividade** — Telas de Comprador
- [ ] **Responsividade** — Telas de Corretor
- [ ] **Responsividade** — Telas de Admnistrador

## Etapa 12 -  Barra lateral com filtros.
- [ ] **Barra Lateral com filtros** — Telas de Comprador
## 💰 Filtros de Preço

- [ ] Preço mínimo  
- [ ] Preço máximo  
- [ ] Tipo de negociação  
  - [ ] Venda  
  - [ ] Aluguel  
  - [ ] Temporada / Diária  
- [ ] Valor do condomínio  
- [ ] Valor do IPTU mensal  
- [ ] Faixas de preço sugeridas  
  - [ ] Até R$ 100.000  
  - [ ] R$ 100.000 – R$ 300.000  
  - [ ] R$ 300.000 – R$ 500.000  
  - [ ] R$ 500.000 – R$ 1.000.000  
  - [ ] Acima de R$ 1.000.000  
- [ ] Parcelamento / Financiamento disponível  
- [ ] Aceita proposta / Negociável  
- [ ] Exibir apenas imóveis com preço informado

- [ ] **Barra Lateral com filtros** — Telas de Corretor
- [ ] **Barra Lateral com filtros** — Telas de Admnistrador

---

## Etapa 13 — Tarefas Pendentes

### 🔧 Funcionalidades Pendentes

#### Para Corretores
- [ ] **Relatórios de Desempenho** — Tela com gráficos e métricas individuais:
  - [ ] Total de imóveis cadastrados pelo corretor
  - [ ] Imóveis vendidos vs. ativos vs. arquivados
  - [ ] Gráfico de vendas por mês/trimestre
  - [ ] Taxa de conversão (visualizações vs. contatos)
  - [ ] Ranking do corretor entre todos os corretores
  - [ ] Histórico de atividades (cadastros, edições, arquivamentos)
- [ ] **Central de Ajuda** — Tela com suporte e documentação:
  - [ ] FAQ (Perguntas Frequentes)
  - [ ] Tutoriais em vídeo
  - [ ] Guia de boas práticas
  - [ ] Contato com suporte técnico
  - [ ] Documentação da plataforma

#### Responsividade
- [ ] **Responsividade - Telas de Corretor** — Adaptação para diferentes tamanhos de tela:
  - [ ] Home do Corretor (lista de imóveis)
  - [ ] Cadastro/Edição de Imóvel
  - [ ] Perfil do Corretor
  - [ ] Chat do Corretor
  - [ ] Relatórios de Desempenho
- [ ] **Responsividade - Telas de Administrador** — Adaptação para diferentes tamanhos de tela:
  - [ ] Dashboard Administrativo
  - [ ] Gestão de Imóveis
  - [ ] Gestão de Corretores
  - [ ] Cadastro de Imóvel (ADM)
  - [ ] Mensagens (ADM)
  - [ ] Relatórios Gerais
  - [ ] Configurações do Sistema


### 📋 Resumo das Tarefas Pendentes

**Total de itens pendentes: 19**

1. **Relatórios de Desempenho** (6 subitens)
2. **Central de Ajuda** (5 subitens)
3. **Responsividade - Telas de Corretor** (5 subitens)
4. **Responsividade - Telas de Administrador** (7 subitens)

**Prioridade sugerida:**
1. **Responsividade** (alta prioridade) - 12 subitens
   - Telas de Corretor (5 subitens)
   - Telas de Administrador (7 subitens)
2. **Relatórios de Desempenho** (média prioridade) - 6 subitens
3. **Central de Ajuda** (baixa prioridade) - 5 subitens

---

## Etapa 14 — Funcionalidades de Comprador para Adicionar Imóveis

### 🚀 **ORDEM DE DESENVOLVIMENTO - ETAPA 14**

#### **FASE 1 - FUNDAÇÃO (Itens 1-8)**

1. [ ] **1.1 - Modelo de Dados**
   - **Objetivo**: Criar/adaptar models para anúncios de compradores
   - **Especificações**:
     - Estender `Property` model com campos de anunciante
     - Adicionar `isOwnerAnnounced: bool` para identificar anúncios de proprietários
     - Criar `OwnerProperty` model com campos específicos (dataAnuncio, statusAnuncio, visualizacoes, contatos)
     - Adicionar `ownerId` para vincular ao comprador
     - Implementar `PropertyStatus` enum (pending, active, paused, archived, rejected)
   - **Arquivos**: `lib/models/property_model.dart`, `lib/models/owner_property_model.dart`
   - **Tempo estimado**: 1-2 dias

2. [ ] **1.2 - Permissões do Comprador**
   - **Objetivo**: Sistema para alternar entre "Buscar" e "Anunciar"
   - **Especificações**:
     - Adicionar `canAnnounce: bool` ao `User` model
     - Criar `UserRole` enum (buyer, buyer_announcer, realtor, admin)
     - Implementar toggle de modo na interface
     - Persistir preferência do usuário (SharedPreferences)
     - Validação de permissões em todas as telas
   - **Arquivos**: `lib/models/user_model.dart`, `lib/services/user_service.dart`
   - **Tempo estimado**: 2-3 dias

3. [ ] **1.3 - Navegação Integrada**
   - **Objetivo**: Bottom navigation com aba "Meus Anúncios"
   - **Especificações**:
     - Adicionar ícone "📝 Meus Anúncios" no bottom navigation
     - Criar rota `/user/my-announcements` no GoRouter
     - Implementar `MyAnnouncementsScreen` básica
     - Adicionar badge de notificação (novos contatos)
     - Responsividade para tablet/desktop
   - **Arquivos**: `lib/screens/user/my_announcements_screen.dart`, `lib/services/navigation_service.dart`
   - **Tempo estimado**: 1-2 dias

4. [ ] **1.4 - Perfil Unificado**
   - **Objetivo**: Dados do comprador + anunciante em um perfil
   - **Especificações**:
     - Estender `UserProfileScreen` com seção de anunciante
     - Adicionar estatísticas básicas (total anúncios, contatos recebidos)
     - Toggle entre modo comprador/anunciante
     - Configurações específicas do anunciante
     - Histórico de atividades (anúncios criados, editados)
   - **Arquivos**: `lib/screens/user/user_profile_screen.dart`
   - **Tempo estimado**: 2-3 dias

5. [ ] **1.5 - Home do Anunciante**
   - **Objetivo**: Dashboard básico com ações rápidas
   - **Especificações**:
     - Cards de estatísticas (anúncios ativos, pausados, contatos)
     - Botão "➕ Novo Anúncio" em destaque
     - Lista de anúncios recentes (últimos 3)
     - Notificações de novos contatos
     - Ações rápidas (pausar/ativar anúncios)
   - **Arquivos**: `lib/screens/user/announcer_home_screen.dart`
   - **Tempo estimado**: 3-4 dias

6. [ ] **1.6 - Cadastrar Imóvel (Tela)**
   - **Objetivo**: Estrutura básica da tela de cadastro
   - **Especificações**:
     - Scaffold com AppBar customizada
     - Formulário em steps (dados básicos → características → mídia)
     - Validação em tempo real
     - Botões de navegação (anterior/próximo)
     - Preview do anúncio
     - Salvar como rascunho
   - **Arquivos**: `lib/screens/user/announce_property_screen.dart`
   - **Tempo estimado**: 4-5 dias

7. [ ] **1.7 - Meus Anúncios (Tela)**
   - **Objetivo**: Lista básica de imóveis anunciados
   - **Especificações**:
     - ListView/GridView responsivo
     - Filtros por status (ativo, pausado, arquivado)
     - Busca por título/endereço
     - Ordenação (data, preço, visualizações)
     - Pull-to-refresh
     - Empty state quando não há anúncios
   - **Arquivos**: `lib/screens/user/my_announcements_screen.dart`
   - **Tempo estimado**: 3-4 dias

8. [ ] **1.8 - Transição Fluida**
   - **Objetivo**: Alternância entre modos comprador/anunciante
   - **Especificações**:
     - Toggle no drawer/bottom navigation
     - Animação suave entre modos
     - Manter estado da navegação
     - Indicador visual do modo ativo
     - Persistir preferência do usuário
     - Validação de permissões
   - **Arquivos**: `lib/widgets/common/mode_toggle.dart`
   - **Tempo estimado**: 2-3 dias

#### **FASE 2 - CADASTRO BÁSICO (Itens 9-16)**

9. [ ] **2.1 - Dados Básicos do Imóvel**
   - **Objetivo**: Título, descrição, tipo, preço, endereço
   - **Especificações**:
     - Campo título (máx 100 caracteres, obrigatório)
     - TextArea descrição (máx 500 caracteres, obrigatório)
     - Dropdown tipo imóvel (casa, apartamento, comercial, terreno, sala)
     - Campo preço com máscara monetária (R$)
     - Dropdown tipo negociação (venda, aluguel, temporada)
     - Campo endereço com autocomplete (CEP, rua, número, bairro, cidade, estado)
     - Validação de CEP via API
     - Preview do endereço no mapa
   - **Arquivos**: `lib/widgets/forms/property_basic_info_form.dart`
   - **Tempo estimado**: 3-4 dias

10. [ ] **2.2 - Características Técnicas**
    - **Objetivo**: Quartos, banheiros, área, garagem, andar
    - **Especificações**:
      - Input numérico quartos (0-10, obrigatório)
      - Input numérico banheiros (0-10, obrigatório)
      - Input numérico área total (m², obrigatório)
      - Input numérico vagas garagem (0-10, opcional)
      - Input numérico andar (apartamentos, opcional)
      - Input numérico condomínio (R$, opcional)
      - Input numérico IPTU (R$, opcional)
      - Validação de valores mínimos/máximos
      - Cálculo automático de preço por m²
    - **Arquivos**: `lib/widgets/forms/property_characteristics_form.dart`
    - **Tempo estimado**: 2-3 dias

11. [ ] **2.3 - Upload de Fotos**
    - **Objetivo**: Sistema básico de upload de imagens
    - **Especificações**:
      - Seleção múltipla de imagens (máx 20 fotos)
      - Preview das imagens selecionadas
      - Drag & drop para reordenar
      - Redimensionamento automático (máx 2MB por foto)
      - Compressão de imagens
      - Upload progress indicator
      - Validação de formato (JPG, PNG, WebP)
      - Thumbnail generation
    - **Arquivos**: `lib/widgets/forms/image_upload_widget.dart`, `lib/services/image_service.dart`
    - **Tempo estimado**: 4-5 dias

12. [ ] **2.4 - Informações Adicionais**
    - **Objetivo**: Aceita proposta, financiamento, mobiliado
    - **Especificações**:
      - Switch "Aceita proposta" (sim/não)
      - Switch "Financiamento disponível" (sim/não)
      - Switch "Mobiliado" (sim/não)
      - Switch "Aceita pets" (sim/não)
      - Switch "Pet friendly" (sim/não)
      - Checkbox múltipla comodidades (piscina, academia, segurança, portaria 24h)
      - Campo observações adicionais (opcional)
      - Validação de campos obrigatórios
    - **Arquivos**: `lib/widgets/forms/property_additional_info_form.dart`
    - **Tempo estimado**: 2-3 dias

13. [ ] **2.5 - Formulário de Cadastro (Componente)**
    - **Objetivo**: Componente reutilizável
    - **Especificações**:
      - Stepper com 4 steps (dados básicos → características → mídia → revisão)
      - Navegação entre steps (anterior/próximo)
      - Validação por step
      - Progress indicator
      - Botões de ação (salvar rascunho, cancelar, finalizar)
      - Responsividade para mobile/tablet/desktop
      - Auto-save a cada step
    - **Arquivos**: `lib/widgets/forms/property_announcement_form.dart`
    - **Tempo estimado**: 3-4 dias

14. [ ] **2.6 - Validação de Dados**
    - **Objetivo**: Validações básicas do formulário
    - **Especificações**:
      - Validação em tempo real
      - Mensagens de erro específicas
      - Validação de campos obrigatórios
      - Validação de formatos (email, telefone, CEP)
      - Validação de valores (preço > 0, área > 0)
      - Validação de imagens (mín 1, máx 20)
      - Validação de endereço completo
      - Indicadores visuais de erro
    - **Arquivos**: `lib/utils/form_validators.dart`
    - **Tempo estimado**: 2-3 dias

15. [ ] **2.7 - Salvar Anúncio**
    - **Objetivo**: Persistência dos dados do anúncio
    - **Especificações**:
      - Criar `AnnouncementService` para CRUD
      - Integração com Supabase/MockData
      - Upload de imagens para storage
      - Geração de ID único
      - Timestamp de criação/edição
      - Status inicial (pending)
      - Validação de dados antes de salvar
      - Tratamento de erros
    - **Arquivos**: `lib/services/announcement_service.dart`
    - **Tempo estimado**: 3-4 dias

16. [ ] **2.8 - Confirmação de Cadastro**
    - **Objetivo**: Tela de sucesso após cadastro
    - **Especificações**:
      - Tela de confirmação com animação
      - Resumo do anúncio criado
      - Próximos passos (aguardar aprovação)
      - Botões de ação (ver anúncio, criar outro, voltar ao início)
      - Timeline do processo (criado → pendente → aprovado)
      - Compartilhamento do anúncio
      - Notificação de sucesso
    - **Arquivos**: `lib/screens/user/announcement_success_screen.dart`
    - **Tempo estimado**: 2-3 dias

#### **FASE 3 - GESTÃO BÁSICA (Itens 17-24)**

17. [ ] **3.1 - Listar Meus Anúncios**
    - **Objetivo**: Exibir anúncios do comprador
    - **Especificações**:
      - ListView/GridView responsivo com cards
      - Paginação infinita (scroll)
      - Pull-to-refresh
      - Loading states (skeleton, shimmer)
      - Empty state com call-to-action
      - Ordenação padrão (mais recentes primeiro)
      - Indicadores de status (ativo, pausado, pendente)
    - **Arquivos**: `lib/screens/user/my_announcements_screen.dart`
    - **Tempo estimado**: 3-4 dias

18. [ ] **3.2 - Card de Anúncio (Gestão)**
    - **Objetivo**: Versão do PropertyCard para gerenciamento
    - **Especificações**:
      - Thumbnail da primeira foto
      - Título e endereço
      - Preço e status (badge colorido)
      - Métricas (visualizações, contatos)
      - Data de criação/última edição
      - Ações rápidas (editar, pausar, excluir)
      - Indicador de notificações
      - Responsividade
    - **Arquivos**: `lib/widgets/cards/announcement_management_card.dart`
    - **Tempo estimado**: 2-3 dias

19. [ ] **3.3 - Editar Anúncio**
    - **Objetivo**: Modificar dados do imóvel anunciado
    - **Especificações**:
      - Reutilizar formulário de cadastro
      - Pré-popular campos com dados existentes
      - Validação de alterações
      - Histórico de edições
      - Confirmação antes de salvar
      - Preview das alterações
      - Notificação de sucesso
    - **Arquivos**: `lib/screens/user/edit_announcement_screen.dart`
    - **Tempo estimado**: 3-4 dias

20. [ ] **3.4 - Ativar/Pausar Anúncio**
    - **Objetivo**: Controle de status do anúncio
    - **Especificações**:
      - Toggle switch para ativar/pausar
      - Confirmação de ação
      - Atualização em tempo real
      - Feedback visual do status
      - Motivo da pausa (opcional)
      - Data/hora da alteração
      - Notificação de mudança
    - **Arquivos**: `lib/services/announcement_status_service.dart`
    - **Tempo estimado**: 2-3 dias

21. [ ] **3.5 - Excluir Anúncio**
    - **Objetivo**: Remover anúncio permanentemente
    - **Especificações**:
      - Modal de confirmação com aviso
      - Opção de arquivar vs excluir
      - Período de carência (7 dias)
      - Backup dos dados
      - Notificação de exclusão
      - Histórico de exclusões
    - **Arquivos**: `lib/widgets/dialogs/delete_announcement_dialog.dart`
    - **Tempo estimado**: 2-3 dias

22. [ ] **3.6 - Filtros de Anúncios**
    - **Objetivo**: Por status, data, performance
    - **Especificações**:
      - Filtro por status (todos, ativos, pausados, arquivados)
      - Filtro por data (últimos 7 dias, 30 dias, 90 dias)
      - Filtro por performance (com contatos, sem contatos)
      - Filtro por tipo de imóvel
      - Filtro por preço (faixas)
      - Filtros combinados
      - Salvar filtros preferidos
    - **Arquivos**: `lib/widgets/filters/announcement_filters.dart`
    - **Tempo estimado**: 3-4 dias

23. [ ] **3.7 - Busca em Anúncios**
    - **Objetivo**: Pesquisar entre próprios anúncios
    - **Especificações**:
      - Busca por título, endereço, descrição
      - Busca em tempo real (debounce)
      - Highlight dos termos encontrados
      - Histórico de buscas
      - Busca avançada (múltiplos campos)
      - Resultados ordenados por relevância
    - **Arquivos**: `lib/services/announcement_search_service.dart`
    - **Tempo estimado**: 2-3 dias

24. [ ] **3.8 - Ações Rápidas**
    - **Objetivo**: Botões de ação rápida nos cards
    - **Especificações**:
      - Menu de ações (3 dots)
      - Editar, pausar, excluir, compartilhar
      - Ações contextuais por status
      - Confirmação para ações destrutivas
      - Feedback visual das ações
      - Atalhos de teclado (desktop)
    - **Arquivos**: `lib/widgets/common/announcement_actions_menu.dart`
    - **Tempo estimado**: 2-3 dias

#### **FASE 4 - SISTEMA DE CONTATOS (Itens 25-32)**

25. [ ] **4.1 - Central de Mensagens (Anunciante)**
    - **Objetivo**: Estrutura básica de mensagens
    - **Especificações**:
      - Lista de conversas recebidas
      - Ordenação por última mensagem
      - Indicadores de não lidas
      - Busca por nome/telefone
      - Filtros por anúncio
      - Status online/offline
    - **Arquivos**: `lib/screens/user/announcer_messages_screen.dart`
    - **Tempo estimado**: 4-5 dias

26. [ ] **4.2 - Conversas com Interessados**
    - **Objetivo**: Lista de conversas recebidas
    - **Especificações**:
      - Avatar do interessado
      - Nome e telefone
      - Última mensagem (preview)
      - Timestamp da última mensagem
      - Badge de mensagens não lidas
      - Status da conversa
    - **Arquivos**: `lib/widgets/cards/conversation_card.dart`
    - **Tempo estimado**: 2-3 dias

27. [ ] **4.3 - Filtros por Anúncio**
    - **Objetivo**: Organizar mensagens por imóvel
    - **Especificações**:
      - Dropdown com anúncios do usuário
      - Filtro "Todas as conversas"
      - Contador de mensagens por anúncio
      - Busca dentro do anúncio selecionado
      - Ordenação por data/prioridade
    - **Arquivos**: `lib/widgets/filters/message_filters.dart`
    - **Tempo estimado**: 2-3 dias

28. [ ] **4.4 - Status das Conversas**
    - **Objetivo**: Lida/não lida, respondida/pendente
    - **Especificações**:
      - Badge visual de não lida
      - Status "respondida" vs "pendente"
      - Timestamp da última visualização
      - Contador de mensagens não lidas
      - Auto-marcação como lida
      - Histórico de status
    - **Arquivos**: `lib/models/conversation_status.dart`
    - **Tempo estimado**: 2-3 dias

29. [ ] **4.5 - Notificações de Interesse**
    - **Objetivo**: Alertas de novos contatos
    - **Especificações**:
      - Push notifications
      - Badge no ícone da app
      - Notificação in-app
      - Email de notificação (opcional)
      - Som de notificação
      - Configurações de notificação
    - **Arquivos**: `lib/services/notification_service.dart`
    - **Tempo estimado**: 3-4 dias

30. [ ] **4.6 - Mensagens Não Lidas**
    - **Objetivo**: Contador e indicadores visuais
    - **Especificações**:
      - Badge numérico no bottom navigation
      - Contador na lista de conversas
      - Indicador visual nos cards
      - Sincronização em tempo real
      - Reset ao visualizar mensagem
    - **Arquivos**: `lib/services/unread_messages_service.dart`
    - **Tempo estimado**: 2-3 dias

31. [ ] **4.7 - Propostas de Compra/Aluguel**
    - **Objetivo**: Sistema de propostas
    - **Especificações**:
      - Formulário de proposta
      - Campos: valor, prazo, condições
      - Anexos (documentos)
      - Status da proposta (pendente, aceita, recusada)
      - Notificação de nova proposta
      - Histórico de propostas
    - **Arquivos**: `lib/models/proposal_model.dart`, `lib/screens/user/proposal_screen.dart`
    - **Tempo estimado**: 4-5 dias

32. [ ] **4.8 - Responder Mensagens**
    - **Objetivo**: Interface para responder interessados
    - **Especificações**:
      - Chat interface similar ao WhatsApp
      - Envio de texto, imagens, documentos
      - Status de entrega/leitura
      - Respostas rápidas (templates)
      - Histórico da conversa
      - Informações do anúncio no contexto
    - **Arquivos**: `lib/screens/user/announcer_chat_screen.dart`
    - **Tempo estimado**: 4-5 dias

#### **FASE 5 - ESTATÍSTICAS BÁSICAS (Itens 33-40)**

33. [ ] **5.1 - Visitas ao Anúncio**
    - **Objetivo**: Contador de visualizações
    - **Especificações**:
      - Tracking de visualizações únicas
      - Contador em tempo real
      - Histórico de visualizações
      - Filtros por período (dia, semana, mês)
      - Comparativo entre anúncios
      - Gráfico de tendência
    - **Arquivos**: `lib/services/analytics_service.dart`
    - **Tempo estimado**: 3-4 dias

34. [ ] **5.2 - Contatos Recebidos**
    - **Objetivo**: Número de interessados
    - **Especificações**:
      - Contador de mensagens recebidas
      - Contador de propostas recebidas
      - Contador de ligações (se disponível)
      - Taxa de conversão (visualizações → contatos)
      - Ranking de anúncios por contatos
      - Gráfico de contatos por período
    - **Arquivos**: `lib/services/contact_analytics_service.dart`
    - **Tempo estimado**: 2-3 dias

35. [ ] **5.3 - Dashboard Widgets**
    - **Objetivo**: Cards de estatísticas básicas
    - **Especificações**:
      - Card "Anúncios Ativos" com contador
      - Card "Visualizações Hoje" com gráfico
      - Card "Contatos Recebidos" com tendência
      - Card "Performance Geral" com indicadores
      - Atualização em tempo real
      - Responsividade para mobile/tablet
    - **Arquivos**: `lib/widgets/dashboard/statistics_cards.dart`
    - **Tempo estimado**: 3-4 dias

36. [ ] **5.4 - Total de Anúncios Ativos**
    - **Objetivo**: Contador geral
    - **Especificações**:
      - Contador total de anúncios
      - Breakdown por status (ativo, pausado, arquivado)
      - Comparativo com período anterior
      - Indicador de crescimento/declínio
      - Meta de anúncios (se configurada)
    - **Arquivos**: `lib/services/announcement_stats_service.dart`
    - **Tempo estimado**: 2-3 dias

37. [ ] **5.5 - Anúncios Pausados/Arquivados**
    - **Objetivo**: Status dos anúncios
    - **Especificações**:
      - Lista de anúncios pausados
      - Lista de anúncios arquivados
      - Motivos da pausa/arquivamento
      - Data da última ação
      - Opção de reativar
      - Histórico de mudanças de status
    - **Arquivos**: `lib/screens/user/archived_announcements_screen.dart`
    - **Tempo estimado**: 3-4 dias

38. [ ] **5.6 - Visualizações por Anúncio**
    - **Objetivo**: Métricas individuais
    - **Especificações**:
      - Lista de anúncios com visualizações
      - Ranking por número de visualizações
      - Gráfico de visualizações por anúncio
      - Comparativo entre anúncios
      - Detalhes por período
      - Exportar dados
    - **Arquivos**: `lib/screens/user/announcement_analytics_screen.dart`
    - **Tempo estimado**: 3-4 dias

39. [ ] **5.7 - Performance por Período**
    - **Objetivo**: Gráficos básicos mensais/semanais
    - **Especificações**:
      - Gráfico de linha com visualizações
      - Gráfico de barras com contatos
      - Comparativo mensal/semanal
      - Tendências e previsões
      - Filtros por período
      - Zoom nos gráficos
    - **Arquivos**: `lib/widgets/charts/performance_charts.dart`
    - **Tempo estimado**: 4-5 dias

40. [ ] **5.8 - Estatísticas (Tela)**
    - **Objetivo**: Tela dedicada para relatórios
    - **Especificações**:
      - Dashboard completo de estatísticas
      - Filtros por período e anúncio
      - Gráficos interativos
      - Exportar relatórios (PDF/Excel)
      - Compartilhar estatísticas
      - Configurações de exibição
    - **Arquivos**: `lib/screens/user/announcer_statistics_screen.dart`
    - **Tempo estimado**: 4-5 dias

#### **FASE 6 - FUNCIONALIDADES AVANÇADAS (Itens 41-48)**

41. [ ] **6.1 - Upload de Vídeos**
    - **Objetivo**: Sistema de upload de vídeos
    - **Especificações**:
      - Upload de vídeos (máx 100MB)
      - Compressão automática
      - Preview do vídeo
      - Thumbnail generation
      - Progress indicator
      - Validação de formato (MP4, MOV, AVI)
      - Streaming de vídeo
    - **Arquivos**: `lib/widgets/forms/video_upload_widget.dart`
    - **Tempo estimado**: 5-6 dias

42. [ ] **6.2 - Planta Baixa (Opcional)**
    - **Objetivo**: Upload de plantas baixas
    - **Especificações**:
      - Upload de imagens de planta baixa
      - Zoom e pan na planta
      - Anotações na planta
      - Múltiplas plantas (diferentes andares)
      - Preview interativo
      - Download da planta
    - **Arquivos**: `lib/widgets/forms/floor_plan_widget.dart`
    - **Tempo estimado**: 4-5 dias

43. [ ] **6.3 - Comodidades Avançadas**
    - **Objetivo**: Piscina, academia, segurança
    - **Especificações**:
      - Lista expandida de comodidades
      - Categorias (lazer, segurança, conveniência)
      - Ícones para cada comodidade
      - Filtros por comodidade
      - Busca por comodidades
      - Ranking por comodidades
    - **Arquivos**: `lib/models/amenities_model.dart`
    - **Tempo estimado**: 3-4 dias

44. [ ] **6.4 - Compartilhar Anúncio**
    - **Objetivo**: Funcionalidade de compartilhamento
    - **Especificações**:
      - Compartilhar via WhatsApp, Facebook, Instagram
      - Link direto para o anúncio
      - Preview do anúncio no compartilhamento
      - QR Code do anúncio
      - Estatísticas de compartilhamentos
      - Compartilhamento em redes sociais
    - **Arquivos**: `lib/services/share_service.dart`
    - **Tempo estimado**: 3-4 dias

45. [ ] **6.5 - Ver como Comprador**
    - **Objetivo**: Visualizar próprio anúncio como comprador
    - **Especificações**:
      - Botão "Ver como Comprador" no anúncio
      - Abrir anúncio na visualização de comprador
      - Feedback sobre a apresentação
      - Sugestões de melhoria
      - Comparativo com outros anúncios
      - A/B testing de apresentação
    - **Arquivos**: `lib/screens/user/preview_announcement_screen.dart`
    - **Tempo estimado**: 2-3 dias

46. [ ] **6.6 - Taxa de Conversão**
    - **Objetivo**: Visitas vs. Contatos
    - **Especificações**:
      - Cálculo automático da taxa
      - Gráfico de conversão por período
      - Comparativo entre anúncios
      - Benchmarking com média da plataforma
      - Sugestões para melhorar conversão
      - Alertas de baixa conversão
    - **Arquivos**: `lib/services/conversion_analytics_service.dart`
    - **Tempo estimado**: 3-4 dias

47. [ ] **6.7 - Tempo de Resposta**
    - **Objetivo**: Velocidade de resposta às mensagens
    - **Especificações**:
      - Medição do tempo de resposta
      - Estatísticas de tempo médio
      - Ranking por velocidade de resposta
      - Alertas de mensagens não respondidas
      - Templates de resposta rápida
      - Configurações de auto-resposta
    - **Arquivos**: `lib/services/response_time_service.dart`
    - **Tempo estimado**: 3-4 dias

48. [ ] **6.8 - Perfil Anunciante**
    - **Objetivo**: Dados específicos do anunciante
    - **Especificações**:
      - Seção específica no perfil
      - Estatísticas do anunciante
      - Histórico de anúncios
      - Reputação e avaliações
      - Configurações de notificação
      - Preferências de anúncio
    - **Arquivos**: `lib/screens/user/announcer_profile_screen.dart`
    - **Tempo estimado**: 4-5 dias

#### **FASE 7 - MODERAÇÃO (Itens 49-56)**

49. [ ] **7.1 - Sistema de Aprovação**
    - **Objetivo**: Anúncios pendentes de aprovação
    - **Especificações**:
      - Fila de anúncios para aprovação
      - Status "pending" para novos anúncios
      - Notificação para administradores
      - Priorização por data de criação
      - Filtros por tipo de anúncio
      - Sistema de aprovação em lote
    - **Arquivos**: `lib/services/approval_service.dart`
    - **Tempo estimado**: 3-4 dias

50. [ ] **7.2 - Revisão por Administradores**
    - **Objetivo**: Interface para ADM aprovar
    - **Especificações**:
      - Dashboard de moderação
      - Preview completo do anúncio
      - Botões de aprovação/rejeição
      - Campo de comentários para rejeição
      - Histórico de aprovações
      - Estatísticas de moderação
    - **Arquivos**: `lib/screens/admin/announcement_moderation_screen.dart`
    - **Tempo estimado**: 4-5 dias

51. [ ] **7.3 - Critérios de Qualidade**
    - **Objetivo**: Regras de aprovação
    - **Especificações**:
      - Checklist de qualidade
      - Validação automática de campos
      - Verificação de imagens
      - Análise de conteúdo
      - Score de qualidade
      - Sugestões de melhoria
    - **Arquivos**: `lib/services/quality_check_service.dart`
    - **Tempo estimado**: 4-5 dias

52. [ ] **7.4 - Termos de Uso para Anunciantes**
    - **Objetivo**: Documentação legal
    - **Especificações**:
      - Termos específicos para anunciantes
      - Política de privacidade
      - Regras de conduta
      - Penalidades por violação
      - Aceite obrigatório
      - Histórico de aceites
    - **Arquivos**: `lib/screens/legal/announcer_terms_screen.dart`
    - **Tempo estimado**: 2-3 dias

53. [ ] **7.5 - Política de Preços**
    - **Objetivo**: Regras de precificação
    - **Especificações**:
      - Validação de preços por região
      - Alertas de preços suspeitos
      - Comparativo com mercado
      - Sugestões de preço
      - Histórico de preços
      - Análise de tendências
    - **Arquivos**: `lib/services/price_validation_service.dart`
    - **Tempo estimado**: 3-4 dias

54. [ ] **7.6 - Regras de Conteúdo**
    - **Objetivo**: Diretrizes de conteúdo
    - **Especificações**:
      - Lista de palavras proibidas
      - Verificação de spam
      - Análise de conteúdo duplicado
      - Moderação de imagens
      - Filtros automáticos
      - Sistema de denúncia
    - **Arquivos**: `lib/services/content_moderation_service.dart`
    - **Tempo estimado**: 4-5 dias

55. [ ] **7.7 - Penalidades por Violações**
    - **Objetivo**: Sistema de penalidades
    - **Especificações**:
      - Sistema de pontos
      - Suspensão temporária
      - Banimento permanente
      - Notificações de penalidade
      - Processo de recurso
      - Histórico de penalidades
    - **Arquivos**: `lib/services/penalty_service.dart`
    - **Tempo estimado**: 3-4 dias

56. [ ] **7.8 - Qualidade dos Anúncios**
    - **Objetivo**: Métricas de aprovação
    - **Especificações**:
      - Taxa de aprovação por anunciante
      - Tempo médio de aprovação
      - Motivos de rejeição
      - Ranking de qualidade
      - Melhorias sugeridas
      - Relatórios de qualidade
    - **Arquivos**: `lib/services/quality_metrics_service.dart`
    - **Tempo estimado**: 3-4 dias

#### **FASE 8 - MONETIZAÇÃO (Itens 57-64)**

57. [ ] **8.1 - Destacar Anúncio (Pago)**
    - **Objetivo**: Sistema de anúncios pagos
    - **Especificações**:
      - Planos de destaque (básico, premium, vip)
      - Preços por período (7, 15, 30 dias)
      - Pagamento integrado
      - Confirmação de pagamento
      - Renovação automática
      - Cancelamento de destaque
    - **Arquivos**: `lib/services/premium_announcement_service.dart`
    - **Tempo estimado**: 5-6 dias

58. [ ] **8.2 - Anúncio em Destaque na Home**
    - **Objetivo**: Posicionamento premium
    - **Especificações**:
      - Carrossel de anúncios destacados
      - Badge "DESTAQUE" no anúncio
      - Posicionamento prioritário
      - Estatísticas de visualização
      - ROI do investimento
      - Comparativo com anúncios normais
    - **Arquivos**: `lib/widgets/cards/featured_announcement_card.dart`
    - **Tempo estimado**: 3-4 dias

59. [ ] **8.3 - Aumentar Visibilidade**
    - **Objetivo**: Ferramentas de promoção
    - **Especificações**:
      - Boost de visualizações
      - Promoção em redes sociais
      - Email marketing
      - Push notifications
      - Parcerias com influenciadores
      - Campanhas segmentadas
    - **Arquivos**: `lib/services/visibility_boost_service.dart`
    - **Tempo estimado**: 4-5 dias

60. [ ] **8.4 - ROI dos Anúncios Pagos**
    - **Objetivo**: Retorno sobre investimento
    - **Especificações**:
      - Cálculo automático de ROI
      - Gráficos de retorno
      - Comparativo de investimentos
      - Previsão de ROI
      - Alertas de baixo retorno
      - Sugestões de otimização
    - **Arquivos**: `lib/services/roi_analytics_service.dart`
    - **Tempo estimado**: 3-4 dias

61. [ ] **8.5 - Receita de Promoções**
    - **Objetivo**: Sistema de pagamentos
    - **Especificações**:
      - Integração com gateway de pagamento
      - Múltiplas formas de pagamento
      - Faturamento automático
      - Relatórios financeiros
      - Comissões da plataforma
      - Histórico de transações
    - **Arquivos**: `lib/services/payment_service.dart`
    - **Tempo estimado**: 5-6 dias

62. [ ] **8.6 - Anunciantes Ativos**
    - **Objetivo**: Métricas de engajamento
    - **Especificações**:
      - Contador de anunciantes ativos
      - Frequência de anúncios
      - Tempo médio na plataforma
      - Taxa de retenção
      - Análise de comportamento
      - Segmentação de usuários
    - **Arquivos**: `lib/services/announcer_engagement_service.dart`
    - **Tempo estimado**: 3-4 dias

63. [ ] **8.7 - Total de Anúncios**
    - **Objetivo**: Por categoria e região
    - **Especificações**:
      - Dashboard de anúncios totais
      - Breakdown por categoria
      - Distribuição geográfica
      - Crescimento mensal
      - Comparativo regional
      - Projeções de crescimento
    - **Arquivos**: `lib/services/announcement_analytics_service.dart`
    - **Tempo estimado**: 3-4 dias

64. [ ] **8.8 - Relatórios do Anunciante**
    - **Objetivo**: Performance detalhada
    - **Especificações**:
      - Relatórios personalizados
      - Exportação em PDF/Excel
      - Gráficos interativos
      - Filtros avançados
      - Agendamento de relatórios
      - Compartilhamento de relatórios
    - **Arquivos**: `lib/services/announcer_report_service.dart`
    - **Tempo estimado**: 4-5 dias

#### **FASE 9 - AVALIAÇÕES E REPUTAÇÃO (Itens 65-72)**

65. [ ] **9.1 - Avaliação de Compradores**
    - **Objetivo**: Sistema de avaliação de interessados
    - **Especificações**:
      - Formulário de avaliação
      - Rating de 1 a 5 estrelas
      - Comentários opcionais
      - Categorias de avaliação
      - Verificação de compra
      - Moderação de avaliações
    - **Arquivos**: `lib/models/rating_model.dart`
    - **Tempo estimado**: 4-5 dias

66. [ ] **9.2 - Feedback sobre o Processo**
    - **Objetivo**: Coleta de feedback
    - **Especificações**:
      - Formulário de feedback
      - Categorias de feedback
      - Priorização de melhorias
      - Análise de sentimentos
      - Relatórios de feedback
      - Ações corretivas
    - **Arquivos**: `lib/services/feedback_service.dart`
    - **Tempo estimado**: 3-4 dias

67. [ ] **9.3 - Reputação do Anunciante**
    - **Objetivo**: Sistema de reputação
    - **Especificações**:
      - Score de reputação (0-100)
      - Badges de qualidade
      - Histórico de avaliações
      - Comparativo com outros
      - Melhoria da reputação
      - Certificações especiais
    - **Arquivos**: `lib/services/reputation_service.dart`
    - **Tempo estimado**: 4-5 dias

68. [ ] **9.4 - Sistema de Avaliações**
    - **Objetivo**: Interface de avaliações
    - **Especificações**:
      - Lista de avaliações recebidas
      - Filtros por rating
      - Resposta às avaliações
      - Agradecimentos
      - Moderação de avaliações
      - Estatísticas de avaliações
    - **Arquivos**: `lib/screens/user/announcer_ratings_screen.dart`
    - **Tempo estimado**: 3-4 dias

69. [ ] **9.5 - Histórico de Avaliações**
    - **Objetivo**: Registro de avaliações
    - **Especificações**:
      - Timeline de avaliações
      - Evolução da reputação
      - Comparativo temporal
      - Gráficos de tendência
      - Exportação de dados
      - Backup de avaliações
    - **Arquivos**: `lib/services/rating_history_service.dart`
    - **Tempo estimado**: 3-4 dias

70. [ ] **9.6 - Métricas de Satisfação**
    - **Objetivo**: Indicadores de qualidade
    - **Especificações**:
      - NPS (Net Promoter Score)
      - CSAT (Customer Satisfaction)
      - Taxa de resolução
      - Tempo de resposta
      - Qualidade do atendimento
      - Relatórios de satisfação
    - **Arquivos**: `lib/services/satisfaction_metrics_service.dart`
    - **Tempo estimado**: 4-5 dias

71. [ ] **9.7 - Ranking de Anunciantes**
    - **Objetivo**: Classificação por qualidade
    - **Especificações**:
      - Leaderboard de anunciantes
      - Critérios de ranking
      - Categorias de ranking
      - Prêmios e reconhecimentos
      - Benefícios do ranking
      - Transparência dos critérios
    - **Arquivos**: `lib/services/announcer_ranking_service.dart`
    - **Tempo estimado**: 3-4 dias

72. [ ] **9.8 - Certificação de Qualidade**
    - **Objetivo**: Selos de qualidade
    - **Especificações**:
      - Selos de qualidade
      - Critérios para certificação
      - Processo de certificação
      - Renovação de certificados
      - Benefícios da certificação
      - Verificação de autenticidade
    - **Arquivos**: `lib/services/certification_service.dart`
    - **Tempo estimado**: 4-5 dias

#### **FASE 10 - ANALYTICS AVANÇADOS (Itens 73-80)**

73. [ ] **10.1 - Gráficos de Visualizações**
    - **Objetivo**: Visualizações detalhadas
    - **Especificações**:
      - Gráficos interativos
      - Filtros por período
      - Comparativo entre anúncios
      - Análise de picos
      - Previsões de tendência
      - Exportação de gráficos
    - **Arquivos**: `lib/widgets/charts/views_charts.dart`
    - **Tempo estimado**: 4-5 dias

74. [ ] **10.2 - Análise de Contatos**
    - **Objetivo**: Padrões de interesse
    - **Especificações**:
      - Análise de comportamento
      - Segmentação de interessados
      - Padrões de contato
      - Horários de maior interesse
      - Perfil dos interessados
      - Insights automáticos
    - **Arquivos**: `lib/services/contact_analysis_service.dart`
    - **Tempo estimado**: 5-6 dias

75. [ ] **10.3 - Performance dos Anúncios**
    - **Objetivo**: Métricas avançadas
    - **Especificações**:
      - KPIs personalizados
      - Benchmarking automático
      - Análise de concorrência
      - Otimização de performance
      - Alertas de performance
      - Relatórios executivos
    - **Arquivos**: `lib/services/advanced_analytics_service.dart`
    - **Tempo estimado**: 5-6 dias

76. [ ] **10.4 - Análise de Mercado**
    - **Objetivo**: Dados de mercado
    - **Especificações**:
      - Preços de mercado
      - Tendências regionais
      - Análise de concorrência
      - Oportunidades de mercado
      - Previsões de preços
      - Relatórios de mercado
    - **Arquivos**: `lib/services/market_analysis_service.dart`
    - **Tempo estimado**: 6-7 dias

77. [ ] **10.5 - Comparativo de Performance**
    - **Objetivo**: Benchmarking
    - **Especificações**:
      - Comparativo com concorrentes
      - Benchmarking interno
      - Análise de gaps
      - Oportunidades de melhoria
      - Ranking de performance
      - Relatórios comparativos
    - **Arquivos**: `lib/services/benchmarking_service.dart`
    - **Tempo estimado**: 4-5 dias

78. [ ] **10.6 - Previsões de Vendas**
    - **Objetivo**: IA para previsões
    - **Especificações**:
      - Machine Learning para previsões
      - Algoritmos de predição
      - Previsão de vendas
      - Análise de probabilidade
      - Recomendações automáticas
      - Ajuste de preços
    - **Arquivos**: `lib/services/prediction_service.dart`
    - **Tempo estimado**: 7-8 dias

79. [ ] **10.7 - Otimização de Anúncios**
    - **Objetivo**: Sugestões de melhoria
    - **Especificações**:
      - IA para otimização
      - Sugestões automáticas
      - A/B testing
      - Otimização de preços
      - Melhoria de descrições
      - Recomendações de imagens
    - **Arquivos**: `lib/services/optimization_service.dart`
    - **Tempo estimado**: 6-7 dias

80. [ ] **10.8 - Relatórios Personalizados**
    - **Objetivo**: Relatórios customizáveis
    - **Especificações**:
      - Builder de relatórios
      - Widgets personalizáveis
      - Agendamento automático
      - Múltiplos formatos
      - Compartilhamento avançado
      - API de relatórios
    - **Arquivos**: `lib/services/custom_report_service.dart`
    - **Tempo estimado**: 5-6 dias

### 📊 **RESUMO DA ORDEM DE DESENVOLVIMENTO**

**Total: 80 itens organizados em 10 fases**

**Fases por Prioridade:**
1. **FASE 1-2** (Itens 1-16) - **CRÍTICA** - Fundação e cadastro básico
2. **FASE 3-4** (Itens 17-32) - **ALTA** - Gestão e contatos
3. **FASE 5-6** (Itens 33-48) - **MÉDIA** - Estatísticas e funcionalidades avançadas
4. **FASE 7-8** (Itens 49-64) - **MÉDIA** - Moderação e monetização
5. **FASE 9-10** (Itens 65-80) - **BAIXA** - Avaliações e analytics avançados

**Tempo Estimado por Fase:**
- **FASE 1-2**: 2-3 semanas (funcionalidade básica)
- **FASE 3-4**: 2-3 semanas (gestão completa)
- **FASE 5-6**: 2-3 semanas (estatísticas e avançado)
- **FASE 7-8**: 2-3 semanas (moderação e monetização)
- **FASE 9-10**: 2-3 semanas (avaliações e analytics)

**Total Estimado: 10-15 semanas para implementação completa**