# MapButton Widget

## Descrição
O `MapButton` é um widget reutilizável que permite abrir o Google Maps com o endereço de um imóvel.

## Funcionalidades
- Abre o Google Maps nativo (se disponível) ou no navegador
- Suporte para iOS (Apple Maps) e Android (Google Maps)
- Fallback para navegador web
- Modo compacto (IconButton) e modo completo (OutlinedButton)

## Parâmetros

### Obrigatórios
- `address`: Endereço do imóvel
- `city`: Cidade
- `state`: Estado

### Opcionais
- `zipCode`: CEP
- `neighborhood`: Bairro
- `buttonText`: Texto do botão (padrão: "Exibir no mapa")
- `icon`: Ícone do botão (padrão: Icons.map_outlined)
- `isCompact`: Se true, renderiza como IconButton (padrão: false)

## Exemplos de Uso

### Botão Completo (Padrão)
```dart
MapButton(
  address: "Rua das Flores, 123",
  city: "São Paulo",
  state: "SP",
  zipCode: "01234-567",
  neighborhood: "Centro",
)
```

### Botão Compacto (IconButton)
```dart
MapButton(
  address: "Rua das Flores, 123",
  city: "São Paulo", 
  state: "SP",
  isCompact: true,
  icon: Icons.map,
  buttonText: "Abrir no mapa",
)
```

## Comportamento
1. Tenta abrir o app Google Maps nativo
2. Se não disponível, tenta Apple Maps (iOS)
3. Fallback para navegador web com Google Maps
4. Trata erros silenciosamente (apenas debug print)

## Integração
O componente já está integrado na tela de detalhes do imóvel (`PropertyDetailScreen`) em duas posições:
1. Na seção de localização (botão completo)
2. Na AppBar (botão compacto)
