import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/achievement.dart';
import '../../models/character.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Tela de Conquistas (Achievements)
/// Mostra todas as conquistas disponíveis e desbloqueadas
class AchievementsScreen extends StatefulWidget {
  final Character character;

  const AchievementsScreen({
    super.key,
    required this.character,
  });

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Achievement> _achievements = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadAchievements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAchievements() {
    setState(() {
      _achievements = DefaultAchievements.all;
      _checkAndUnlockAchievements();
    });
  }

  /// Verifica e desbloqueia conquistas baseado no personagem atual
  void _checkAndUnlockAchievements() {
    for (var i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      bool shouldUnlock = false;

      switch (achievement.id) {
        case 'first_character':
          shouldUnlock = true; // Se abriu a tela, já tem personagem
          break;
        case 'nex_10':
          shouldUnlock = widget.character.nex >= 10;
          break;
        case 'nex_50':
          shouldUnlock = widget.character.nex >= 50;
          break;
        case 'nex_99':
          shouldUnlock = widget.character.nex >= 99;
          break;
        case 'first_purchase':
          shouldUnlock = widget.character.inventarioIds.isNotEmpty;
          break;
        case 'collector':
          shouldUnlock = widget.character.inventarioIds.length >= 20;
          break;
        case 'rich':
          shouldUnlock = widget.character.creditos >= 10000;
          break;
        case 'full_stats':
          final totalStats = widget.character.forca +
              widget.character.agilidade +
              widget.character.vigor +
              widget.character.intelecto +
              widget.character.presenca;
          shouldUnlock = totalStats >= 25;
          break;
        case 'max_hp':
          shouldUnlock = widget.character.pvMax >= 100;
          break;
        case 'paranormal':
          shouldUnlock = widget.character.poderesIds.length >= 10;
          break;
      }

      if (shouldUnlock && !achievement.isUnlocked) {
        _achievements[i] = achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _achievements.where((a) => a.isUnlocked).length;
    final totalCount = _achievements.length;
    final completionPercentage = (unlockedCount / totalCount * 100).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: AppColors.darkGray,
        title: Text(
          'CONQUISTAS',
          style: AppTextStyles.uppercase.copyWith(fontSize: 14),
        ),
        iconTheme: const IconThemeData(color: AppColors.lightGray),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Barra de progresso geral
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PROGRESSO GERAL',
                          style: AppTextStyles.uppercase.copyWith(
                            fontSize: 11,
                            color: AppColors.energiaYellow,
                          ),
                        ),
                        Text(
                          '$unlockedCount / $totalCount ($completionPercentage%)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.energiaYellow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.deepBlack,
                            border: Border.all(color: AppColors.energiaYellow.withOpacity(0.3)),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: unlockedCount / totalCount,
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.energiaYellow, AppColors.energiaYellow.withOpacity(0.7)],
                              ),
                            ),
                          ),
                        ).animate().scaleX(begin: 0, duration: 1000.ms),
                      ],
                    ),
                  ],
                ),
              ),

              // Tabs por categoria
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.scarletRed,
                labelColor: AppColors.scarletRed,
                unselectedLabelColor: AppColors.silver,
                labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'TODAS'),
                  Tab(text: 'PROGRESSÃO'),
                  Tab(text: 'COMBATE'),
                  Tab(text: 'COLEÇÃO'),
                  Tab(text: 'EXPLORAÇÃO'),
                  Tab(text: 'SOCIAL'),
                  Tab(text: 'GERAL'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAchievementList(null), // Todas
          _buildAchievementList(AchievementCategory.progressao),
          _buildAchievementList(AchievementCategory.combate),
          _buildAchievementList(AchievementCategory.colecao),
          _buildAchievementList(AchievementCategory.exploracao),
          _buildAchievementList(AchievementCategory.social),
          _buildAchievementList(AchievementCategory.geral),
        ],
      ),
    );
  }

  Widget _buildAchievementList(AchievementCategory? category) {
    final filtered = category == null
        ? _achievements
        : _achievements.where((a) => a.category == category).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 64, color: AppColors.silver.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'NENHUMA CONQUISTA',
              style: AppTextStyles.uppercase.copyWith(color: AppColors.silver),
            ),
          ],
        ),
      );
    }

    // Ordenar: desbloqueadas primeiro, depois por categoria
    final sorted = [...filtered]..sort((a, b) {
        if (a.isUnlocked && !b.isUnlocked) return -1;
        if (!a.isUnlocked && b.isUnlocked) return 1;
        return 0;
      });

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final achievement = sorted[index];
        return _buildAchievementCard(achievement, index);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement, int index) {
    final isLocked = !achievement.isUnlocked;
    final color = _getCategoryColor(achievement.category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border.all(
          color: isLocked ? AppColors.silver.withOpacity(0.3) : color,
          width: isLocked ? 1 : 2,
        ),
        boxShadow: !isLocked
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Ícone
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isLocked
                  ? AppColors.deepBlack
                  : color.withOpacity(0.2),
              border: Border.all(
                color: isLocked ? AppColors.silver.withOpacity(0.3) : color,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                achievement.iconCode,
                style: TextStyle(
                  fontSize: 28,
                  color: isLocked ? AppColors.silver.withOpacity(0.3) : color,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title.toUpperCase(),
                        style: AppTextStyles.uppercase.copyWith(
                          fontSize: 13,
                          color: isLocked
                              ? AppColors.silver.withOpacity(0.5)
                              : color,
                        ),
                      ),
                    ),
                    if (!isLocked) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.conhecimentoGreen.withOpacity(0.2),
                          border: Border.all(color: AppColors.conhecimentoGreen),
                        ),
                        child: Text(
                          'DESBLOQUEADA',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: AppColors.conhecimentoGreen,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  achievement.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.silver.withOpacity(isLocked ? 0.5 : 0.8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 14,
                      color: AppColors.energiaYellow.withOpacity(isLocked ? 0.3 : 1),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${achievement.xpReward} XP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.energiaYellow.withOpacity(isLocked ? 0.3 : 1),
                      ),
                    ),
                    const Spacer(),
                    if (achievement.unlockedAt != null) ...[
                      Text(
                        _formatDate(achievement.unlockedAt!),
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.silver.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0);
  }

  Color _getCategoryColor(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.combate:
        return AppColors.neonRed;
      case AchievementCategory.exploracao:
        return AppColors.conhecimentoGreen;
      case AchievementCategory.social:
        return AppColors.magenta;
      case AchievementCategory.progressao:
        return AppColors.energiaYellow;
      case AchievementCategory.colecao:
        return AppColors.medoPurple;
      case AchievementCategory.geral:
        return AppColors.scarletRed;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
