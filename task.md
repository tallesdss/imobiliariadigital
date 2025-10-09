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
- [ ] **Cadastro de Imóvel (ADM)**
  - [ ] Igual ao do corretor (formulário + upload mock).
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
- **Usuário (Comprador)**
  - Ver imóveis ativos.
  - Favoritar / criar alertas.
  - Mandar mensagem para corretor ou ADM.
- **Corretor**
  - Criar, editar, arquivar, excluir imóveis próprios.
  - Gerenciar perfil (dados pessoais).
  - Responder mensagens de usuários.
- **Administrador**
  - Criar, editar, arquivar, excluir qualquer imóvel.
  - Adicionar / editar / excluir corretores.
  - Acompanhar desempenho de corretores (dashboard).
  - Responder mensagens de usuários ou corretores.

### Regras de visibilidade
- Imóvel arquivado = invisível para usuários.
- Imóvel vendido = aparece como "Vendido" (histórico).
- Cada imóvel mostra **contato do corretor** (dono) e **contato do administrador**.

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
- [ ] **Barra Lateral com filtros** — Telas de Corretor
- [ ] **Barra Lateral com filtros** — Telas de Admnistrador