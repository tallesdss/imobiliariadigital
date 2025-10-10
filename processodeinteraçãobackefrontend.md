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
- [ ] **Listagem e Filtros**
  - **Endpoints:** `/properties`, parâmetros `cidade`, `tipo`, `preco_min`, `preco_max`
  - **Estimado:** 5h  
  - **Real:** ___  
  - **Status:** ☐ Em andamento ☐ Concluído  
  - **Observações:** ___________________________________________

- [ ] **Cards de Imóvel**
  - **Endpoints:** `/properties` (modo resumido)
  - **Estimado:** 2h  
  - **Real:** ___  
  - **Status:** ☐ Em andamento ☐ Concluído  
  - **Observações:** ___________________________________________

---

## 🏡 Etapa 3 — Detalhe do Imóvel (`properties/:id`)
- [ ] **Tela de Detalhes**
  - **Endpoints:** `/properties/:id`
  - **Estimado:** 4h  
  - **Real:** ___  
  - **Status:** ☐ Em andamento ☐ Concluído  
  - **Observações:** ___________________________________________

- [ ] **Favoritar / Desfavoritar**
  - **Endpoints:** `/favorites`, `/favorites/:id`
  - **Estimado:** 2h  
  - **Real:** ___  
  - **Status:** ☐ Em andamento ☐ Concluído  
  - **Observações:** ___________________________________________

---

## 💬 Etapa 4 — Chat em Tempo Real (`chat_conversations`, `chat_messages`)
- [ ] **Listagem de Conversas**
  - **Endpoints:** `/conversations`, `/conversations/:id`
  - **Estimado:** 3h  
  - **Real:** ___  
  - **Status:** ☐ Em andamento ☐ Concluído  
  - **Observações:** ___________________________________________

- [ ] **Envio e Recebimento de Mensagens**
  - **Endpoints:** `/messages`, WebSocket / Realtime Supabase
  - **Estimado:** 5h  
  - **Real:** ___  
  - **Status:** ☐ Em andamento ☐ Concluído  
  - **Observações:** ___________________________________________

---

## ⭐ Etapa 5 — Favoritos (`favorites`)
- [ ] **Integração completa**
  - **Endpoints:** `/favorites`, `/favorites/:id`
  - **Estimado:** 3h  
  - **Real:** ___  
  - **Status:** ☐ Em andamento ☐ Concluído  
  - **Observações:** ___________________________________________

---

## 🔔 Etapa 6 — Notificações (`notifications`)
- [ ] **Listagem e Marcar como Lida**
  - **Endpoints:** `/notifications`, `/notifications/:id/read`
  - **Estimado:** 4h  
  - **Real:** ___  
  - **Status:** ☐ Em andamento ☐ Concluído  
  - **Observações:** ___________________________________________

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
| Lista de Imóveis | 7h | ___ | ☐ |
| Detalhe do Imóvel | 6h | ___ | ☐ |
| Chat | 8h | ___ | ☐ |
| Favoritos | 3h | ___ | ☐ |
| Notificações | 4h | ___ | ☐ |
| Área Corretor/Admin | 10h | ___ | ☐ |
| Filtros & Alertas | 7h | ___ | ☐ |
| Relatórios & Logs | 4h | ___ | ☐ |
| Testes & Documentação | 5h | ___ | ☐ |
| **Total Planejado** | **57h** | **___** |   |

---
