import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../models/character.dart';
import '../models/power.dart';
import '../services/local_database_service.dart';
import '../theme/app_theme.dart';
import '../utils/dice_roller.dart';
import '../widgets/widgets.dart';

class PowersScreen extends StatefulWidget {
  final Character character;
  final bool isMasterMode;

  const PowersScreen({
    super.key,
    required this.character,
    required this.isMasterMode,
  });

  @override
  State<PowersScreen> createState() => _PowersScreenState();
}

class _PowersScreenState extends State<PowersScreen> {
  final _dbService = LocalDatabaseService();
  final _diceRoller = DiceRoller();
  final _uuid = const Uuid();
  late List<Power> _poderes;

  @override
  void initState() {
    super.initState();
    _poderes = List.from(widget.character.poderes);
  }

  Color _getElementColor(String elemento) {
    switch (elemento) {
      case 'Conhecimento':
        return AppTheme.mutagenGreen;
      case 'Energia':
        return AppTheme.alertYellow;
      case 'Morte':
        return AppTheme.obscureGray;
      case 'Sangue':
        return AppTheme.ritualRed;
      case 'Medo':
        return AppTheme.etherealPurple;
      default:
        return AppTheme.etherealPurple;
    }
  }

  IconData _getElementIcon(String elemento) {
    switch (elemento) {
      case 'Conhecimento':
        return Icons.menu_book;
      case 'Energia':
        return Icons.flash_on;
      case 'Morte':
        return Icons.dark_mode;
      case 'Sangue':
        return Icons.water_drop;
      case 'Medo':
        return Icons.psychology;
      default:
        return Icons.auto_fix_high;
    }
  }

