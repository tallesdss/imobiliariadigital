# ⏱️ Controle de Integração Frontend ↔ Backend — Imobiliária Digital

> **Instruções:**
> - Marque `[x]` quando a etapa for concluída.  
> - Preencha o tempo **estimado** e o **real gasto**.  
> - Adicione observações curtas, como endpoints usados, erros corrigidos ou melhorias.  
> - Após finalizar uma etapa, rode: `Execute Flutter Analyze e Corrija os erros`.

---

## 🧩 Etapa 1 — Autenticação & Usuários (`users`)
- [x] **Login / Registro / Perfil**
  - **Endpoints:** `/auth`, `/users/me`, `/users/update`
  - **Estimado:** 3h  
  - **Real:** 2.5h  
  - **Status:** ☐ Em andamento ☑ Concluído  
  - **Observações:** Implementado ApiService, AuthService, telas de login/registro/perfil com integração real ao backend

---

## 🏠 Etapa 2 — Lista de Imóveis (`properties`)
- [x] **Listagem e Filtros**
  - **Endpoints:** `/properties`, parâmetros `cidade`, `tipo`, `preco_min`, `preco_max`
  - **Estimado:** 5h  
  - **Real:** 4h  
  - **Status:** ☐ Em andamento ☑ Concluído  
  - **Observações:** Implementado PropertyService, PropertyStateService, filtros avançados, busca por texto, carrosséis por categoria

- [x] **Cards de Imóvel**
  - **Endpoints:** `/properties` (modo resumido)
  - **Estimado:** 2h  
  - **Real:** 1.5h  
  - **Status:** ☐ Em andamento ☑ Concluído  
  - **Observações:** PropertyCard implementado com modo compacto, favoritos, comparação, responsivo

---

## 🏡 Etapa 3 — Detalhe do Imóvel (`properties/:id`)
- [x] **Tela de Detalhes**
  - **Endpoints:** `/properties/:id`
  - **Estimado:** 4h  
  - **Real:** 3h  
  - **Status:** ☐ Em andamento ☑ Concluído  
  - **Observações:** Implementado PropertyService.getPropertyById, integração real com API, tratamento de erros, carregamento assíncrono

- [x] **Favoritar / Desfavoritar**
  - **Endpoints:** `/favorites`, `/favorites/:id`
  - **Estimado:** 2h  
  - **Real:** 2h  
  - **Status:** ☐ Em andamento ☑ Concluído  
  - **Observações:** Criado FavoriteService, integração completa com API, atualização de FavoritesScreen e PropertyDetailScreen

---

## 💬 Etapa 4 — Chat em Tempo Real (`chat_conversations`, `chat_messages`)
- [x] **Listagem de Conversas**
  - **Endpoints:** `/conversations`, `/conversations/:id`
  - **Estimado:** 3h  
  - **Real:** 2.5h  
  - **Status:** ☐ Em andamento ☑ Concluído  
  - **Observações:** Criado ChatService com integração completa à API, listagem de conversas para todos os perfis (usuário, corretor, admin)

- [x] **Envio e Recebimento de Mensagens**
  - **Endpoints:** `/messages`, WebSocket / Realtime Supabase
  - **Estimado:** 5h  
  - **Real:** 4h  
  - **Status:** ☐ Em andamento ☑ Concluído  
  - **Observações:** Implementado WebSocket para mensagens em tempo real, telas de conversa para usuário e corretor, envio de mensagens com feedback visual

---

## ⭐ Etapa 5 — Favoritos (`favorites`)
- [x] **Integração completa**
  - **Endpoints:** `/favorites`, `/favorites/:id`
  - **Estimado:** 3h  
  - **Real:** 2.5h  
  - **Status:** ☐ Em andamento ☑ Concluído  
  - **Observações:** Implementado FavoriteService com cache local, integração completa com API, melhorias na UX com carregamento otimizado, limpeza de cache no logout

---

## 🔔 Etapa 6 — Notificações (`notifications`)
- [x] **Listagem e Marcar como Lida**
  - **Endpoints:** `/notifications`, `/notifications/:id/read`
  - **Estimado:** 4h  
  - **Real:** 3.5h  
  - **Status:** ☐ Em andamento ☑ Concluído  
  - **Observações:** Implementado NotificationModel, NotificationService com cache local, NotificationsScreen com filtros e ações, integração completa nas telas de usuário, corretor e admin com contadores de notificações não lidas

---

## ⚙️ Etapa 7 — Área do Corretor & Administração
- [ ] **Painel do Corretor**
  - **Endpoints:** `/realtors`, `/properties?corretor_id=`
  - **Estimado:** 4h  
  - **Real:** ___  
  - **Status:** ☐ Em andamento ☐ Concluído  
  - **Observações:** ___________________________________________

- [ ] **Painel do Administrador**
  - **Endpoints:** `/reports`, `/system_settings`, `/activity_logs`
  - **Estimado:** 6h  
  - **Real:** ___  
  - **Status:** ☐ Em andamento ☐ Concluído  
  - **Observações:** ___________________________________________

---

## 🔍 Etapa 8 — Filtros e Alertas (`property_filters`, `property_alerts`)
- [ ] **Filtros Salvos**
  - **Endpoints:** `/filters`, `/filters/:id`
  - **Estimado:** 3h  
  - **Real:** ___  
  - **Status:** ☐ Em andamento ☐ Concluído  
  - **Observações:** ___________________________________________

- [ ] **Alertas de Imóveis**
  - **Endpoints:** `/alerts`, `/alerts/:id`
  - **Estimado:** 4h  
  - **Real:** ___  
  - **Status:** ☐ Em andamento ☐ Concluído  
  - **Observações:** ___________________________________________

---

## 📊 Etapa 9 — Relatórios & Logs (`reports`, `activity_logs`)
- [ ] **Integração e Visualização**
  - **Endpoints:** `/reports`, `/activity_logs`
  - **Estimado:** 4h  
  - **Real:** ___  
  - **Status:** ☐ Em andamento ☐ Concluído  
  - **Observações:** ___________________________________________

---

## 🧠 Etapa 10 — Testes, Ajustes e Documentação
- [ ] **Testes de Integração**
  - **Estimado:** 3h  
  - **Real:** ___  
  - **Status:** ☐ Em andamento ☐ Concluído  
  - **Observações:** ___________________________________________

- [ ] **Documentar Endpoints e Fluxos**
  - **Estimado:** 2h  
  - **Real:** ___  
  - **Status:** ☐ Em andamento ☐ Concluído  
  - **Observações:** ___________________________________________

---

## ✅ Resumo Final
| Módulo | Estimado | Real | Status |
|---|---:|---:|:---|
| Autenticação & Usuários | 3h | 2.5h | ☑ |
| Lista de Imóveis | 7h | 5.5h | ☑ |
| Detalhe do Imóvel | 6h | 5h | ☑ |
| Chat | 8h | 6.5h | ☑ |
| Favoritos | 3h | 2.5h | ☑ |
| Notificações | 4h | 3.5h | ☑ |
| Área Corretor/Admin | 10h | ___ | ☐ |
| Filtros & Alertas | 7h | ___ | ☐ |
| Relatórios & Logs | 4h | ___ | ☐ |
| Testes & Documentação | 5h | ___ | ☐ |
| **Total Planejado** | **57h** | **___** |   |

---
