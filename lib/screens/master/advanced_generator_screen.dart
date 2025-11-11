import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/database/character_repository.dart';
import '../../core/utils/advanced_character_generator.dart';

/// Tela de Gerador Avançado (só Mestre)
/// Gera NPCs randomicos por tier (10 categorias)
class AdvancedGeneratorScreen extends StatefulWidget {
  final String userId;

  const AdvancedGeneratorScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AdvancedGeneratorScreen> createState() =>
      _AdvancedGeneratorScreenState();
}

class _AdvancedGeneratorScreenState extends State<AdvancedGeneratorScreen> {
  final CharacterRepository _characterRepo = CharacterRepository();
  CharacterTier _selectedTier = CharacterTier.soldado;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        title: const Text('GERADOR AVANÇADO DE NPCs'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.magenta.withOpacity(0.1),
                border: Border.all(color: AppColors.magenta),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.magenta, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'GERADOR SUPREMO',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.magenta),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gera NPCs balanceados seguindo o PROMPT SUPREMO:\n'
                    '• Atributos limitados por tier\n'
                    '• Stats balanceados (PV/PE/SAN)\n'
                    '• 10 categorias: Civil → Deus',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.silver),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Seletor de Tier
            Text('SELECIONE O NÍVEL', style: AppTextStyles.title),
            const SizedBox(height: 16),

            ...CharacterTier.values.map((tier) => _buildTierOption(tier)),

            const SizedBox(height: 32),

            // Botão Gerar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateCharacter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.scarletRed,
                ),
                child: _isGenerating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.lightGray,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('GERAR NPC ALEATÓRIO'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierOption(CharacterTier tier) {
    final isSelected = tier == _selectedTier;
    final config = AdvancedCharacterGenerator.tierConfig[tier]!;
    final colorHex = AdvancedCharacterGenerator.getTierColor(tier);
    final color = Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);

    return GestureDetector(
      onTap: () => setState(() => _selectedTier = tier),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppColors.darkGray,
          border: Border.all(
            color: isSelected ? color : AppColors.silver.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Indicador
            Container(
              width: 4,
              height: 40,
              color: color,
            ),

            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AdvancedCharacterGenerator.getTierName(tier),
                    style: AppTextStyles.uppercase.copyWith(color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AdvancedCharacterGenerator.getTierDescription(tier),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.silver,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatBadge(
                          'ATR', '${config['pontos']}', AppColors.forRed),
                      const SizedBox(width: 8),
                      _buildStatBadge('PV',
                          '${config['pvMin']}-${config['pvMax']}', AppColors.pvRed),
                      const SizedBox(width: 8),
                      _buildStatBadge('PE',
                          '${config['peMin']}-${config['peMax']}', AppColors.pePurple),
                    ],
                  ),
                ],
              ),
            ),

            // Radio
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.scarletRed, size: 24)
            else
              Icon(Icons.circle_outlined,
                  color: AppColors.silver.withOpacity(0.5), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Future<void> _generateCharacter() async {
    setState(() => _isGenerating = true);

    try {
      // Gera personagem
      final character = AdvancedCharacterGenerator.generateRandom(
        userId: widget.userId,
        tier: _selectedTier,
      );

      // Salva no banco
      await _characterRepo.create(character);

      if (mounted) {
        setState(() => _isGenerating = false);

        // Mostra dialog de sucesso
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.darkGray,
            title: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: AppColors.conhecimentoGreen, size: 32),
                const SizedBox(width: 12),
                const Text('NPC CRIADO'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nome: ${character.nome}',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 8),
                Text(
                  'Classe: ${character.classe.name.toUpperCase()}',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 8),
                Text(
                  'NEX: ${character.nex}%',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 8),
                Text(
                  'PV: ${character.pvMax} | PE: ${character.peMax} | SAN: ${character.sanMax}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.silver),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CONTINUAR GERANDO'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Fecha dialog
                  Navigator.pop(context, true); // Volta e recarrega lista
                },
                child: const Text('VER LISTA'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar: $e')),
        );
      }
    }
  }
}
