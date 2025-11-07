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
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.abyssalBlack,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: _buildHeader(),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: AppTheme.ritualRed,
                  labelColor: AppTheme.ritualRed,
                  unselectedLabelColor: AppTheme.coldGray,
                  labelStyle: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                  tabs: const [
                    Tab(text: 'STATUS'),
                    Tab(text: 'ATRIBUTOS'),
                    Tab(text: 'PERÍCIAS'),
                    Tab(text: 'OUTROS'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildStatusTab(),
              _buildAttributesTab(),
              _buildSkillsTab(),
              _buildOthersTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.abyssalBlack,
            AppTheme.obscureGray.withOpacity(0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          const Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: RitualGridPattern(spacing: 30),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar/Icon - Modern circular with radial gradient
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const RadialGradient(
                            colors: [AppTheme.ritualRed, AppTheme.chaoticMagenta],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.ritualRed.withOpacity(0.5),
                              blurRadius: 16,
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: AppTheme.abyssalBlack.withOpacity(0.3),
                              blurRadius: 4,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _currentCharacter.nome.isNotEmpty
                                ? _currentCharacter.nome[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 36,
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
                          children: [
                            Text(
                              widget.character.nome.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'BebasNeue',
                                color: AppTheme.paleWhite,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (widget.character.patente.isNotEmpty)
                              Text(
                                widget.character.patente,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.ritualRed,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _buildBadge('NEX ${widget.character.nex}%', AppTheme.chaoticMagenta),
                                if (widget.character.classe.isNotEmpty)
                                  _buildBadge(
                                    widget.character.classe.length > 12
                                        ? '${widget.character.classe.substring(0, 12)}...'
                                        : widget.character.classe,
                                    AppTheme.etherealPurple,
                                  ),
                                if (widget.character.origem.isNotEmpty)
                                  _buildBadge(
                                    widget.character.origem.length > 10
                                        ? '${widget.character.origem.substring(0, 10)}...'
                                        : widget.character.origem,
                                    AppTheme.mutagenGreen,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppTheme.abyssalBlack.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          fontFamily: 'Montserrat',
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ========== TAB 1: STATUS ==========
  Widget _buildStatusTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // PV
          _buildStatusCard(
            label: 'PONTOS DE VIDA',
            icon: Icons.favorite,
            current: _pvAtual,
            max: widget.character.pvMax,
            color: AppTheme.ritualRed,
            onChanged: (value) {
              setState(() => _pvAtual = value.clamp(0, widget.character.pvMax));
              _updateStatus(pvAtual: _pvAtual);
            },
          ),
          const SizedBox(height: 24),

          // PE
          _buildStatusCard(
            label: 'PONTOS DE ESFORÇO',
            icon: Icons.bolt,
            current: _peAtual,
            max: widget.character.peMax,
            color: AppTheme.mutagenGreen,
            onChanged: (value) {
              setState(() => _peAtual = value.clamp(0, widget.character.peMax));
              _updateStatus(peAtual: _peAtual);
            },
          ),
          const SizedBox(height: 24),

          // PS
          _buildStatusCard(
            label: 'PONTOS DE SANIDADE',
            icon: Icons.psychology,
            current: _psAtual,
            max: widget.character.psMax,
            color: AppTheme.etherealPurple,
            onChanged: (value) {
              setState(() => _psAtual = value.clamp(0, widget.character.psMax));
              _updateStatus(psAtual: _psAtual);
            },
          ),
          const SizedBox(height: 24),

          // Créditos
          _buildCreditsCard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required String label,
    required IconData icon,
    required int current,
    required int max,
    required Color color,
    required Function(int) onChanged,
  }) {
    final percentage = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.obscureGray,
            AppTheme.industrialGray.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppTheme.abyssalBlack.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: -2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontFamily: 'Montserrat',
                    letterSpacing: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          Stack(
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.industrialGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Container(
                height: 40,
                width: MediaQuery.of(context).size.width * percentage * 0.85,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.6),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              Container(
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  '$current / $max',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.paleWhite,
                    fontFamily: 'BebasNeue',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(Icons.remove_circle, () => onChanged(current - 5), color),
              const SizedBox(width: 8),
              _buildControlButton(Icons.remove, () => onChanged(current - 1), color),
              const SizedBox(width: 16),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              _buildControlButton(Icons.add, () => onChanged(current + 1), color),
              const SizedBox(width: 8),
              _buildControlButton(Icons.add_circle, () => onChanged(current + 5), color),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed, Color color) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.obscureGray,
              AppTheme.industrialGray.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: AppTheme.abyssalBlack.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildCreditsCard() {
    return RitualCard(
      glowEffect: true,
      glowColor: AppTheme.alertYellow,
      ritualCorners: true,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.alertYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.alertYellow.withOpacity(0.35),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(Icons.attach_money, color: AppTheme.alertYellow, size: 28),
              ),
              const SizedBox(width: 12),
              const Text(
                'CRÉDITOS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.alertYellow,
                  fontFamily: 'Montserrat',
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'T\$ $_creditos',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: AppTheme.alertYellow,
              fontFamily: 'BebasNeue',
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(Icons.remove_circle, () {
                setState(() => _creditos = (_creditos - 10).clamp(0, 999999));
                _updateStatus(creditos: _creditos);
              }, AppTheme.alertYellow),
              const SizedBox(width: 8),
              _buildControlButton(Icons.remove, () {
                setState(() => _creditos = (_creditos - 1).clamp(0, 999999));
                _updateStatus(creditos: _creditos);
              }, AppTheme.alertYellow),
              const SizedBox(width: 16),
              _buildControlButton(Icons.add, () {
                setState(() => _creditos = (_creditos + 1).clamp(0, 999999));
                _updateStatus(creditos: _creditos);
              }, AppTheme.alertYellow),
              const SizedBox(width: 8),
              _buildControlButton(Icons.add_circle, () {
                setState(() => _creditos = (_creditos + 10).clamp(0, 999999));
                _updateStatus(creditos: _creditos);
              }, AppTheme.alertYellow),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ========== TAB 2: ATRIBUTOS ==========
  Widget _buildAttributesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AttributeGrid(
            forca: widget.character.forca,
            agilidade: widget.character.agilidade,
            vigor: widget.character.vigor,
            inteligencia: widget.character.inteligencia,
            presenca: widget.character.presenca,
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 24),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return RitualCard(
      glowEffect: false,
      ritualCorners: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INFORMAÇÕES',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.ritualRed,
              fontFamily: 'BebasNeue',
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('ORIGEM', widget.character.origem),
          _buildInfoRow('CLASSE', widget.character.classe),
          if (widget.character.trilha.isNotEmpty)
            _buildInfoRow('TRILHA', widget.character.trilha),
          _buildInfoRow('INICIATIVA', '+${widget.character.iniciativaBase}'),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.coldGray,
              fontFamily: 'Montserrat',
              letterSpacing: 1,
            ),
          ),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.paleWhite,
              fontFamily: 'SpaceMono',
            ),
          ),
        ],
      ),
    );
  }

  // ========== TAB 3: PERÍCIAS ==========
  Widget _buildSkillsTab() {
    final hasSkills = _currentCharacter.pericias.isNotEmpty;

    if (!hasSkills) {
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
                    color: AppTheme.alertYellow.withOpacity(0.35),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.school,
                size: 60,
                color: AppTheme.alertYellow,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'NENHUMA PERÍCIA',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.coldGray,
                fontFamily: 'BebasNeue',
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            GlowingButton(
              label: 'Configurar Perícias',
              icon: Icons.add,
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
              style: GlowingButtonStyle.primary,
            ),
          ],
        ),
      );
    }

    // Filter out untrained skills
    final trainedSkills = _currentCharacter.pericias.values
        .where((skill) => skill.level != SkillLevel.untrained)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trainedSkills.length,
      itemBuilder: (context, index) {
        final skill = trainedSkills[index];
        final attrMod = skill.attribute != null
            ? _currentCharacter.getModifier(skill.attribute!)
            : 0;

        return SkillBadge(
          skill: skill,
          attributeModifier: attrMod,
          onTap: () async {
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
        );
      },
    );
  }

  // ========== TAB 4: OUTROS ==========
  Widget _buildOthersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          RitualCardLarge(
            title: 'Inventário',
            subtitle: '${widget.character.inventario.length} itens',
            icon: const Icon(Icons.backpack, color: AppTheme.mutagenGreen, size: 32),
            accentColor: AppTheme.mutagenGreen,
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
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 16),
          RitualCardLarge(
            title: 'Poderes',
            subtitle: '${widget.character.poderes.length} poderes',
            icon: const Icon(Icons.auto_fix_high, color: AppTheme.etherealPurple, size: 32),
            accentColor: AppTheme.etherealPurple,
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
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
        ],
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
