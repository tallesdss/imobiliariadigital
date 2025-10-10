# Tabelas Necessárias para o Frontend - Imobiliária Digital

## 1. Tabela de Usuários (users)
**Descrição:** Armazena informações de todos os usuários do sistema (compradores, corretores e administradores)

**Campos:**
- id (identificador único)
- nome (nome completo do usuário)
- email (endereço de email)
- telefone (número de telefone - opcional)
- foto (URL da foto de perfil - opcional)
- tipo_usuario (enum: comprador, corretor, administrador)
- data_criacao (data de criação da conta)
- ativo (se a conta está ativa)

## 2. Tabela de Corretores (realtors)
**Descrição:** Informações específicas dos corretores de imóveis

**Campos:**
- id (identificador único)
- nome (nome completo do corretor)
- email (endereço de email)
- telefone (número de telefone)
- foto (URL da foto de perfil - opcional)
- creci (número do CRECI)
- biografia (descrição do corretor - opcional)
- data_criacao (data de cadastro)
- ativo (se o corretor está ativo)
- total_imoveis (quantidade total de imóveis cadastrados)
- imoveis_vendidos (quantidade de imóveis vendidos)

## 3. Tabela de Imóveis (properties)
**Descrição:** Armazena todas as informações dos imóveis disponíveis

**Campos:**
- id (identificador único)
- titulo (título do anúncio)
- descricao (descrição detalhada do imóvel)
- preco (valor do imóvel)
- tipo_imovel (enum: casa, apartamento, comercial, terreno)
- status (enum: ativo, vendido, arquivado, suspenso)
- endereco (endereço completo)
- cidade (cidade)
- estado (estado)
- cep (CEP)
- fotos (array de URLs das fotos)
- videos (array de URLs dos vídeos)
- atributos (JSON com características: quartos, banheiros, área, vagas, etc.)
- corretor_id (ID do corretor responsável)
- nome_corretor (nome do corretor)
- telefone_corretor (telefone do corretor)
- contato_admin (contato administrativo)
- data_criacao (data de cadastro)
- data_atualizacao (última atualização)
- destaque (se é imóvel em destaque)
- lancamento (se é um lançamento)

## 4. Tabela de Favoritos (favorites)
**Descrição:** Relaciona usuários com imóveis favoritados

**Campos:**
- id (identificador único)
- usuario_id (ID do usuário)
- imovel_id (ID do imóvel)
- data_criacao (data que foi favoritado)

## 5. Tabela de Alertas de Imóveis (property_alerts)
**Descrição:** Alertas configurados pelos usuários para imóveis

**Campos:**
- id (identificador único)
- usuario_id (ID do usuário)
- imovel_id (ID do imóvel)
- titulo_imovel (título do imóvel)
- tipo_alerta (enum: redução de preço, vendido, imóvel similar)
- preco_alvo (preço alvo para alerta - opcional)
- data_criacao (data de criação do alerta)
- ativo (se o alerta está ativo)

## 6. Tabela de Conversas de Chat (chat_conversations)
**Descrição:** Conversas entre compradores e corretores sobre imóveis

**Campos:**
- id (identificador único)
- imovel_id (ID do imóvel em discussão)
- titulo_imovel (título do imóvel)
- comprador_id (ID do comprador)
- nome_comprador (nome do comprador)
- corretor_id (ID do corretor)
- nome_corretor (nome do corretor)
- data_criacao (data de início da conversa)
- ultima_mensagem_data (data da última mensagem)
- mensagens_nao_lidas (contador de mensagens não lidas)

## 7. Tabela de Mensagens de Chat (chat_messages)
**Descrição:** Mensagens individuais das conversas

**Campos:**
- id (identificador único)
- conversa_id (ID da conversa)
- remetente_id (ID de quem enviou)
- nome_remetente (nome de quem enviou)
- conteudo (conteúdo da mensagem)
- tipo_mensagem (enum: texto, imagem, documento)
- data_envio (data e hora do envio)
- lida (se a mensagem foi lida)

## 8. Tabela de Filtros de Imóveis (property_filters)
**Descrição:** Filtros salvos pelos usuários para busca de imóveis

**Campos:**
- id (identificador único)
- usuario_id (ID do usuário)
- nome_filtro (nome do filtro salvo)
- preco_minimo (preço mínimo)
- preco_maximo (preço máximo)
- tipo_transacao (enum: venda, aluguel, diária)
- condominio_maximo (valor máximo do condomínio)
- iptu_maximo (valor máximo do IPTU)
- apenas_com_preco (filtrar apenas com preço definido)
- aceita_proposta (aceita proposta)
- tem_financiamento (tem financiamento)
- faixas_preco (array de faixas de preço)
- data_criacao (data de criação do filtro)

## 9. Tabela de Relatórios (reports)
**Descrição:** Relatórios gerados pelo sistema para administradores e corretores

**Campos:**
- id (identificador único)
- tipo_relatorio (tipo do relatório)
- usuario_id (ID do usuário que solicitou)
- dados_relatorio (JSON com os dados do relatório)
- data_geracao (data de geração)
- periodo_inicio (início do período)
- periodo_fim (fim do período)

## 10. Tabela de Configurações do Sistema (system_settings)
**Descrição:** Configurações gerais do sistema

**Campos:**
- id (identificador único)
- chave (chave da configuração)
- valor (valor da configuração)
- descricao (descrição da configuração)
- data_atualizacao (última atualização)

## 11. Tabela de Logs de Atividade (activity_logs)
**Descrição:** Log de atividades dos usuários no sistema

**Campos:**
- id (identificador único)
- usuario_id (ID do usuário)
- acao (ação realizada)
- detalhes (detalhes da ação)
- data_acao (data e hora da ação)
- ip_address (endereço IP)
- user_agent (navegador/dispositivo)

## 12. Tabela de Notificações (notifications)
**Descrição:** Notificações para usuários

**Campos:**
- id (identificador único)
- usuario_id (ID do usuário)
- titulo (título da notificação)
- mensagem (conteúdo da notificação)
- tipo_notificacao (tipo da notificação)
- lida (se foi lida)
- data_criacao (data de criação)
- data_leitura (data de leitura - opcional)

## Relacionamentos Principais:
- Usuários → Corretores (1:1 para corretores)
- Corretores → Imóveis (1:N)
- Usuários → Favoritos (1:N)
- Imóveis → Favoritos (1:N)
- Usuários → Alertas (1:N)
- Imóveis → Alertas (1:N)
- Imóveis → Conversas (1:N)
- Conversas → Mensagens (1:N)
- Usuários → Filtros (1:N)
- Usuários → Relatórios (1:N)
- Usuários → Logs (1:N)
- Usuários → Notificações (1:N)