  @override
  Widget build(BuildContext context) {
    return HexatombeBackground(
      showParticles: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildPEBar(),
            Expanded(
              child: _poderes.isEmpty ? _buildEmptyState() : _buildPowersList(),
            ),
          ],
        ),
        floatingActionButton: GlowingButton(
          label: 'Adicionar',
          icon: Icons.add,
          onPressed: _addPower,
          style: GlowingButtonStyle.occult,
          pulsateGlow: true,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.abyssalBlack.withOpacity(0.9),
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PODERES PARANORMAIS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'BebasNeue',
              letterSpacing: 2,
              color: AppTheme.etherealPurple,
            ),
          ),
          Text(
            widget.character.nome,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.coldGray,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPEBar() {
    final pePercent = widget.character.peMax > 0
        ? widget.character.peAtual / widget.character.peMax
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.obscureGray.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.etherealPurple.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bolt,
                color: AppTheme.etherealPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'PONTOS DE ESFORÇO (PE)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.etherealPurple,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.character.peAtual} / ${widget.character.peMax}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.etherealPurple,
                  fontFamily: 'BebasNeue',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pePercent,
              minHeight: 12,
              backgroundColor: AppTheme.obscureGray,
              valueColor: AlwaysStoppedAnimation<Color>(
                pePercent > 0.5
                    ? AppTheme.etherealPurple
                    : pePercent > 0.25
                        ? AppTheme.alertYellow
                        : AppTheme.ritualRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.obscureGray,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.etherealPurple.withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_fix_high,
              size: 60,
              color: AppTheme.etherealPurple,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'NENHUM PODER',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.coldGray,
              fontFamily: 'BebasNeue',
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adicione poderes paranormais',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.coldGray,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _poderes.length,
      itemBuilder: (context, index) {
        final power = _poderes[index];
        return _buildPowerCard(power, index)
            .animate()
            .fadeIn(delay: (index * 100).ms, duration: 300.ms)
            .slideX(begin: -0.2, end: 0);
      },
    );
  }

  Widget _buildPowerCard(Power power, int index) {
    final elementColor = _getElementColor(power.elemento);
    final elementIcon = _getElementIcon(power.elemento);

    return GestureDetector(
      onTap: () => _showPowerDetails(power),
      child: RitualCard(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        glowEffect: power.habilidades.isNotEmpty,
        glowColor: elementColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Ícone do elemento
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: elementColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: elementColor.withOpacity(0.4),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    elementIcon,
                    color: elementColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Nome e elemento
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        power.nome.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.paleWhite,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildBadge(power.elemento, elementColor),
                          const SizedBox(width: 8),
                          _buildBadge(
                            '${power.habilidades.length} hab.',
                            AppTheme.coldGray,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Menu
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: AppTheme.coldGray),
                  color: AppTheme.obscureGray,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: AppTheme.etherealPurple, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'Editar',
                            style: TextStyle(
                              color: AppTheme.paleWhite,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: AppTheme.ritualRed, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'Excluir',
                            style: TextStyle(
                              color: AppTheme.paleWhite,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editPower(power);
                    } else if (value == 'delete') {
                      _deletePower(power.id);
                    }
                  },
                ),
              ],
            ),

            // Descrição
            if (power.descricao.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                power.descricao,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.coldGray,
                  fontFamily: 'Montserrat',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Preview das habilidades
            if (power.habilidades.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(color: AppTheme.obscureGray, height: 1),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: power.habilidades.take(3).map((ability) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getAbilityColor(ability.tipo).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: _getAbilityColor(ability.tipo).withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getAbilityIcon(ability.tipo),
                          color: _getAbilityColor(ability.tipo),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          ability.nome,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getAbilityColor(ability.tipo),
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${ability.custo}PE',
                          style: TextStyle(
                            fontSize: 10,
                            color: _getAbilityColor(ability.tipo),
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              if (power.habilidades.length > 3) ...[
                const SizedBox(height: 8),
                Text(
                  '+${power.habilidades.length - 3} habilidades',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.coldGray,
                    fontFamily: 'Montserrat',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Color _getAbilityColor(String tipo) {
    switch (tipo) {
      case 'dano':
        return AppTheme.ritualRed;
      case 'cura':
        return AppTheme.mutagenGreen;
      case 'utilidade':
        return AppTheme.etherealPurple;
      default:
        return AppTheme.coldGray;
    }
  }

  IconData _getAbilityIcon(String tipo) {
    switch (tipo) {
      case 'dano':
        return Icons.flash_on;
      case 'cura':
        return Icons.healing;
      case 'utilidade':
        return Icons.star;
      default:
        return Icons.circle;
    }
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }

  void _showPowerDetails(Power power) {
    showDialog(
      context: context,
      builder: (context) => _PowerDetailsDialog(
        power: power,
        character: widget.character,
        onEdit: () {
          Navigator.pop(context);
          _editPower(power);
        },
        onDelete: () {
          Navigator.pop(context);
          _deletePower(power.id);
        },
        onUseAbility: (ability) {
          Navigator.pop(context);
          _useAbility(power, ability);
        },
      ),
    );
  }

  void _useAbility(Power power, Ability ability) {
    // Verificar se tem PE suficiente
    if (widget.character.peAtual < ability.custo) {
      _showError('PE insuficiente! Necessário: ${ability.custo}');
      return;
    }

    // Se tem fórmula de dano/cura, rolar dados
    if (ability.formulaDano != null && ability.formulaDano!.isNotEmpty) {
      try {
        final result = _diceRoller.roll(ability.formulaDano!);
        _showAbilityResult(
          power: power,
          ability: ability,
          result: result.total.toString(),
          details: result.detailedResult,
        );
      } catch (e) {
        _showError('Erro ao rolar dados: $e');
      }
    } else {
      _showAbilityResult(
        power: power,
        ability: ability,
        result: null,
        details: null,
      );
    }

    // Deduzir PE
    _updatePE(-ability.custo);
  }

  void _showAbilityResult({
    required Power power,
    required Ability ability,
    String? result,
    String? details,
  }) {
    final abilityColor = _getAbilityColor(ability.tipo);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: RitualCard(
          glowEffect: true,
          glowColor: abilityColor,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getAbilityIcon(ability.tipo),
                color: abilityColor,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                ability.nome.toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: abilityColor,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                power.nome,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.paleWhite,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              _buildBadge('${ability.custo} PE gastos', AppTheme.etherealPurple),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.obscureGray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ability.descricao,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.coldGray,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (result != null) ...[
                const SizedBox(height: 16),
                if (details != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.obscureGray.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      details,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.coldGray,
                        fontFamily: 'Montserrat',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: abilityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: abilityColor.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        ability.tipo == 'dano' ? 'DANO' : 'CURA',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: abilityColor,
                          fontFamily: 'BebasNeue',
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        result,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: abilityColor,
                          fontFamily: 'BebasNeue',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (ability.efeitoAdicional != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: abilityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: abilityColor.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: abilityColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ability.efeitoAdicional!,
                          style: TextStyle(
                            fontSize: 12,
                            color: abilityColor,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              GlowingButton(
                label: 'Fechar',
                onPressed: () => Navigator.pop(context),
                style: GlowingButtonStyle.secondary,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9)),
      ),
    );
  }

  Future<void> _updatePE(int change) async {
    final newPE = (widget.character.peAtual + change).clamp(0, widget.character.peMax);

    try {
      final updatedCharacter = widget.character.copyWith(peAtual: newPE);
      await _dbService.updateCharacter(updatedCharacter);

      if (mounted) {
        setState(() {
          // Atualiza o widget interno
        });
      }
    } catch (e) {
      _showError('Erro ao atualizar PE: $e');
    }
  }

  Future<void> _addPower() async {
    final newPower = await showDialog<Power>(
      context: context,
      builder: (context) => const _PowerFormDialog(power: null),
    );

    if (newPower != null) {
      setState(() {
        _poderes.add(newPower.copyWith(id: _uuid.v4()));
      });
      await _savePowers();
    }
  }

  Future<void> _editPower(Power power) async {
    final updatedPower = await showDialog<Power>(
      context: context,
      builder: (context) => _PowerFormDialog(power: power),
    );

    if (updatedPower != null) {
      setState(() {
        final index = _poderes.indexWhere((p) => p.id == power.id);
        if (index != -1) {
          _poderes[index] = updatedPower;
        }
      });
      await _savePowers();
    }
  }

  Future<void> _deletePower(String powerId) async {
    final power = _poderes.firstWhere((p) => p.id == powerId);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: RitualCard(
          glowEffect: true,
          glowColor: AppTheme.ritualRed,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, color: AppTheme.ritualRed, size: 48),
              const SizedBox(height: 16),
              const Text(
                'EXCLUIR PODER',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ritualRed,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Deseja excluir "${power.nome}"?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.paleWhite,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlowingButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.pop(context, false),
                      style: GlowingButtonStyle.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlowingButton(
                      label: 'Excluir',
                      icon: Icons.delete,
                      onPressed: () => Navigator.pop(context, true),
                      style: GlowingButtonStyle.danger,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9)),
      ),
    );

    if (confirm == true) {
      setState(() {
        _poderes.removeWhere((p) => p.id == powerId);
      });
      await _savePowers();
    }
  }

  Future<void> _savePowers() async {
    try {
      final updatedCharacter = widget.character.copyWith(poderes: _poderes);
      await _dbService.updateCharacter(updatedCharacter);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Poderes atualizados!'),
            backgroundColor: AppTheme.mutagenGreen,
          ),
        );
      }
    } catch (e) {
      _showError('Erro ao salvar: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.ritualRed,
        ),
      );
    }
  }
}

// Power Details Dialog
class _PowerDetailsDialog extends StatelessWidget {
  final Power power;
  final Character character;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final void Function(Ability ability) onUseAbility;

  const _PowerDetailsDialog({
    required this.power,
    required this.character,
    required this.onEdit,
    required this.onDelete,
    required this.onUseAbility,
  });

  Color _getElementColor(String elemento) {
    switch (elemento) {
      case 'Conhecimento':
        return AppTheme.mutagenGreen;
      case 'Energia':
        return AppTheme.alertYellow;
      case 'Morte':
        return AppTheme.obscureGray;
      case 'Sangue':
        return AppTheme.ritualRed;
      case 'Medo':
        return AppTheme.etherealPurple;
      default:
        return AppTheme.etherealPurple;
    }
  }

  IconData _getElementIcon(String elemento) {
    switch (elemento) {
      case 'Conhecimento':
        return Icons.menu_book;
      case 'Energia':
        return Icons.flash_on;
      case 'Morte':
        return Icons.dark_mode;
      case 'Sangue':
        return Icons.water_drop;
      case 'Medo':
        return Icons.psychology;
      default:
        return Icons.auto_fix_high;
    }
  }

  Color _getAbilityColor(String tipo) {
    switch (tipo) {
      case 'dano':
        return AppTheme.ritualRed;
      case 'cura':
        return AppTheme.mutagenGreen;
      case 'utilidade':
        return AppTheme.etherealPurple;
      default:
        return AppTheme.coldGray;
    }
  }

  IconData _getAbilityIcon(String tipo) {
    switch (tipo) {
      case 'dano':
        return Icons.flash_on;
      case 'cura':
        return Icons.healing;
      case 'utilidade':
        return Icons.star;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final elementColor = _getElementColor(power.elemento);
    final elementIcon = _getElementIcon(power.elemento);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: RitualCard(
        glowEffect: true,
        glowColor: elementColor,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone do elemento
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: elementColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: elementColor.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(elementIcon, color: elementColor, size: 40),
              ),
              const SizedBox(height: 16),

              // Nome
              Text(
                power.nome.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.paleWhite,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: elementColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: elementColor.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  power.elemento.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: elementColor,
                    fontFamily: 'BebasNeue',
                    letterSpacing: 1,
                  ),
                ),
              ),

              // Descrição
              if (power.descricao.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.obscureGray.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    power.descricao,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.coldGray,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              // Habilidades
              if (power.habilidades.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'HABILIDADES',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.etherealPurple,
                      fontFamily: 'BebasNeue',
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...power.habilidades.map((ability) {
                  final abilityColor = _getAbilityColor(ability.tipo);
                  final canUse = character.peAtual >= ability.custo;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: abilityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: abilityColor.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getAbilityIcon(ability.tipo),
                              color: abilityColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ability.nome,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: abilityColor,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.etherealPurple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.etherealPurple.withOpacity(0.3),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Text(
                                '${ability.custo} PE',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.etherealPurple,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ability.descricao,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.coldGray,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        if (ability.formulaDano != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.casino, color: abilityColor, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Fórmula: ${ability.formulaDano}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: abilityColor,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: GlowingButton(
                            label: canUse ? 'Usar' : 'PE Insuficiente',
                            icon: Icons.bolt,
                            onPressed: canUse ? () => onUseAbility(ability) : null,
                            style: canUse
                                ? GlowingButtonStyle.occult
                                : GlowingButtonStyle.secondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlowingButton(
                      label: 'Editar',
                      icon: Icons.edit,
                      onPressed: onEdit,
                      style: GlowingButtonStyle.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlowingButton(
                      label: 'Excluir',
                      icon: Icons.delete,
                      onPressed: onDelete,
                      style: GlowingButtonStyle.danger,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GlowingButton(
                label: 'Fechar',
                onPressed: () => Navigator.pop(context),
                style: GlowingButtonStyle.secondary,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }
}

// Power Form Dialog - Devido ao tamanho, será necessário continuar no próximo trecho
class _PowerFormDialog extends StatefulWidget {
  final Power? power;

  const _PowerFormDialog({this.power});

  @override
  State<_PowerFormDialog> createState() => _PowerFormDialogState();
}

class _PowerFormDialogState extends State<_PowerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;

  String _selectedElemento = 'Conhecimento';
  List<Ability> _habilidades = [];

  final List<String> _elementos = [
    'Conhecimento',
    'Energia',
    'Morte',
    'Sangue',
    'Medo',
  ];

  @override
  void initState() {
    super.initState();
    final power = widget.power;

    _nomeController = TextEditingController(text: power?.nome ?? '');
    _descricaoController = TextEditingController(text: power?.descricao ?? '');

    if (power != null) {
      _selectedElemento = power.elemento;
      _habilidades = List.from(power.habilidades);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: RitualCard(
        glowEffect: true,
        glowColor: AppTheme.etherealPurple,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.power == null ? 'ADICIONAR PODER' : 'EDITAR PODER',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.etherealPurple,
                    fontFamily: 'BebasNeue',
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _nomeController,
                  label: 'Nome do Poder',
                  validator: (value) =>
                      value?.isEmpty == true ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descricaoController,
                  label: 'Descrição',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedElemento,
                  decoration: InputDecoration(
                    labelText: 'Elemento',
                    labelStyle: const TextStyle(color: AppTheme.coldGray),
                    filled: true,
                    fillColor: AppTheme.obscureGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppTheme.etherealPurple,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppTheme.coldGray,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppTheme.etherealPurple,
                        width: 2,
                      ),
                    ),
                  ),
                  dropdownColor: AppTheme.obscureGray,
                  style: const TextStyle(
                    color: AppTheme.paleWhite,
                    fontFamily: 'Montserrat',
                  ),
                  items: _elementos
                      .map((elem) =>
                          DropdownMenuItem(value: elem, child: Text(elem)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedElemento = value!;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text(
                      'HABILIDADES',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.etherealPurple,
                        fontFamily: 'BebasNeue',
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    GlowingButton(
                      label: 'Adicionar',
                      icon: Icons.add,
                      onPressed: _addAbility,
                      style: GlowingButtonStyle.occult,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_habilidades.isEmpty)
                  const Text(
                    'Nenhuma habilidade adicionada',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.coldGray,
                      fontFamily: 'Montserrat',
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  ..._habilidades.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ability = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.obscureGray.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.coldGray.withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ability.nome,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.paleWhite,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${ability.custo} PE • ${ability.tipo}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.coldGray,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppTheme.ritualRed,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _habilidades.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }),
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
                        label: 'Salvar',
                        icon: Icons.check,
                        onPressed: _savePower,
                        style: GlowingButtonStyle.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        color: AppTheme.paleWhite,
        fontFamily: 'Montserrat',
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.coldGray),
        filled: true,
        fillColor: AppTheme.obscureGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.etherealPurple, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.coldGray, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.etherealPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.ritualRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.ritualRed, width: 2),
        ),
      ),
    );
  }

  Future<void> _addAbility() async {
    final ability = await showDialog<Ability>(
      context: context,
      builder: (context) => _AbilityFormDialog(ability: null),
    );

    if (ability != null) {
      setState(() {
        _habilidades.add(ability.copyWith(id: _uuid.v4()));
      });
    }
  }

  void _savePower() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final power = Power(
      id: widget.power?.id ?? '',
      nome: _nomeController.text,
      descricao: _descricaoController.text,
      elemento: _selectedElemento,
      habilidades: _habilidades,
    );

    Navigator.pop(context, power);
  }
}

// Ability Form Dialog
class _AbilityFormDialog extends StatefulWidget {
  final Ability? ability;

  const _AbilityFormDialog({this.ability});

  @override
  State<_AbilityFormDialog> createState() => _AbilityFormDialogState();
}

class _AbilityFormDialogState extends State<_AbilityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _custoController;
  late TextEditingController _formulaDanoController;
  late TextEditingController _efeitoAdicionalController;

  String _selectedTipo = 'utilidade';
  final List<String> _tipos = ['dano', 'cura', 'utilidade'];

  @override
  void initState() {
    super.initState();
    final ability = widget.ability;

    _nomeController = TextEditingController(text: ability?.nome ?? '');
    _descricaoController = TextEditingController(text: ability?.descricao ?? '');
    _custoController = TextEditingController(text: ability?.custo.toString() ?? '1');
    _formulaDanoController = TextEditingController(text: ability?.formulaDano ?? '');
    _efeitoAdicionalController =
        TextEditingController(text: ability?.efeitoAdicional ?? '');

    if (ability != null) {
      _selectedTipo = ability.tipo;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _custoController.dispose();
    _formulaDanoController.dispose();
    _efeitoAdicionalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: RitualCard(
        glowEffect: true,
        glowColor: AppTheme.etherealPurple,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ADICIONAR HABILIDADE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.etherealPurple,
                    fontFamily: 'BebasNeue',
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _nomeController,
                  label: 'Nome',
                  validator: (value) =>
                      value?.isEmpty == true ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descricaoController,
                  label: 'Descrição',
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _custoController,
                        label: 'Custo (PE)',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty == true ||
                              int.tryParse(value!) == null) {
                            return 'Inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedTipo,
                        decoration: InputDecoration(
                          labelText: 'Tipo',
                          labelStyle: const TextStyle(color: AppTheme.coldGray),
                          filled: true,
                          fillColor: AppTheme.obscureGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.etherealPurple,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.coldGray,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.etherealPurple,
                              width: 2,
                            ),
                          ),
                        ),
                        dropdownColor: AppTheme.obscureGray,
                        style: const TextStyle(
                          color: AppTheme.paleWhite,
                          fontFamily: 'Montserrat',
                        ),
                        items: _tipos
                            .map((tipo) =>
                                DropdownMenuItem(value: tipo, child: Text(tipo)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTipo = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                if (_selectedTipo != 'utilidade') ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _formulaDanoController,
                    label: _selectedTipo == 'dano'
                        ? 'Fórmula de Dano'
                        : 'Fórmula de Cura',
                    hint: 'ex: 2d6+3',
                  ),
                ],
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _efeitoAdicionalController,
                  label: 'Efeito Adicional',
                  hint: 'Descrição de efeitos extras',
                  maxLines: 2,
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
                        label: 'Salvar',
                        icon: Icons.check,
                        onPressed: _saveAbility,
                        style: GlowingButtonStyle.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        color: AppTheme.paleWhite,
        fontFamily: 'Montserrat',
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppTheme.coldGray),
        hintStyle: const TextStyle(color: AppTheme.coldGray),
        filled: true,
        fillColor: AppTheme.obscureGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.etherealPurple, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.coldGray, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.etherealPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.ritualRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.ritualRed, width: 2),
        ),
      ),
    );
  }

  void _saveAbility() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ability = Ability(
      id: widget.ability?.id ?? '',
      nome: _nomeController.text,
      descricao: _descricaoController.text,
      custo: int.parse(_custoController.text),
      tipo: _selectedTipo,
      formulaDano: _formulaDanoController.text.isNotEmpty
          ? _formulaDanoController.text
          : null,
      efeitoAdicional: _efeitoAdicionalController.text.isNotEmpty
          ? _efeitoAdicionalController.text
          : null,
    );

    Navigator.pop(context, ability);
  }
}
