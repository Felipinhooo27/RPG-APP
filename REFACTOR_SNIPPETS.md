# Snippets de Codigo - Refatoracao DiceRollerScreen

## 1. BorderRadius Padronizado - Quantidade

**ANTES (Linha 175):**
```dart
Container(
  width: 40,
  height: 40,
  decoration: BoxDecoration(
    color: AppTheme.ritualRed.withOpacity(0.2),
    borderRadius: BorderRadius.circular(8),
    boxShadow: [...]
  ),
)
```

**DEPOIS:**
```dart
Container(
  width: 40,
  height: 40,
  decoration: BoxDecoration(
    color: AppTheme.ritualRed.withOpacity(0.2),
    borderRadius: BorderRadius.circular(6),  // MUDADO: 8 -> 6
    boxShadow: [...]
  ),
)
```

---

## 2. BorderRadius Padronizado - Modificador

**ANTES (Linha 246):**
```dart
decoration: BoxDecoration(
  color: AppTheme.mutagenGreen.withOpacity(0.2),
  borderRadius: BorderRadius.circular(8),
  boxShadow: [...]
)
```

**DEPOIS:**
```dart
decoration: BoxDecoration(
  color: AppTheme.mutagenGreen.withOpacity(0.2),
  borderRadius: BorderRadius.circular(6),  // MUDADO: 8 -> 6
  boxShadow: [...]
)
```

---

## 3. Modal BorderRadius - Historico

**ANTES (Linha 429):**
```dart
Container(
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppTheme.obscureGray, AppTheme.abyssalBlack],
    ),
    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    boxShadow: [...]
  ),
)
```

**DEPOIS:**
```dart
Container(
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppTheme.obscureGray, AppTheme.abyssalBlack],
    ),
    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),  // MUDADO: 20 -> 8
    boxShadow: [...]
  ),
)
```

---

## 4. Dialog Rolagem - RitualCorners

**ANTES (Linha 636):**
```dart
Dialog(
  backgroundColor: Colors.transparent,
  child: RitualCard(
    glowEffect: true,
    glowColor: AppTheme.chaoticMagenta,
    pulsate: _isRolling,
    padding: const EdgeInsets.all(32),
    child: Column(...)
  ),
)
```

**DEPOIS:**
```dart
Dialog(
  backgroundColor: Colors.transparent,
  elevation: 0,  // ADICIONADO
  child: RitualCard(
    glowEffect: true,
    glowColor: AppTheme.chaoticMagenta,
    pulsate: _isRolling,
    ritualCorners: true,  // ADICIONADO
    padding: const EdgeInsets.all(32),
    child: Column(...)
  ),
)
```

---

## 5. Dado - BorderRadius Dialog

**ANTES (Linha 662):**
```dart
child: Container(
  width: 140,
  height: 140,
  decoration: BoxDecoration(
    gradient: const LinearGradient(...),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [...]
  ),
)
```

**DEPOIS:**
```dart
child: Container(
  width: 140,
  height: 140,
  decoration: BoxDecoration(
    gradient: const LinearGradient(...),
    borderRadius: BorderRadius.circular(6),  // MUDADO: 20 -> 6
    boxShadow: [...]
  ),
)
```

---

## 6. Modal Handle - Otimizado

**ANTES (Linha 441):**
```dart
Container(
  margin: const EdgeInsets.symmetric(vertical: 12),
  width: 40,
  height: 4,
  decoration: BoxDecoration(
    color: AppTheme.coldGray,
    borderRadius: BorderRadius.circular(2),
  ),
),
```

**DEPOIS:**
```dart
Container(
  margin: const EdgeInsets.symmetric(vertical: 14),  // MUDADO: 12 -> 14
  width: 42,  // MUDADO: 40 -> 42
  height: 5,  // MUDADO: 4 -> 5
  decoration: BoxDecoration(
    color: AppTheme.coldGray,
    borderRadius: BorderRadius.circular(2.5),  // MUDADO: 2 -> 2.5
  ),
),
```

---

## 7. Delete Button - Redesenhado

**ANTES (Linha 465):**
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text('HISTÓRICO DE ROLAGENS', style: ...),
    IconButton(
      icon: const Icon(Icons.delete_sweep, color: AppTheme.ritualRed),
      onPressed: () {
        setState(() => _history.clear());
        Navigator.pop(context);
      },
      tooltip: 'Limpar histórico',
    ),
  ],
),
```

**DEPOIS:**
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text('HISTÓRICO DE ROLAGENS', style: ...),
    if (_history.isNotEmpty)  // ADICIONADO: condicional
      Tooltip(
        message: 'Limpar histórico',
        child: GestureDetector(
          onTap: () {
            setState(() => _history.clear());
            Navigator.pop(context);
          },
          child: Container(  // REDESENHADO
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.ritualRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.delete_sweep,
              color: AppTheme.ritualRed,
              size: 20,
            ),
          ),
        ),
      ),
  ],
),
```

---

## 8. EmptyState - Novo Widget

**ANTES (Linha 480):**
```dart
Expanded(
  child: _history.isEmpty
      ? const Center(
          child: Text(
            'Nenhuma rolagem no histórico',
            style: TextStyle(
              color: AppTheme.coldGray,
              fontFamily: 'Montserrat',
            ),
          ),
        )
      : ListView.builder(...)
)
```

**DEPOIS:**
```dart
Expanded(
  child: _history.isEmpty
      ? EmptyState(  // NOVO: EmptyState widget
          icon: Icons.history,
          title: 'Nenhuma Rolagem',
          message: 'Role alguns dados para ver o histórico aqui',
          actionLabel: null,
          onAction: null,
        )
      : ListView.builder(...)
)
```

---

## 9. Formula Badge - BorderRadius

**ANTES (Linha 769):**
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: AppTheme.ritualRed.withOpacity(0.2),
    borderRadius: BorderRadius.circular(6),
    boxShadow: [...]
  ),
)
```

**DEPOIS:**
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: AppTheme.ritualRed.withOpacity(0.2),
    borderRadius: BorderRadius.circular(7),  // MUDADO: 6 -> 7
    boxShadow: [...]
  ),
)
```

---

## 10. Imports - Limpeza

**ANTES (Linha 7):**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../utils/dice_roller.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../widgets/empty_state.dart';  // REDUNDANTE
```

**DEPOIS:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../utils/dice_roller.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
// REMOVIDO: import '../widgets/empty_state.dart'; (ja incluido em widgets.dart)
```

---

## Resumo de Mudancas

| Item | Tipo | Localizacao | Mudanca |
|------|------|-------------|---------|
| 1 | BorderRadius | Linha 175 | 8px -> 6px |
| 2 | BorderRadius | Linha 246 | 8px -> 6px |
| 3 | BorderRadius | Linha 429 | 20px -> 8px |
| 4 | Props | Linha 637 | elevation=0, ritualCorners=true |
| 5 | BorderRadius | Linha 662 | 20px -> 6px |
| 6 | Dimensions | Linhas 441-448 | Handle otimizado |
| 7 | Design | Linhas 466-487 | Delete button redesenhado |
| 8 | Widget | Linhas 480-487 | EmptyState adicionado |
| 9 | BorderRadius | Linha 769 | 6px -> 7px |
| 10 | Imports | Linha 7 | Removida redundancia |

**Total: 11 mudancas principais**

