# Ordem Paranormal RPG - Kit de Gestão

Aplicativo mobile Flutter para gestão completa de fichas, inventários e combates do sistema de RPG "Ordem Paranormal".

**✨ Versão com Banco de Dados Local (SQLite) - Sem necessidade de Firebase!**

---

## 🚀 Início Rápido

**SUPER SIMPLES - 2 comandos:**

```bash
flutter pub get
flutter run
```

Pronto! Sem configuração de Firebase, sem complicação. Tudo salvo localmente no seu dispositivo.

---

## Características

### Funcionalidades Principais

- **Modo Jogador**: Gerencie seus personagens individuais
- **Modo Mestre**: Controle total sobre todos os personagens da campanha
- **Gestão de Fichas**: Crie, edite e exclua personagens completos
- **Controles Interativos**: Ajuste PV, PE, PS e Créditos com botões ±1 e ±5
- **Sistema de Inventário**: Gerencie itens, armas e equipamentos
- **Rolagem de Dados**: Sistema completo de rolagem com fórmulas (ex: 1d20+5, 2d6+1d8)
- **Rolagem de Dano**: Role dano de armas diretamente do inventário
- **Dano Crítico**: Suporte a multiplicadores e efeitos críticos
- **Exportação/Importação**: Compartilhe personagens via WhatsApp usando JSON
- **Persistência Local**: Todos os dados salvos localmente no dispositivo (SQLite)
- **Tema Escuro**: Interface visual alinhada à temática paranormal

### Tecnologias

- **Flutter/Dart**: Framework de desenvolvimento mobile
- **SQLite (sqflite)**: Banco de dados local para persistência
- **Material Design 3**: Design moderno e fluido

## Instalação e Configuração

### Pré-requisitos

- Flutter SDK (versão 3.0.0 ou superior)
- Android Studio ou VS Code
- Dispositivo Android ou Emulador

### Passo 1: Instalar Flutter

Se você ainda não tem o Flutter instalado:

1. Baixe o Flutter SDK em: https://flutter.dev/docs/get-started/install
2. Adicione o Flutter ao PATH do sistema
3. Execute `flutter doctor` para verificar a instalação

### Passo 2: Navegar até o Projeto

```bash
cd E:\Academico\008 - UNIRP 2023-2026\6 semestre\mobile\android\dart
```

### Passo 3: Instalar Dependências

```bash
flutter pub get
```

### Passo 4: Executar o Aplicativo

```bash
# Conecte um dispositivo Android ou inicie um emulador
flutter devices

# Execute o aplicativo
flutter run
```

**Pronto!** Não precisa configurar Firebase ou nada na nuvem. Tudo funciona localmente! 🎉

## Estrutura do Projeto

```
lib/
├── main.dart                    # Ponto de entrada do app
├── models/                      # Modelos de dados
│   ├── character.dart          # Modelo de personagem
│   └── item.dart               # Modelo de item
├── services/                    # Serviços e lógica de negócio
│   └── firestore_service.dart  # Serviço de persistência
├── utils/                       # Utilitários
│   └── dice_roller.dart        # Sistema de rolagem de dados
├── theme/                       # Tema e estilos
│   └── app_theme.dart          # Tema escuro personalizado
└── screens/                     # Telas do aplicativo
    ├── mode_selection_screen.dart      # Seleção de modo
    ├── player_home_screen.dart         # Home do jogador
    ├── character_list_screen.dart      # Lista de personagens
    ├── character_form_screen.dart      # Formulário de personagem
    ├── character_detail_screen.dart    # Detalhes e controles
    ├── inventory_screen.dart           # Inventário e rolagem de dano
    ├── dice_roller_screen.dart         # Rolador de dados
    └── master_dashboard_screen.dart    # Dashboard do mestre
```

## Como Usar

### Modo Jogador

1. **Criar Personagem**:
   - Toque em "MODO JOGADOR"
   - Toque no botão "+" para adicionar um novo personagem
   - Preencha todos os campos da ficha
   - Toque em "Salvar"

2. **Gerenciar Status**:
   - Toque em um personagem da lista
   - Use os botões -5, -1, +1, +5 para ajustar PV, PE, PS
   - Use os botões para ajustar Créditos
   - Alterações são salvas automaticamente

