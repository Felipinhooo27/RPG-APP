import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/character.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Dashboard de Estatísticas Visuais
/// Mostra progressão do personagem com gráficos animados
class StatsDashboardScreen extends StatefulWidget {
  final Character character;

  const StatsDashboardScreen({
    super.key,
    required this.character,
  });

  @override
  State<StatsDashboardScreen> createState() => _StatsDashboardScreenState();
}

class _StatsDashboardScreenState extends State<StatsDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: AppColors.darkGray,
        title: Text(
          'ESTATÍSTICAS - ${widget.character.nome.toUpperCase()}',
          style: AppTextStyles.uppercase.copyWith(fontSize: 14),
        ),
        iconTheme: const IconThemeData(color: AppColors.lightGray),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com NEX e Patente
            _buildHeader(),
            const SizedBox(height: 24),

            // Recursos (PV, PE, SAN)
            _buildResourcesSection(),
            const SizedBox(height: 24),

            // Atributos (Radar Chart Style)
            _buildAttributesSection(),
            const SizedBox(height: 24),

            // Estatísticas de Combate
            _buildCombatStatsSection(),
            const SizedBox(height: 24),

            // Progressão (quanto falta para próximo NEX)
            _buildProgressionSection(),
            const SizedBox(height: 24),

            // Inventário Stats
            _buildInventoryStatsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border.all(color: AppColors.scarletRed, width: 2),
      ),
      child: Row(
        children: [
          // Avatar com círculo de NEX
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: widget.character.nex / 100,
                  strokeWidth: 6,
                  backgroundColor: AppColors.deepBlack,
                  valueColor: const AlwaysStoppedAnimation(AppColors.neonRed),
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.scarletRed.withOpacity(0.2),
                  border: Border.all(color: AppColors.scarletRed, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${widget.character.nex}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neonRed,
                    ),
                  ),
                ),
              ),
            ],
          ).animate().scale(delay: 200.ms, duration: 400.ms),

          const SizedBox(width: 20),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.character.classe.name.toUpperCase(),
                  style: AppTextStyles.uppercase.copyWith(
                    fontSize: 18,
                    color: AppColors.scarletRed,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.character.origem.name.toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.silver,
                  ),
                ),
                if (widget.character.trilha != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.character.trilha!.toUpperCase(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.magenta,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildResourcesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECURSOS',
          style: AppTextStyles.uppercase.copyWith(
            fontSize: 14,
            color: AppColors.lightGray,
          ),
        ),
        const SizedBox(height: 12),
        _buildResourceBar(
          'PONTOS DE VIDA',
          widget.character.pvAtual,
          widget.character.pvMax,
          AppColors.pvRed,
          Icons.favorite,
        ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.2, end: 0),
        const SizedBox(height: 12),
        _buildResourceBar(
          'PONTOS DE ESFORÇO',
          widget.character.peAtual,
          widget.character.peMax,
          AppColors.pePurple,
          Icons.flash_on,
        ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.2, end: 0),
        const SizedBox(height: 12),
        _buildResourceBar(
          'SANIDADE',
          widget.character.sanAtual,
          widget.character.sanMax,
          AppColors.sanYellow,
          Icons.psychology,
        ).animate(delay: 300.ms).fadeIn().slideX(begin: -0.2, end: 0),
      ],
    );
  }

  Widget _buildResourceBar(String label, int current, int max, Color color, IconData icon) {
    final percentage = max > 0 ? current / max : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Text(
                '$current / $max',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.deepBlack,
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage.clamp(0.0, 1.0),
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                  ),
                ),
              ).animate().scaleX(
                begin: 0,
                duration: 800.ms,
                curve: Curves.easeOutCubic,
              ),
              Container(
                height: 24,
                alignment: Alignment.center,
                child: Text(
                  '${(percentage * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGray,
                    shadows: [
                      Shadow(
                        color: AppColors.deepBlack,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttributesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ATRIBUTOS',
          style: AppTextStyles.uppercase.copyWith(
            fontSize: 14,
            color: AppColors.lightGray,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            border: Border.all(color: AppColors.silver.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              _buildAttributeBar('FORÇA', widget.character.forca, AppColors.neonRed),
              const SizedBox(height: 12),
              _buildAttributeBar('AGILIDADE', widget.character.agilidade, AppColors.conhecimentoGreen),
              const SizedBox(height: 12),
              _buildAttributeBar('VIGOR', widget.character.vigor, AppColors.energiaYellow),
              const SizedBox(height: 12),
              _buildAttributeBar('INTELECTO', widget.character.intelecto, AppColors.medoPurple),
              const SizedBox(height: 12),
              _buildAttributeBar('PRESENÇA', widget.character.presenca, AppColors.magenta),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildAttributeBar(String label, int value, Color color) {
    final maxValue = 5;
    final percentage = value / maxValue;

    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.deepBlack,
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 20,
                  color: color,
                ),
              ).animate().scaleX(begin: 0, duration: 600.ms),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCombatStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COMBATE',
          style: AppTextStyles.uppercase.copyWith(
            fontSize: 14,
            color: AppColors.lightGray,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'DEFESA',
                widget.character.defesa.toString(),
                AppColors.conhecimentoGreen,
                Icons.shield,
              ).animate(delay: 100.ms).fadeIn().scale(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'BLOQUEIO',
                widget.character.bloqueio.toString(),
                AppColors.medoPurple,
                Icons.block,
              ).animate(delay: 200.ms).fadeIn().scale(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'DESLOC',
                '${widget.character.deslocamento}m',
                AppColors.energiaYellow,
                Icons.directions_run,
              ).animate(delay: 300.ms).fadeIn().scale(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressionSection() {
    // Próximos NEX levels: 5, 10, 20, 35, 40, 50, 65, 70, 80, 95, 99
    final nexLevels = [5, 10, 20, 35, 40, 50, 65, 70, 80, 95, 99];
    final nextNex = nexLevels.firstWhere((n) => n > widget.character.nex, orElse: () => 99);
    final progress = widget.character.nex / nextNex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROGRESSÃO',
          style: AppTextStyles.uppercase.copyWith(
            fontSize: 14,
            color: AppColors.lightGray,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            border: Border.all(color: AppColors.magenta.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NEX ATUAL: ${widget.character.nex}%',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.magenta,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'PRÓXIMO: $nextNex%',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.silver,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Stack(
                children: [
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.deepBlack,
                      border: Border.all(color: AppColors.magenta.withOpacity(0.3)),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 16,
                      color: AppColors.magenta,
                    ),
                  ).animate().scaleX(begin: 0, duration: 1000.ms),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }

  Widget _buildInventoryStatsSection() {
    final itemCount = widget.character.inventarioIds.length;
    final espacoTotal = widget.character.deslocamento * 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INVENTÁRIO',
          style: AppTextStyles.uppercase.copyWith(
            fontSize: 14,
            color: AppColors.lightGray,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'ITENS',
                itemCount.toString(),
                AppColors.conhecimentoGreen,
                Icons.inventory,
              ).animate(delay: 100.ms).fadeIn().scale(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                'CRÉDITOS',
                '\$${widget.character.creditos}',
                AppColors.energiaYellow,
                Icons.attach_money,
              ).animate(delay: 200.ms).fadeIn().scale(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                'ESPAÇO',
                '$espacoTotal slots',
                AppColors.medoPurple,
                Icons.space_dashboard,
              ).animate(delay: 300.ms).fadeIn().scale(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
