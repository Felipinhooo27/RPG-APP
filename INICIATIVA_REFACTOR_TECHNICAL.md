# Documentação Técnica - Refatoração IniciativaScreen

## 1. Loading State com HexLoading

### Antes
```dart
_isLoadingCharacters ? const Center(child: HexLoading.large()) : ...
```

### Depois
```dart
_isLoadingCharacters
    ? Center(
        child: HexLoading.large(
          message: 'Carregando combatentes...',
        ),
      )
    : ...
```

**Impacto**: Melhor feedback ao usuário durante carregamento

---

## 2. Estados Vazios

### Character Selection Vazio

**Código**:
```dart
_allCharacters.isEmpty
    ? const EmptyState(
        icon: Icons.shield_outlined,
        title: 'Nenhum Combatente',
        message: 'Crie personagens primeiro para iniciar um combate',
      )
    : ListView(...)
```

### Combat Vazio

**Código**:
```dart
session.combatentes.isEmpty
    ? const EmptyState.noCombat()
    : ListView.builder(...)
```

---

## 3. Dialog Implementation Pattern

### Padrão Base para Todos os Diálogos

1. **Dialog com fundo transparente**
2. **RitualCard com glow contextual**
3. **Icon em container 64x64 com sombra**
4. **Título em CAPS com BebasNeue**
5. **Mensagem em coldGray com Montserrat**
6. **Row com GlowingButton(s)**

### Dialog 1: Erro Inicial
- **Cor**: ritualRed
- **Ícone**: warning_outlined
- **Título**: "AVISO"
- **Botão**: Um "Entendido"

### Dialog 2: Re-rolar Iniciativa
- **Cor**: etherealPurple
- **Ícone**: shuffle
- **Botões**: Cancelar + Confirmar
- **Ação**: Re-rola todas as iniciativas

### Dialog 3: Finalizar Combate
- **Cor**: alertYellow
- **Ícone**: stop_circle_outlined
- **Botões**: Cancelar + Encerrar
- **Ação**: Chama _finalizarCombate()

### Dialog 4: Remover Combatente
- **Cor**: ritualRed
- **Ícone**: person_remove_outlined
- **Botões**: Cancelar + Remover
- **Ação**: Remove do session

---

## 4. BorderRadius Standardização

| Elemento | Tamanho | BorderRadius |
|----------|---------|--------------|
| Checkbox | 48x48 | circular(6) |
| Icon Container | 64x64 | circular(8) |
| Badges | Médio | circular(6) |
| Buttons | Médio | circular(6) |
| Progress Bar | - | circular(3) |

---

## 5. GlowingButton Estilos

- **primary** (ritualRed)
- **secondary** (etherealPurple)
- **danger** (alertYellow)
- **occult** (chaoticMagenta)

---

## 6. Imports via widgets.dart

Todos os componentes estão disponíveis via:
```dart
import '../widgets/widgets.dart';
```

- HexLoading
- EmptyState
- RitualCard
- GlowingButton
- HexatombeBackground

---

## 7. Validação de Código

- Análise: Sem erros críticos
- Sintaxe: Válida
- Imports: Completos
- Funcionalidade: Preservada

