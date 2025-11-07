import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/character.dart';
import '../models/skill.dart';
import '../services/local_database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

/// Tela de seleção e gerenciamento de perícias
class SkillsSelectionScreen extends StatefulWidget {
  final Character character;

  const SkillsSelectionScreen({
    super.key,
    required this.character,
  });

  @override
  State<SkillsSelectionScreen> createState() => _SkillsSelectionScreenState();
}

class _SkillsSelectionScreenState extends State<SkillsSelectionScreen>
    with SingleTickerProviderStateMixin {
  final _dbService = LocalDatabaseService();
  late Map<String, Skill> _pericias;
  late TabController _tabController;
  bool _isLoading = false;

  // Categorias de perícias
  final List<SkillCategory> _categories = SkillCategory.values;

  @override
  void initState() {
    super.initState();
    _pericias = Map.from(widget.character.pericias);
    _tabController = TabController(length: _categories.length, vsync: this);

    // Inicializar perícias se estiverem vazias
    if (_pericias.isEmpty) {
      _initializeSkills();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Inicializar todas as perícias com nível untrained
  void _initializeSkills() {
    final newPericias = <String, Skill>{};

    OrdemSkills.allSkills.forEach((name, data) {
      newPericias[name] = Skill(
        name: name,
        category: SkillCategory.values.firstWhere(
          (c) => c.name == data['category'],
          orElse: () => SkillCategory.investigation,
        ),
        level: SkillLevel.untrained,
        attribute: data['attribute'],
      );
    });

    setState(() {
      _pericias = newPericias;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HexatombeBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppTheme.abyssalBlack,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PERÍCIAS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                  color: AppTheme.ritualRed,
                ),
              ),
              Text(
                widget.character.nome,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.coldGray,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppTheme.ritualRed),
                  ),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.save, color: AppTheme.ritualRed),
                onPressed: _saveSkills,
                tooltip: 'Salvar perícias',
              ),
          ],
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
              letterSpacing: 1,
            ),
            tabs: _categories.map((category) {
              return Tab(
                text: _getCategoryName(category).toUpperCase(),
                icon: Icon(_getCategoryIcon(category), size: 20),
              );
            }).toList(),
          ),
        ),
        body: Column(
          children: [
            // Info sobre pontos de perícia
            _buildSkillPointsInfo(),

            // Lista de perícias por categoria
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _categories.map((category) {
                  return _buildCategoryView(category);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillPointsInfo() {
    final totalTrained = _pericias.values
        .where((s) => s.level != SkillLevel.untrained)
        .length;

    return RitualCard(
      glowEffect: true,
      glowColor: AppTheme.chaoticMagenta,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      ritualCorners: false,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.chaoticMagenta.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.chaoticMagenta.withOpacity(0.35),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.school,
              color: AppTheme.chaoticMagenta,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PERÍCIAS TREINADAS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.coldGray,
                    fontFamily: 'Montserrat',
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalTrained perícia${totalTrained != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.chaoticMagenta,
                    fontFamily: 'BebasNeue',
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildCategoryView(SkillCategory category) {
    final categorySkills = _pericias.values
        .where((s) => s.category == category)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    if (categorySkills.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma perícia nesta categoria',
          style: TextStyle(
            color: AppTheme.coldGray,
            fontFamily: 'Montserrat',
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: categorySkills.length,
      itemBuilder: (context, index) {
        final skill = categorySkills[index];
        final attributeMod = skill.attribute != null
            ? widget.character.getModifier(skill.attribute!)
            : 0;

        return _buildSkillItem(skill, attributeMod);
      },
    );
  }

  Widget _buildSkillItem(Skill skill, int attributeMod) {
    return GestureDetector(
      onTap: () => _showSkillLevelDialog(skill),
      child: SkillBadge(
        skill: skill,
        attributeModifier: attributeMod,
        onTap: () => _showSkillLevelDialog(skill),
      ),
    );
  }

  void _showSkillLevelDialog(Skill skill) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: RitualCard(
          glowEffect: true,
          glowColor: _getCategoryColor(skill.category),
          padding: const EdgeInsets.all(24),
          ritualCorners: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone e nome da perícia
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _getCategoryColor(skill.category).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _getCategoryColor(skill.category).withOpacity(0.35),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  _getCategoryIcon(skill.category),
                  color: _getCategoryColor(skill.category),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                skill.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _getCategoryColor(skill.category),
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_getCategoryName(skill.category)} • ${skill.attribute ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.coldGray,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'SELECIONE O NÍVEL DE TREINAMENTO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.coldGray,
                  fontFamily: 'Montserrat',
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              SkillLevelSelector(
                currentLevel: skill.level,
                onLevelChanged: (newLevel) {
                  setState(() {
                    _pericias[skill.name] = Skill(
                      name: skill.name,
                      category: skill.category,
                      level: newLevel,
                      attribute: skill.attribute,
                    );
                  });
                  Navigator.of(context).pop();
                },
                color: _getCategoryColor(skill.category),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 200.ms)
            .scale(begin: const Offset(0.9, 0.9)),
      ),
    );
  }

  Future<void> _saveSkills() async {
    setState(() => _isLoading = true);

    try {
      await _dbService.updateCharacterSkills(
        characterId: widget.character.id,
        pericias: _pericias,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perícias salvas com sucesso!'),
            backgroundColor: AppTheme.mutagenGreen,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar perícias: $e'),
            backgroundColor: AppTheme.ritualRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getCategoryName(SkillCategory category) {
    switch (category) {
      case SkillCategory.combat:
        return 'Combate';
      case SkillCategory.investigation:
        return 'Investigação';
      case SkillCategory.social:
        return 'Social';
      case SkillCategory.occult:
        return 'Ocultismo';
      case SkillCategory.survival:
        return 'Sobrevivência';
    }
  }

  IconData _getCategoryIcon(SkillCategory category) {
    switch (category) {
      case SkillCategory.combat:
        return Icons.gps_fixed;
      case SkillCategory.investigation:
        return Icons.search;
      case SkillCategory.social:
        return Icons.people;
      case SkillCategory.occult:
        return Icons.auto_fix_high;
      case SkillCategory.survival:
        return Icons.terrain;
    }
  }

  Color _getCategoryColor(SkillCategory category) {
    switch (category) {
      case SkillCategory.combat:
        return AppTheme.ritualRed;
      case SkillCategory.investigation:
        return AppTheme.chaoticMagenta;
      case SkillCategory.social:
        return AppTheme.alertYellow;
      case SkillCategory.occult:
        return AppTheme.etherealPurple;
      case SkillCategory.survival:
        return AppTheme.mutagenGreen;
    }
  }
}
