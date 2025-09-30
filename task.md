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
- [ ] Chat bubbles.
- [ ] Badge de status (ativo, arquivado, vendido).

---

## Etapa 3 — Telas & Funções — Usuário (Comprador)
- [x] **Login / Cadastro** (mock).
- [x] **Seleção de Perfil** → Usuário / Corretor / Administrador.
- [x] **Home Usuário**
  - [ ] Carrosséis horizontais por categoria (Lançamentos, Casas, Apts, Comerciais).
  - [x] Lista/grade vertical com todos os imóveis ativos.
  - [x] Filtro / Pesquisa (layout mock).
- [x] **Detalhe do Imóvel**
  - [x] Carrossel de fotos.
  - [ ] Playlist de vídeos.
  - [x] Descrição completa.
  - [x] Preço e status.
  - [x] Botões:
    - ⭐ Favoritar
    - [ ] 🔔 Criar Alerta (baixa preço / vendido)
    - [ ] 💬 Mandar mensagem (chat com corretor e/ou ADM)
    - [x] 📞 Ligar para corretor (mock)
  - [x] Mostrar contatos:
    - Nome + contato do **Corretor**
    - [ ] Nome + contato do **Administrador**
- [ ] **Chat (Usuário)**
  - [ ] Conversas com corretores ou ADM.
- [x] **Meus Favoritos**
- [ ] **Meus Alertas**

---

## Etapa 4 — Telas & Funções — Corretor Imobiliário
- [ ] **Cadastro de Corretor**
  - [ ] Perfil com dados básicos (nome, foto, telefone, email, CRECI).
- [ ] **Home Corretor**
  - [ ] Listagem de imóveis que ele cadastrou.
  - [ ] Ações rápidas por item: Editar / Arquivar / Excluir.
  - [ ] Botão ➕ Cadastrar Novo Imóvel.
- [ ] **Cadastro de Imóvel**
  - [ ] Formulário mock (título, descrição, preço, endereço, atributos).
  - [ ] Upload fake de fotos.
  - [ ] Upload fake de vídeos (playlist).
- [ ] **Detalhe do Imóvel (Corretor)**
  - [ ] Igual ao do usuário, mas com botões de gestão.
  - [ ] Ações: Editar, Arquivar, Excluir.
- [ ] **Perfil do Corretor**
  - [ ] Foto, bio, contato.
  - [ ] Lista de imóveis cadastrados.
- [ ] **Chat (Corretor)**
  - [ ] Conversas com usuários interessados nos seus imóveis.

---

## Etapa 5 — Telas & Funções — Administrador
- [ ] **Home Administrador**
  - [ ] Listagem de todos os imóveis cadastrados (por corretores ou ADM).
  - [ ] Filtros por status (Ativo / Arquivado / Vendido).
  - [ ] Ações: Editar, Arquivar, Excluir, Ativar.
- [ ] **Cadastro de Imóvel (ADM)**
  - [ ] Igual ao do corretor (formulário + upload mock).
- [ ] **Gestão de Corretores**
  - [ ] Listagem de corretores cadastrados.
  - [ ] Ações: 
    - ➕ Adicionar novo corretor (mock de cadastro)
    - ✏️ Editar dados do corretor
    - 🚫 Suspender corretor
    - ❌ Excluir corretor
- [ ] **Dashboard Administrativo**
  - [ ] Estatísticas gerais:
    - Total de imóveis ativos / vendidos / arquivados
    - Total de corretores ativos
  - [ ] Ranking de corretores:
    - Quantidade de imóveis cadastrados
    - Quantidade de imóveis vendidos (mock)
    - Status dos imóveis (ativos/arquivados)
  - [ ] Gráficos mock de desempenho por corretor.
- [ ] **Mensagens (ADM)**
  - [ ] Conversas com usuários ou corretores.
  - [ ] Chat vinculado ao imóvel ou usuário.

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
- [ ] Bottom Navigation (usuário).
- [ ] Drawer lateral (corretor e ADM).
- [x] Card de imóvel.
- [x] Botões globais.
- [x] Inputs customizados.

### Usuário
- [ ] Carrossel horizontal.
- [x] Feed vertical.
- [x] Galeria + playlist.
- [ ] Chat bubble.

### Corretor
- [ ] Lista de imóveis do corretor.
- [ ] Formulário de cadastro/edição.
- [ ] Perfil do corretor.

### Administrador
- [ ] Tabela/lista de imóveis com ações rápidas.
- [ ] Listagem de corretores.
- [ ] Dashboard de desempenho (gráficos mock).
- [ ] Badge de status.

---

## Etapa 8 — Fluxos e Navegação
- [x] Login → Seleção Perfil → Home (Usuário / Corretor / ADM).
- [x] Usuário → Home → Detalhe → Chat com corretor/ADM → Favoritos/Alertas.
- [ ] Corretor → Home Corretor → Cadastrar/Editar/Arquivar → Perfil → Chat com usuários.
- [ ] Administrador → Home ADM → Imóveis / Corretores / Dashboard / Mensagens.

---

## Etapa 9 — Avisos Finais (O que NÃO deve ser feito)
- [x] Nenhuma lógica de autenticação real.
- [x] Nenhuma integração com API ou backend.
- [x] Não implementar lógica de telefonia real.
- [x] Tudo deve ser mock/fake em LocalState/PageState.
