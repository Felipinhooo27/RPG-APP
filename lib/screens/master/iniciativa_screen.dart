import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/character.dart';
import '../../core/database/character_repository.dart';

/// Rastreador de Iniciativa para Combate
/// Gerencia turnos, ordem de ação e status dos combatentes
class IniciativaScreen extends StatefulWidget {
  const IniciativaScreen({super.key});

  @override
  State<IniciativaScreen> createState() => _IniciativaScreenState();
}

class _IniciativaScreenState extends State<IniciativaScreen> {
  final CharacterRepository _repo = CharacterRepository();
  final List<CombatParticipant> _participants = [];
  int _currentTurn = 1;
  int _currentParticipantIndex = 0;
  bool _combatActive = false;
  final Random _random = Random();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _combatActive
                ? _buildCombatTracker()
                : _buildSetupScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border(
          bottom: BorderSide(color: AppColors.neonRed.withOpacity(0.3), width: 2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.sports_martial_arts, color: AppColors.neonRed, size: 20),
          const SizedBox(width: 8),
          Text(
            'RASTREADOR DE INICIATIVA',
            style: AppTextStyles.uppercase.copyWith(
              fontSize: 14,
              color: AppColors.neonRed,
            ),
          ),
          const Spacer(),
          if (_combatActive) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.neonRed.withOpacity(0.2),
                border: Border.all(color: AppColors.neonRed),
              ),
              child: Text(
                'TURNO $_currentTurn',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neonRed,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.stop_circle, color: AppColors.neonRed),
              onPressed: _endCombat,
              tooltip: 'Encerrar combate',
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================================
  // TELA DE CONFIGURAÇÃO (antes do combate começar)
  // ==========================================================================
  Widget _buildSetupScreen() {
    return Column(
      children: [
        Expanded(
          child: _participants.isEmpty
              ? _buildEmptyState()
              : _buildParticipantList(),
        ),
        _buildSetupActions(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group_off, size: 64, color: AppColors.silver),
          const SizedBox(height: 16),
          Text(
            'NENHUM COMBATENTE',
            style: AppTextStyles.title.copyWith(
              color: AppColors.silver.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione personagens para começar o combate',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.silver.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _participants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final participant = _participants[index];
        return _buildParticipantCard(participant, index);
      },
    );
  }

  Widget _buildParticipantCard(CombatParticipant participant, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border.all(color: AppColors.silver.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Iniciativa
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.neonRed.withOpacity(0.2),
              border: Border.all(color: AppColors.neonRed, width: 2),
            ),
            child: Center(
              child: Text(
                participant.iniciativa.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neonRed,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.nome.toUpperCase(),
                  style: AppTextStyles.uppercase.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'PV: ${participant.pvAtual}/${participant.pvMax}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.pvRed.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Remover
          IconButton(
            icon: Icon(Icons.close, color: AppColors.silver.withOpacity(0.5)),
            onPressed: () => setState(() => _participants.removeAt(index)),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border(
          top: BorderSide(color: AppColors.silver.withOpacity(0.3)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _addFromCharacters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.conhecimentoGreen,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text('ADICIONAR PERSONAGEM'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _addCustomCombatant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.magenta,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text('ADICIONAR INIMIGO'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _participants.isEmpty ? null : _startCombat,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonRed,
                disabledBackgroundColor: AppColors.darkGray,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: const Text('INICIAR COMBATE'),
            ),
          ),
        ],
      ),
    );
  }

  void _addFromCharacters() async {
    final characters = await _repo.getAll();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text('SELECIONE PERSONAGEM'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: characters.length,
            separatorBuilder: (_, __) => const Divider(color: AppColors.silver),
            itemBuilder: (context, index) {
              final char = characters[index];
              return ListTile(
                title: Text(
                  char.nome.toUpperCase(),
                  style: AppTextStyles.uppercase.copyWith(fontSize: 12),
                ),
                subtitle: Text('PV: ${char.pvMax} | DEF: ${char.defesa}'),
                onTap: () {
                  Navigator.pop(context);
                  _addParticipant(
                    nome: char.nome,
                    pvMax: char.pvMax,
                    pvAtual: char.pvAtual,
                    defesa: char.defesa,
                    agilidade: char.agilidade,
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
        ],
      ),
    );
  }

  void _addCustomCombatant() {
    final nomeController = TextEditingController();
    final pvController = TextEditingController(text: '10');
    final defesaController = TextEditingController(text: '10');
    final agiController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text('ADICIONAR INIMIGO'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(borderRadius: BorderRadius.zero),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pvController,
              decoration: const InputDecoration(
                labelText: 'PV Máximo',
                border: OutlineInputBorder(borderRadius: BorderRadius.zero),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: defesaController,
              decoration: const InputDecoration(
                labelText: 'Defesa',
                border: OutlineInputBorder(borderRadius: BorderRadius.zero),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: agiController,
              decoration: const InputDecoration(
                labelText: 'Agilidade',
                border: OutlineInputBorder(borderRadius: BorderRadius.zero),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addParticipant(
                nome: nomeController.text.isEmpty ? 'Inimigo' : nomeController.text,
                pvMax: int.tryParse(pvController.text) ?? 10,
                pvAtual: int.tryParse(pvController.text) ?? 10,
                defesa: int.tryParse(defesaController.text) ?? 10,
                agilidade: int.tryParse(agiController.text) ?? 0,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.magenta),
            child: const Text('ADICIONAR'),
          ),
        ],
      ),
    );
  }

  void _addParticipant({
    required String nome,
    required int pvMax,
    required int pvAtual,
    required int defesa,
    required int agilidade,
  }) {
    // Rola d20 + agilidade para iniciativa
    final iniciativa = _random.nextInt(20) + 1 + agilidade;

    setState(() {
      _participants.add(CombatParticipant(
        nome: nome,
        iniciativa: iniciativa,
        pvMax: pvMax,
        pvAtual: pvAtual,
        defesa: defesa,
      ));

      // Ordena por iniciativa (maior primeiro)
      _participants.sort((a, b) => b.iniciativa.compareTo(a.iniciativa));
    });
  }

  void _startCombat() {
    setState(() {
      _combatActive = true;
      _currentTurn = 1;
      _currentParticipantIndex = 0;
    });
  }

  void _endCombat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        title: const Text('ENCERRAR COMBATE?'),
        content: const Text('Todos os dados serão perdidos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _combatActive = false;
                _participants.clear();
                _currentTurn = 1;
                _currentParticipantIndex = 0;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonRed),
            child: const Text('ENCERRAR'),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // RASTREADOR DE COMBATE ATIVO
  // ==========================================================================
  Widget _buildCombatTracker() {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _participants.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final participant = _participants[index];
              final isActive = index == _currentParticipantIndex;
              return _buildActiveCombatantCard(participant, index, isActive);
            },
          ),
        ),
        _buildCombatActions(),
      ],
    );
  }

  Widget _buildActiveCombatantCard(
    CombatParticipant participant,
    int index,
    bool isActive,
  ) {
    final pvPercentage = participant.pvAtual / participant.pvMax;
    final isDead = participant.pvAtual <= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.neonRed.withOpacity(0.2)
            : isDead
                ? AppColors.morteGray.withOpacity(0.1)
                : AppColors.darkGray,
        border: Border.all(
          color: isActive
              ? AppColors.neonRed
              : isDead
                  ? AppColors.morteGray
                  : AppColors.silver.withOpacity(0.3),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Iniciativa
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.neonRed
                      : AppColors.neonRed.withOpacity(0.2),
                  border: Border.all(color: AppColors.neonRed),
                ),
                child: Center(
                  child: Text(
                    participant.iniciativa.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppColors.deepBlack : AppColors.neonRed,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isActive)
                          const Icon(Icons.play_arrow, color: AppColors.neonRed, size: 16),
                        if (isActive) const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            participant.nome.toUpperCase(),
                            style: AppTextStyles.uppercase.copyWith(
                              fontSize: 13,
                              color: isDead
                                  ? AppColors.silver.withOpacity(0.5)
                                  : AppColors.lightGray,
                            ),
                          ),
                        ),
                        if (isDead)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.morteGray.withOpacity(0.3),
                              border: Border.all(color: AppColors.morteGray),
                            ),
                            child: Text(
                              'MORTO',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: AppColors.morteGray,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Defesa: ${participant.defesa}',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.silver.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Barra de PV
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.deepBlack,
              border: Border.all(color: AppColors.pvRed),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: pvPercentage.clamp(0.0, 1.0),
                  child: Container(color: AppColors.pvRed),
                ),
                Center(
                  child: Text(
                    '${participant.pvAtual} / ${participant.pvMax}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGray,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Controles de PV
          Row(
            children: [
              Expanded(
                child: _buildSmallButton(
                  '-5',
                  () => _modifyPV(index, -5),
                  AppColors.neonRed,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildSmallButton(
                  '-1',
                  () => _modifyPV(index, -1),
                  AppColors.neonRed,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildSmallButton(
                  '+1',
                  () => _modifyPV(index, 1),
                  AppColors.conhecimentoGreen,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildSmallButton(
                  '+5',
                  () => _modifyPV(index, 5),
                  AppColors.conhecimentoGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton(String label, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          border: Border.all(color: color),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  void _modifyPV(int index, int amount) {
    setState(() {
      _participants[index].pvAtual += amount;
      _participants[index].pvAtual = _participants[index]
          .pvAtual
          .clamp(0, _participants[index].pvMax);
    });
  }

  Widget _buildCombatActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border(
          top: BorderSide(color: AppColors.neonRed.withOpacity(0.3), width: 2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'TURNO DE: ${_participants[_currentParticipantIndex].nome.toUpperCase()}',
            style: AppTextStyles.uppercase.copyWith(
              fontSize: 13,
              color: AppColors.neonRed,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextTurn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonRed,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: const Text('PRÓXIMO TURNO'),
            ),
          ),
        ],
      ),
    );
  }

  void _nextTurn() {
    setState(() {
      _currentParticipantIndex++;

      if (_currentParticipantIndex >= _participants.length) {
        _currentParticipantIndex = 0;
        _currentTurn++;
      }
    });
  }
}

// =============================================================================
// MODEL: CombatParticipant
// =============================================================================
class CombatParticipant {
  final String nome;
  final int iniciativa;
  final int pvMax;
  int pvAtual;
  final int defesa;

  CombatParticipant({
    required this.nome,
    required this.iniciativa,
    required this.pvMax,
    required this.pvAtual,
    required this.defesa,
  });
}
