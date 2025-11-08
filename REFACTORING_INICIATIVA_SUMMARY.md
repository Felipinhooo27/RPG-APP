# Refatoração IniciativaScreen - Hexatombe Design System

## Arquivo Refatorado
- **Path**: `E:\RPG-APP\lib\screens\iniciativa_screen.dart`
- **Status**: Refatoração Completa
- **Linhas**: 1195

## Alterações Implementadas

### 1. HexLoading.large() com Mensagens
**Antes**: Spinner genérico sem feedback
**Depois**: 
```dart
HexLoading.large(
  message: 'Carregando combatentes...',
)
```
- Linha 174-177: Carregamento com mensagem contextual
- Melhora UX com feedback visual

### 2. EmptyState para Estados Vazios
**Implementação**:
- **Character Selection Vazio** (Linha 180-184):
  ```dart
  const EmptyState(
    icon: Icons.shield_outlined,
    title: 'Nenhum Combatente',
    message: 'Crie personagens primeiro para iniciar um combate',
  )
  ```
- **Combat Vazio** (Linha 509-510):
  ```dart
  const EmptyState.noCombat()
  ```

### 3. RitualCard para Character Selection
**Localização**: Linhas 237-373
- Cards para cada personagem selecionável
- Efeito de glow quando selecionado
- Estrutura limpa com checkbox + info

### 4. RitualCard para Combat Tracker
**Localização**: Linhas 547-813
- Card para cada combatente
- Glow ativo para turno atual
- Contém status de vida, iniciativa e controles

### 5. BorderRadius 6-8px (Não 20px)
**Alterações Globais**:
- Checkbox containers: `BorderRadius.circular(6)` (linha 263)
- Auto-save toggle: `BorderRadius.circular(6)` (linha 322)
- Combat tracker position indicator: `BorderRadius.circular(6)` (linha 562)
- Initiative badge: `BorderRadius.circular(6)` (linha 601)
- Containers variados: `BorderRadius.circular(6)` (linhas 675, 750)
- PV buttons: `BorderRadius.circular(6)` (linha 830)

**Padrão Aplicado**: 
- Bordas maiores (64px): circular(8)
- Bordas médias (48px): circular(6)
- Bordas pequenas: circular(6)

### 6. GlowingButton para Ações
**Turnos** (Linhas 477-500):
```dart
GlowingButton(
  label: 'Anterior',
  icon: Icons.arrow_back,
  onPressed: () { session.turnoAnterior(); },
  style: GlowingButtonStyle.secondary,
)

GlowingButton(
  label: 'Próximo',
  icon: Icons.arrow_forward,
  onPressed: () { session.proximoTurno(); },
  style: GlowingButtonStyle.danger,
)
```

**Remover Combatente** (Linhas 803-810):
```dart
GlowingButton(
  label: 'Remover do Combate',
  icon: Icons.remove_circle_outline,
  onPressed: () { _showRemoveCombatantDialog(...); },
  style: GlowingButtonStyle.danger,
)
```

### 7. Diálogos com Dialog + RitualCard + GlowingButton

#### 7.1 Dialog de Erro Inicial
**Função**: `_showInitErrorDialog()` (Linhas 849-916)
- **Gatilho**: Nenhum combatente selecionado ao iniciar
- **Design**:
  - RitualCard com glow vermelho
  - Ícone warning em container com sombra
  - Título e mensagem
  - Botão GlowingButton.primary para confirmar

#### 7.2 Dialog de Re-rolar Iniciativa
**Função**: `_showRerollInitiativeDialog()` (Linhas 918-1017)
- **Gatilho**: Clique no ícone refresh na AppBar
- **Design**:
  - RitualCard com glow púrpura
  - Ícone shuffle
  - Confirmação de ação
  - Dois botões: Cancelar (secondary) e Confirmar (primary)
  - Re-rola todas as iniciativas ao confirmar

#### 7.3 Dialog de Finalizar Combate
**Função**: `_showEndCombatDialog()` (Linhas 1019-1102)
- **Gatilho**: Clique no ícone close na AppBar
- **Design**:
  - RitualCard com glow amarelo
  - Ícone stop_circle
  - Confirmação com dois botões
  - Cancela combate ao confirmar

#### 7.4 Dialog de Remover Combatente
**Função**: `_showRemoveCombatantDialog()` (Linhas 1104-1193)
- **Gatilho**: Clique em "Remover do Combate" no expansion
- **Design**:
  - RitualCard com glow vermelho
  - Ícone person_remove
  - Nome do personagem na mensagem
  - Dois botões: Cancelar e Remover

## Mudanças de Fluxo

### Character Selection → Combat
- SnackBar removido (erro inicial)
- Dialog styled com Hexatombe para feedback

### Combat Reroll
- Callback direto removido
- Dialog de confirmação adicionado
- Transação limpa com estado

### Combat End
- Callback direto removido  
- Dialog de confirmação adicionado
- Melhor UX com confirmação visual

### Remove Combatant
- Callback direto removido
- Dialog contextual com nome do personagem
- Melhor feedback ao usuário

## Componentes Usados
- **HexLoading**: Para estados de carregamento
- **EmptyState**: Para estados vazios
- **RitualCard**: Cards temáticas
- **GlowingButton**: Botões com efeito de brilho
- **Dialog**: Diálogos modais nativos
- **AppTheme**: Paleta de cores Hexatombe

## Padrão de Design
- **Cores por contexto**:
  - Vermelho (ritualRed): Avisos, remoção, combate
  - Púrpura (etherealPurple): Re-rolar iniciativas
  - Amarelo (alertYellow): Finalizar combate
- **Ícones**: Semânticos e contextuais
- **Animações**: Fade + Scale nos diálogos
- **Feedback**: Mensagens claras e ações confirmadas

## Validação
- Análise: Sem erros críticos (apenas deprecated warnings)
- Imports: Todos presentes (widgets.dart inclui HexLoading, EmptyState, RitualCard, GlowingButton)
- Sintaxe: Válida e bem-formada
- Funcionalidade: Mantida (interface melhorada)

## Melhorias de UX
1. Mensagens de carregamento mais descritivas
2. Estados vazios visuais e intuitivos
3. Diálogos em vez de SnackBars para ações críticas
4. Confirmações de ações destrutivas
5. Feedback visual coerente com tema Hexatombe
6. Bordas consistentes (6-8px)
7. Cores semânticas e contextuais