3. **Gerenciar Inventário**:
   - Na tela de detalhes, toque em "Ver Inventário"
   - Adicione itens usando o botão "+"
   - Para armas, preencha a fórmula de dano (ex: 1d8+2)
   - Adicione multiplicador e efeito crítico se aplicável

4. **Rolar Dano**:
   - No inventário, toque em uma arma
   - Escolha "Rolar Dano" para dano normal
   - Escolha "Crítico" para aplicar o multiplicador

5. **Rolar Dados**:
   - Vá para a aba "Dados"
   - Digite uma fórmula (ex: 1d20+5)
   - Toque em "Rolar Dados"
   - Veja o resultado detalhado com cada dado individual

### Modo Mestre

1. **Dashboard**:
   - Toque em "MODO MESTRE"
   - Veja estatísticas gerais da campanha
   - Acesse todos os personagens

2. **Exportar Personagens**:
   - No Dashboard, toque em "Exportar Personagens"
   - Selecione os personagens desejados
   - Toque em "Compartilhar"
   - Escolha WhatsApp ou outra forma de compartilhamento
   - O JSON será copiado para compartilhar

3. **Importar Personagens**:
   - No Dashboard, toque em "Importar Personagens"
   - Cole o JSON recebido
   - Toque em "Importar"
   - Os personagens serão adicionados ao Firestore

4. **Gerenciar Personagens**:
   - Vá para a aba "Personagens"
   - Edite ou exclua qualquer personagem
   - Controle total sobre todas as fichas

## Estrutura de Dados

### Character (Personagem)

```dart
{
  "id": "uuid",
  "nome": "String",
  "patente": "String",
  "nex": 5,
  "origem": "String",
  "classe": "String",
  "trilha": "String",
  "createdBy": "user_id",
  "status": {
    "pv_atual": 20,
    "pv_max": 20,
    "pe_atual": 10,
    "pe_max": 10,
    "ps_atual": 15,
    "ps_max": 15,
    "creditos": 1000
  },
  "atributos": {
    "for": 2,
    "agi": 3,
    "vig": 1,
    "int": 2,
    "pre": 1
  },
  "inventario": [...]
}
```

### Item

```dart
{
  "id": "uuid",
  "nome": "Revólver .38",
  "descricao": "Uma arma de fogo padrão",
  "quantidade": 1,
  "tipo": "Arma",
  "formulaDano": "1d8+2",
  "multiplicadorCritico": 2,
  "efeitoCritico": "Sangramento"
}
```

## Sistema de Rolagem de Dados

O sistema suporta fórmulas complexas:

- `1d20` - Um dado de 20 lados
- `2d6` - Dois dados de 6 lados
- `1d8+2` - Um d8 mais modificador de 2
- `1d20+1d6+5` - Múltiplos dados com modificador
- `3d10` - Três dados de 10 lados

## Troubleshooting

### Erro: "MissingPluginException"

```bash
flutter clean
flutter pub get
flutter run
```

### Erro: Build falha no Android

```bash
flutter clean
cd android
gradlew clean
cd ..
flutter pub get
flutter run
```

### Erro: Banco de dados corrompido

Se o banco local estiver com problemas, você pode limpá-lo:
- Desinstale o app do dispositivo
- Instale novamente com `flutter run`

Ou use o modo Debug para limpar dados:
- Configurações → Apps → Ordem Paranormal RPG → Limpar dados

## Próximos Passos (Melhorias Futuras)

- [ ] Backup e restauração de dados (export/import do banco completo)
- [ ] Implementar sistema de campanhas
- [ ] Suporte para mapas e combate tático
- [ ] Adicionar sons e animações
- [ ] Temas personalizáveis
- [ ] Suporte para iOS
- [ ] Sincronização via nuvem (opcional - Firebase/outro)
- [ ] Compartilhamento de fichas via QR Code
- [ ] Histórico de alterações de personagens

## Licença

Este projeto é livre para uso educacional e pessoal.

## Suporte

Para dúvidas ou problemas, abra uma issue no repositório do projeto.

---

Desenvolvido com Flutter 💙
