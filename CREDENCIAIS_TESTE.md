# Credenciais para Testes - Imobiliária Digital

Este arquivo contém as credenciais genéricas para testes durante o desenvolvimento.

## ⚠️ IMPORTANTE
- **NÃO USE** estas credenciais em produção
- Estas credenciais são apenas para **desenvolvimento e testes**
- **DELETE** este arquivo antes de fazer deploy em produção

## 🔐 Credenciais de Teste

### Usuário Comprador (Buyer)
```
E-mail: test.buyer@imobiliariadigital.com
Senha: Teste123456
Tipo: Comprador
```

### Usuário Corretor (Realtor)
```
E-mail: test.realtor@imobiliariadigital.com
Senha: Teste123456
Tipo: Corretor
```

### Usuário Administrador (Admin)
```
E-mail: test.admin@imobiliariadigital.com
Senha: Teste123456
Tipo: Administrador
```

### Usuário Genérico
```
E-mail: usuario.teste@imobiliariadigital.com
Senha: Teste123456
Tipo: Comprador (padrão)
```

## 🚀 Como Usar

1. **Login Tradicional:**
   - Use qualquer uma das credenciais acima
   - O sistema irá redirecionar baseado no tipo de usuário

2. **Cadastro:**
   - Use qualquer e-mail com formato válido
   - Senha deve ter pelo menos 6 caracteres
   - Exemplo: `teste@exemplo.com` / `123456`

3. **Google Sign-In:**
   - Use qualquer conta Google
   - O sistema criará automaticamente um perfil de comprador

## 📱 Tipos de Usuário e Redirecionamento

- **Comprador (buyer):** → `/user`
- **Corretor (realtor):** → `/realtor`  
- **Administrador (admin):** → `/admin`

## 🔧 Para Desenvolvimento

Se precisar criar novos usuários de teste:

1. **Via Interface:**
   - Use a tela de cadastro
   - Qualquer e-mail válido funcionará

2. **Via Supabase Dashboard:**
   - Acesse o painel do Supabase
   - Vá em Authentication > Users
   - Crie usuários manualmente se necessário

## 🛠️ Configurações de Desenvolvimento

Para facilitar os testes, você pode:

1. **Desabilitar confirmação de email** no Supabase:
   - Authentication > Settings
   - Desmarque "Enable email confirmations"

2. **Usar dados mock** para desenvolvimento:
   - O sistema já tem `MockDataService` implementado
   - Use para testes sem depender do backend

## 📝 Notas Importantes

- As senhas seguem o padrão: `Teste123456`
- Todos os e-mails são fictícios e seguros para testes
- O sistema está configurado para aceitar qualquer e-mail válido
- Em caso de rate limit, aguarde alguns minutos ou use Google Sign-In

---
**Última atualização:** $(date)
**Ambiente:** Desenvolvimento
