import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/skill.dart';

/// Badge de perícia com nível de treinamento
class SkillBadge extends StatefulWidget {
  final Skill skill;
  final VoidCallback? onTap;
  final bool compact;
  final int? attributeModifier;

  const SkillBadge({
    super.key,
    required this.skill,
    this.onTap,
    this.compact = false,
    this.attributeModifier,
  });

  @override
  State<SkillBadge> createState() => _SkillBadgeState();
}

class _SkillBadgeState extends State<SkillBadge> {
  bool _isPressed = false;

  Color get categoryColor {
    switch (widget.skill.category) {
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

  /// Retorna apenas o bônus de treinamento (sem atributo)
  /// Conforme solicitado: perícias treinadas mostram +5, +10, +15
  int get trainingBonus {
    return widget.skill.getTrainingBonusOnly();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactBadge();
    }
    return _buildFullBadge();
  }

  Widget _buildFullBadge() {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.obscureGray,
                AppTheme.industrialGray.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: widget.skill.level != SkillLevel.untrained
                ? [
                    BoxShadow(
                      color: categoryColor.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppTheme.coldGray.withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Ícone da categoria
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: categoryColor.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  _getCategoryIcon(),
                  color: categoryColor,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              // Nome e atributo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.skill.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.paleWhite,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          widget.skill.attribute ?? 'N/A',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: categoryColor,
                            fontFamily: 'SpaceMono',
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildTrainingIndicator(),
                      ],
                    ),
                  ],
                ),
              ),

              // Bônus total
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: categoryColor.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  trainingBonus >= 0 ? '+$trainingBonus' : '$trainingBonus',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: categoryColor,
                    fontFamily: 'SpaceMono',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: -0.2, end: 0, duration: 300.ms);
  }

  Widget _buildCompactBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.obscureGray,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: widget.skill.level == SkillLevel.untrained
                ? AppTheme.coldGray.withOpacity(0.3)
                : categoryColor.withOpacity(0.4),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.skill.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.paleWhite,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(width: 8),
          Text(
            trainingBonus >= 0 ? '+$trainingBonus' : '$trainingBonus',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: categoryColor,
              fontFamily: 'SpaceMono',
            ),
          ),
        ],
      ),
    );
  }

  /// Indicador visual do nível de treinamento
  Widget _buildTrainingIndicator() {
    final levelIndex = widget.skill.level.index;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final isFilled = index < levelIndex;
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? categoryColor : categoryColor.withOpacity(0.2),
            boxShadow: [
              BoxShadow(
                color: categoryColor.withOpacity(0.5),
                blurRadius: 2,
                spreadRadius: 0,
              ),
            ],
          ),
        );
      }),
    );
  }

  IconData _getCategoryIcon() {
    switch (widget.skill.category) {
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
}

/// Grid de perícias para exibir múltiplas
class SkillGrid extends StatelessWidget {
  final List<Skill> skills;
  final Function(Skill skill)? onSkillTap;
  final int Function(String attribute)? getAttributeModifier;
  final bool compact;

  const SkillGrid({
    super.key,
    required this.skills,
    this.onSkillTap,
    this.getAttributeModifier,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        final attrMod = skill.attribute != null && getAttributeModifier != null
            ? getAttributeModifier!(skill.attribute!)
            : null;

        return SkillBadge(
          skill: skill,
          onTap: onSkillTap != null ? () => onSkillTap!(skill) : null,
          compact: compact,
          attributeModifier: attrMod,
        );
      },
    );
  }
}

/// Seletor de nível de perícia (para criação/edição)
class SkillLevelSelector extends StatelessWidget {
  final SkillLevel currentLevel;
  final ValueChanged<SkillLevel> onLevelChanged;
  final Color color;

  const SkillLevelSelector({
    super.key,
    required this.currentLevel,
    required this.onLevelChanged,
    this.color = AppTheme.ritualRed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: SkillLevel.values.map((level) {
        final isSelected = level == currentLevel;
        return Expanded(
          child: GestureDetector(
            onTap: () => onLevelChanged(level),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? color.withOpacity(0.4)
                        : AppTheme.coldGray.withOpacity(0.3),
                    blurRadius: isSelected ? 8 : 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _getLevelName(level),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? color : AppTheme.coldGray,
                      fontFamily: 'Montserrat',
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getLevelBonus(level),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? color : AppTheme.coldGray,
                      fontFamily: 'SpaceMono',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getLevelName(SkillLevel level) {
    switch (level) {
      case SkillLevel.untrained:
        return 'SEM\nTREINO';
      case SkillLevel.trained:
        return 'TREINADO';
      case SkillLevel.veteran:
        return 'VETERANO';
      case SkillLevel.expert:
        return 'EXPERT';
    }
  }

  String _getLevelBonus(SkillLevel level) {
    switch (level) {
      case SkillLevel.untrained:
        return '+0';
      case SkillLevel.trained:
        return '+5';
      case SkillLevel.veteran:
        return '+10';
      case SkillLevel.expert:
        return '+15';
    }
  }
}
