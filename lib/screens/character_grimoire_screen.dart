import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/character.dart';
import '../models/skill.dart';
import '../services/local_database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'skills_selection_screen.dart';
import 'inventory_screen.dart';
import 'powers_screen.dart';

/// Ficha de personagem redesenhada como grimório
class CharacterGrimoireScreen extends StatefulWidget {
  final Character character;
  final bool isMasterMode;

  const CharacterGrimoireScreen({
    super.key,
    required this.character,
    required this.isMasterMode,
  });

  @override
  State<CharacterGrimoireScreen> createState() => _CharacterGrimoireScreenState();
}

class _CharacterGrimoireScreenState extends State<CharacterGrimoireScreen>
    with SingleTickerProviderStateMixin {
  final LocalDatabaseService _dbService = LocalDatabaseService();
  late TabController _tabController;
  late Character _currentCharacter;

  late int _pvAtual;
  late int _peAtual;
  late int _psAtual;
  late int _creditos;

  @override
  void initState() {
    super.initState();
    _currentCharacter = widget.character;
    _tabController = TabController(length: 4, vsync: this);
    _pvAtual = widget.character.pvAtual;
    _peAtual = widget.character.peAtual;
    _psAtual = widget.character.psAtual;
    _creditos = widget.character.creditos;
  }

  Future<void> _reloadCharacter() async {
    final reloadedCharacter = await _dbService.getCharacter(widget.character.id);
    if (reloadedCharacter != null && mounted) {
      setState(() {
        _currentCharacter = reloadedCharacter;
        _pvAtual = reloadedCharacter.pvAtual;
        _peAtual = reloadedCharacter.peAtual;
        _psAtual = reloadedCharacter.psAtual;
        _creditos = reloadedCharacter.creditos;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HexatombeBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppTheme.obscureGray.withOpacity(0.95),
          elevation: 0,
          toolbarHeight: 100,
          title: _buildCompactHeader(),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.ritualRed,
            indicatorWeight: 2,
            labelColor: AppTheme.ritualRed,
            unselectedLabelColor: AppTheme.coldGray,
            labelStyle: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 1,
            ),
            tabs: const [
              Tab(text: 'STATUS'),
              Tab(text: 'ATRIBUTOS'),
              Tab(text: 'PERÍCIAS'),
              Tab(text: 'OUTROS'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildCompactStatusTab(),
            _buildCompactAttributesTab(),
            _buildCompactSkillsTab(),
            _buildCompactOthersTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Row(
      children: [
        // Avatar compacto
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.ritualRed,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.ritualRed.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              _currentCharacter.nome.isNotEmpty
                  ? _currentCharacter.nome[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.paleWhite,
                fontFamily: 'BebasNeue',
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.character.nome.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'BebasNeue',
                  color: AppTheme.paleWhite,
                  letterSpacing: 1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (widget.character.patente.isNotEmpty) ...[
                    Text(
                      widget.character.patente,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.ritualRed,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 12,
                      color: AppTheme.industrialGray,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    'NEX ${widget.character.nex}%',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.chaoticMagenta,
                      fontFamily: 'SpaceMono',
                    ),
                  ),
                  if (widget.character.classe.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 12,
                      color: AppTheme.industrialGray,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.character.classe.length > 10
                          ? '${widget.character.classe.substring(0, 10)}...'
                          : widget.character.classe,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.etherealPurple,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ========== TAB 1: STATUS - COMPACTO ==========
  Widget _buildCompactStatusTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCompactResourceBar(
            label: 'PV',
            icon: Icons.favorite,
            current: _pvAtual,
            max: widget.character.pvMax,
            color: AppTheme.ritualRed,
            onChanged: (value) {
              setState(() => _pvAtual = value.clamp(0, widget.character.pvMax));
              _updateStatus(pvAtual: _pvAtual);
            },
          ),
          _buildCompactResourceBar(
            label: 'PE',
            icon: Icons.bolt,
            current: _peAtual,
            max: widget.character.peMax,
            color: AppTheme.etherealPurple,
            onChanged: (value) {
              setState(() => _peAtual = value.clamp(0, widget.character.peMax));
              _updateStatus(peAtual: _peAtual);
            },
          ),
          _buildCompactResourceBar(
            label: 'PS',
            icon: Icons.psychology,
            current: _psAtual,
            max: widget.character.psMax,
            color: AppTheme.alertYellow,
            onChanged: (value) {
              setState(() => _psAtual = value.clamp(0, widget.character.psMax));
              _updateStatus(psAtual: _psAtual);
            },
          ),
          _buildCompactResourceBar(
            label: 'T\$',
            icon: Icons.attach_money,
            current: _creditos,
            max: 99999,
            color: AppTheme.mutagenGreen,
            onChanged: (value) {
              setState(() => _creditos = value.clamp(0, 99999));
              _updateStatus(creditos: _creditos);
            },
            showMax: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactResourceBar({
    required String label,
    required IconData icon,
    required int current,
    required int max,
    required Color color,
    required Function(int) onChanged,
    bool showMax = true,
  }) {
    final percentage = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFamily: 'Montserrat',
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                showMax ? '$current / $max' : '$current',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.paleWhite,
                  fontFamily: 'SpaceMono',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.industrialGray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: percentage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildCompactButton(Icons.remove, () => onChanged(current - 1), color),
              const SizedBox(width: 4),
              _buildCompactButton(Icons.add, () => onChanged(current + 1), color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactButton(IconData icon, VoidCallback onPressed, Color color) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.obscureGray,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }


  // ========== TAB 2: ATRIBUTOS - COMPACTO ==========
  Widget _buildCompactAttributesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Layout horizontal: Hexágonos à esquerda, Info à direita
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hexágonos menores e mais compactos
              Expanded(
                flex: 5,
                child: Transform.scale(
                  scale: 0.75,
                  child: AttributeGrid(
                    forca: widget.character.forca,
                    agilidade: widget.character.agilidade,
                    vigor: widget.character.vigor,
                    inteligencia: widget.character.inteligencia,
                    presenca: widget.character.presenca,
                  ),
                ),
              ),

              // Barra vertical divisória
              Container(
                width: 1,
                height: 280,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: AppTheme.industrialGray.withOpacity(0.3),
              ),

              // Informações em lista vertical compacta
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildInlineInfoRow('ORIGEM', widget.character.origem),
                    _buildInfoDivider(),
                    _buildInlineInfoRow('NEX', '${widget.character.nex}%'),
                    _buildInfoDivider(),
                    _buildInlineInfoRow('CLASSE', widget.character.classe),
                    _buildInfoDivider(),
                    _buildInlineInfoRow('INIT', '+${widget.character.iniciativaBase}'),
                    if (widget.character.trilha.isNotEmpty) ...[
                      _buildInfoDivider(),
                      _buildInlineInfoRow('TRILHA', widget.character.trilha),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Seção de defesas e movimento
          _buildDefenseSection(),
        ],
      ),
    );
  }

  Widget _buildInlineInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppTheme.coldGray,
              fontFamily: 'Montserrat',
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.paleWhite,
              fontFamily: 'Inter',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDivider() {
    return Container(
      height: 1,
      color: AppTheme.industrialGray.withOpacity(0.2),
    );
  }

  Widget _buildDefenseSection() {
    // Calcular defesa e bloqueio
    final agilidadeMod = ((widget.character.agilidade - 10) / 2).floor();
    final defesa = 10 + agilidadeMod;
    final bloqueio = defesa; // Simplificado, ajustar conforme regras

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.obscureGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.industrialGray.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'COMBATE',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.ritualRed,
              fontFamily: 'Montserrat',
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDefenseStat(
                  'DEFESA',
                  defesa.toString(),
                  Icons.shield_outlined,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.industrialGray.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _buildDefenseStat(
                  'BLOQUEIO',
                  bloqueio.toString(),
                  Icons.back_hand_outlined,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.industrialGray.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _buildDefenseStat(
                  'DESLOCAMENTO',
                  '9m',
                  Icons.directions_run,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefenseStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.limestoneGray.withOpacity(0.7),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.paleWhite,
            fontFamily: 'SpaceMono',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: AppTheme.coldGray,
            fontFamily: 'Montserrat',
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }


  // ========== TAB 3: PERÍCIAS - COMPACTO ==========
  Widget _buildCompactSkillsTab() {
    final hasSkills = _currentCharacter.pericias.isNotEmpty;

    if (!hasSkills) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 48,
              color: AppTheme.coldGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'NENHUMA PERÍCIA',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.coldGray,
                fontFamily: 'Montserrat',
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SkillsSelectionScreen(
                      character: _currentCharacter,
                    ),
                  ),
                );
                await _reloadCharacter();
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Configurar Perícias'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.ritualRed,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Filter out untrained skills
    final trainedSkills = _currentCharacter.pericias.values
        .where((skill) => skill.level != SkillLevel.untrained)
        .toList();

    return Column(
      children: [
        // Header com botão inline
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.industrialGray.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.school, size: 18, color: AppTheme.coldGray),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${trainedSkills.length} PERÍCIAS TREINADAS',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.coldGray,
                    fontFamily: 'Montserrat',
                    letterSpacing: 1,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SkillsSelectionScreen(
                        character: _currentCharacter,
                      ),
                    ),
                  );
                  await _reloadCharacter();
                },
                child: const Text(
                  'Editar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
        ),
        // Lista de perícias
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: trainedSkills.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.industrialGray,
            ),
            itemBuilder: (context, index) {
              final skill = trainedSkills[index];
              final attrMod = skill.attribute != null
                  ? _currentCharacter.getModifier(skill.attribute!)
                  : 0;

              return _buildCompactSkillRow(skill, attrMod);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompactSkillRow(Skill skill, int attrMod) {
    final total = skill.getBonus(attrMod);

    // Converter enum para string legível
    String getLevelName(SkillLevel level) {
      switch (level) {
        case SkillLevel.untrained:
          return 'Destreinado';
        case SkillLevel.trained:
          return 'Treinado';
        case SkillLevel.veteran:
          return 'Veterano';
        case SkillLevel.expert:
          return 'Expert';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.paleWhite,
                    fontFamily: 'Montserrat',
                  ),
                ),
                if (skill.attribute != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${skill.attribute!} • ${getLevelName(skill.level)}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.coldGray,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.obscureGray,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppTheme.ritualRed.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              total >= 0 ? '+$total' : '$total',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.ritualRed,
                fontFamily: 'SpaceMono',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== TAB 4: OUTROS - COMPACTO ==========
  Widget _buildCompactOthersTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCompactActionCard(
            title: 'Inventário',
            subtitle: '${widget.character.inventario.length} itens',
            icon: Icons.backpack,
            color: AppTheme.mutagenGreen,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InventoryScreen(
                    character: widget.character,
                    isMasterMode: widget.isMasterMode,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: AppTheme.industrialGray.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          _buildCompactActionCard(
            title: 'Poderes',
            subtitle: '${widget.character.poderes.length} poderes',
            icon: Icons.auto_fix_high,
            color: AppTheme.etherealPurple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PowersScreen(
                    character: widget.character,
                    isMasterMode: widget.isMasterMode,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.obscureGray.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontFamily: 'Montserrat',
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.coldGray,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus({
    int? pvAtual,
    int? peAtual,
    int? psAtual,
    int? creditos,
  }) async {
    try {
      await _dbService.updateCharacterStatus(
        characterId: widget.character.id,
        pvAtual: pvAtual,
        peAtual: peAtual,
        psAtual: psAtual,
        creditos: creditos,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: $e'),
            backgroundColor: AppTheme.ritualRed,
          ),
        );
      }
    }
  }
}
