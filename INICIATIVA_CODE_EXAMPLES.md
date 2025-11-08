# Exemplos de Código - Refatoração IniciativaScreen

## 1. HexLoading com Mensagem

```dart
// Localização: Linhas 173-177
_isLoadingCharacters
    ? Center(
        child: HexLoading.large(
          message: 'Carregando combatentes...',
        ),
      )
    : ...
```

---

## 2. EmptyState para Character Selection Vazio

```dart
// Localização: Linhas 180-184
_allCharacters.isEmpty
    ? const EmptyState(
        icon: Icons.shield_outlined,
        title: 'Nenhum Combatente',
        message: 'Crie personagens primeiro para iniciar um combate',
      )
    : ListView(...)
```

---

## 3. EmptyState para Combat Vazio

```dart
// Localização: Linhas 509-510
session.combatentes.isEmpty
    ? const EmptyState.noCombat()
    : ListView.builder(...)
```

---

## 4. RitualCard Character Selection

```dart
// Localização: Linhas 237-373
RitualCard(
  margin: const EdgeInsets.only(bottom: 12),
  padding: const EdgeInsets.all(16),
  glowEffect: isSelected,
  glowColor: AppTheme.ritualRed,
  child: Column(
    children: [
      Row(
        children: [
          // Checkbox 48x48
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedCharacters[character.id] = !isSelected;
                if (!isSelected) {
                  _autoUpdatePV[character.id] = false;
                }
              });
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.ritualRed.withOpacity(0.2)
                    : AppTheme.obscureGray,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: (isSelected
                            ? AppTheme.ritualRed
                            : AppTheme.coldGray)
                        .withOpacity(0.35),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: AppTheme.ritualRed,
                      size: 28,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),

          // Character Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  character.nome.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.paleWhite,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${character.classe} • AGI ${character.agilidade} • Init ${character.iniciativaBase}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.coldGray,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Auto-save toggle (condicional)
      if (isSelected) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.obscureGray.withOpacity(0.5),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: (autoUpdate
                        ? AppTheme.mutagenGreen
                        : AppTheme.coldGray)
                    .withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.save,
                size: 16,
                color: autoUpdate
                    ? AppTheme.mutagenGreen
                    : AppTheme.coldGray,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Auto-Salvar PV na Ficha',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.paleWhite,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              Switch(
                value: autoUpdate,
                onChanged: (value) {
                  setState(() {
                    _autoUpdatePV[character.id] = value;
                  });
                },
                activeColor: AppTheme.mutagenGreen,
              ),
            ],
          ),
        ),
      ],
    ],
  ),
)
```

---

## 5. Dialog Erro Inicial

```dart
// Localização: Linhas 849-916
void _showInitErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: RitualCard(
        glowEffect: true,
        glowColor: AppTheme.ritualRed,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.ritualRed.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.ritualRed.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.warning_outlined,
                color: AppTheme.ritualRed,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'AVISO',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.ritualRed,
                fontFamily: 'BebasNeue',
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.coldGray,
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GlowingButton(
              label: 'Entendido',
              onPressed: () => Navigator.pop(context),
              style: GlowingButtonStyle.primary,
              fullWidth: true,
            ),
          ],
        ),
      ),
    ),
  );
}
```

---

## 6. Dialog Re-rolar Iniciativa

```dart
// Localização: Linhas 918-1017
void _showRerollInitiativeDialog() {
  final session = _combatSession!;

  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: RitualCard(
        glowEffect: true,
        glowColor: AppTheme.etherealPurple,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.etherealPurple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.etherealPurple.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.shuffle,
                color: AppTheme.etherealPurple,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'RE-ROLAR INICIATIVA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.etherealPurple,
                fontFamily: 'BebasNeue',
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Deseja re-rolar a iniciativa de todos os combatentes?',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.coldGray,
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GlowingButton(
                    label: 'Cancelar',
                    onPressed: () => Navigator.pop(context),
                    style: GlowingButtonStyle.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlowingButton(
                    label: 'Confirmar',
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        for (var combatente in session.combatentes) {
                          final dadosRolados = <int>[];
                          final novaIniciativa =
                              _rolarIniciativa(combatente.character, dadosRolados);
                          final novoCombatente = combatente.copyWith(
                            iniciativaTotal: novaIniciativa,
                            dadosRolados: dadosRolados,
                          );
                          final index = session.combatentes.indexOf(combatente);
                          session.combatentes[index] = novoCombatente;
                        }
                        session.ordenarPorIniciativa();
                        session.resetar();
                      });
                    },
                    style: GlowingButtonStyle.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
```

---

## 7. Dialog Finalizar Combate

```dart
// Localização: Linhas 1019-1102
void _showEndCombatDialog() {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: RitualCard(
        glowEffect: true,
        glowColor: AppTheme.alertYellow,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.alertYellow.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.alertYellow.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.stop_circle_outlined,
                color: AppTheme.alertYellow,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'FINALIZAR COMBATE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.alertYellow,
                fontFamily: 'BebasNeue',
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tem certeza que deseja encerrar o combate?',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.coldGray,
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GlowingButton(
                    label: 'Cancelar',
                    onPressed: () => Navigator.pop(context),
                    style: GlowingButtonStyle.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlowingButton(
                    label: 'Encerrar',
                    onPressed: () {
                      Navigator.pop(context);
                      _finalizarCombate();
                    },
                    style: GlowingButtonStyle.danger,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
```

---

## 8. Dialog Remover Combatente

```dart
// Localização: Linhas 1104-1193
void _showRemoveCombatantDialog(
  CombatantTracker combatente,
  int index,
  CombatSession session,
) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: RitualCard(
        glowEffect: true,
        glowColor: AppTheme.ritualRed,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.ritualRed.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.ritualRed.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_remove_outlined,
                color: AppTheme.ritualRed,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'REMOVER COMBATENTE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.ritualRed,
                fontFamily: 'BebasNeue',
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Remover ${combatente.character.nome} do combate?',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.coldGray,
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GlowingButton(
                    label: 'Cancelar',
                    onPressed: () => Navigator.pop(context),
                    style: GlowingButtonStyle.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlowingButton(
                    label: 'Remover',
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        session.removerCombatente(index);
                      });
                    },
                    style: GlowingButtonStyle.danger,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
```

---

## 9. GlowingButton Turn Controls

```dart
// Localização: Linhas 477-500
Row(
  children: [
    Expanded(
      child: GlowingButton(
        label: 'Anterior',
        icon: Icons.arrow_back,
        onPressed: () {
          setState(() {
            session.turnoAnterior();
          });
        },
        style: GlowingButtonStyle.secondary,
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: GlowingButton(
        label: 'Próximo',
        icon: Icons.arrow_forward,
        onPressed: () {
          setState(() {
            session.proximoTurno();
          });
        },
        style: GlowingButtonStyle.danger,
      ),
    ),
  ],
)
```

---

## 10. Mudança no Callback "Iniciar Combate"

```dart
// Localização: Linhas 87-89
if (selectedIds.isEmpty) {
  _showInitErrorDialog('Selecione pelo menos um combatente para iniciar');
  return;
}

// Antes era:
// ScaffoldMessenger.of(context).showSnackBar(
//   const SnackBar(
//     content: Text('Selecione pelo menos um combatente'),
//     backgroundColor: AppTheme.alertYellow,
//   ),
// );
```

