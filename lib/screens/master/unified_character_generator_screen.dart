import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/character.dart';
import '../../core/utils/unified_character_generator.dart';
import '../../core/database/character_repository.dart';
import '../../core/database/item_repository.dart';
import '../../core/database/power_repository.dart';
import '../../widgets/generator/tier_list_item.dart';
import '../../widgets/generator/sexo_selector.dart';
import '../../widgets/generator/generate_button.dart';
import '../../widgets/common/minimal_text_field.dart';
import 'package:flutter/services.dart';

/// Tela Unificada de Geração de Personagens
/// Combina Gerador Rápido + Avançado em uma interface
class UnifiedCharacterGeneratorScreen extends StatefulWidget {
  final String userId;

  const UnifiedCharacterGeneratorScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UnifiedCharacterGeneratorScreen> createState() =>
      _UnifiedCharacterGeneratorScreenState();
}

class _UnifiedCharacterGeneratorScreenState
    extends State<UnifiedCharacterGeneratorScreen> {
  final CharacterRepository _repository = CharacterRepository();
  final ItemRepository _itemRepository = ItemRepository();
  final PowerRepository _powerRepository = PowerRepository();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _iniciativaController = TextEditingController();

  // Configurações de geração
  CharacterTier _selectedTier = CharacterTier.soldado;
  Sexo? _selectedSexo; // null = aleatório
  bool _isAdvancedMode = false;
  bool _isGenerating = false;

  // Modo avançado - atributos customizados
  double _forcaSlider = 0;
  double _agilidadeSlider = 0;
  double _vigorSlider = 0;
  double _intelectoSlider = 0;
  double _presencaSlider = 0;

  CharacterClass? _customClasse;
  Origem? _customOrigem;

  @override
  void dispose() {
    _nameController.dispose();
    _iniciativaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepBlack,
        title: Row(
          children: [
            Icon(Icons.flash_on, color: AppColors.neonRed, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'GERADOR DE PERSONAGENS',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.neonRed,
                  fontSize: 16,
                ),
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neonRed),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Toggle Rápido/Avançado
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ChoiceChip(
              label: Text(
                _isAdvancedMode ? 'AVANÇADO' : 'RÁPIDO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _isAdvancedMode ? AppColors.deepBlack : AppColors.neonRed,
                ),
              ),
              selected: _isAdvancedMode,
              onSelected: (selected) {
                setState(() {
                  _isAdvancedMode = selected;
                });
              },
              selectedColor: AppColors.neonRed,
              backgroundColor: Colors.transparent,
              side: BorderSide(color: AppColors.neonRed),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTierSelection(),
            const SizedBox(height: 24),
            _buildBasicOptions(),
            const SizedBox(height: 24),
            if (_isAdvancedMode) ...[
              _buildAdvancedOptions(),
              const SizedBox(height: 24),
            ],
            _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTierSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NÍVEL DE PODER',
          style: AppTextStyles.uppercase.copyWith(
            fontSize: 12,
            color: AppColors.neonRed,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        ...CharacterTier.values.asMap().entries.map((entry) {
          final index = entry.key;
          final tier = entry.value;
          final config = UnifiedCharacterGenerator.tierConfig[tier]!;
          final isSelected = _selectedTier == tier;
          final isLast = index == CharacterTier.values.length - 1;

          return TierListItem(
            title: tier.displayName.toUpperCase(),
            description: tier.description,
            nexPercentage: '${config['nex']}%',
            points: config['pontos'] as int,
            pvRange: '${config['pvMin']}-${config['pvMax']}',
            peRange: '${config['peMin']}-${config['peMax']}',
            isSelected: isSelected,
            onTap: () {
              setState(() {
                _selectedTier = tier;
              });
            },
            showDivider: !isLast,
          );
        }),
      ],
    );
  }

  Widget _buildBasicOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OPÇÕES BÁSICAS',
          style: AppTextStyles.uppercase.copyWith(
            fontSize: 12,
            color: AppColors.neonRed,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),

        // Seletor de Sexo
        SexoSelector(
          selectedSexo: _selectedSexo,
          onChanged: (sexo) {
            setState(() {
              _selectedSexo = sexo;
            });
          },
        ),
        const SizedBox(height: 24),

        // Campo Nome
        MinimalTextField(
          label: 'NOME (OPCIONAL)',
          hintText: 'Deixe vazio para gerar automaticamente',
          controller: _nameController,
        ),
        const SizedBox(height: 24),

        // Campo Iniciativa
        MinimalTextField(
          label: 'INICIATIVA BASE (OPCIONAL)',
          hintText: '0',
          controller: _iniciativaController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 3,
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OPÇÕES AVANÇADAS',
          style: AppTextStyles.uppercase.copyWith(
            fontSize: 12,
            color: AppColors.neonRed,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),

        // Atributos manuais
        Text(
          'ATRIBUTOS PERSONALIZADOS',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.silver.withValues(alpha: 0.7),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        _buildAttributeSlider('Força', _forcaSlider, (value) {
          setState(() => _forcaSlider = value);
        }),
        _buildAttributeSlider('Agilidade', _agilidadeSlider, (value) {
          setState(() => _agilidadeSlider = value);
        }),
        _buildAttributeSlider('Vigor', _vigorSlider, (value) {
          setState(() => _vigorSlider = value);
        }),
        _buildAttributeSlider('Intelecto', _intelectoSlider, (value) {
          setState(() => _intelectoSlider = value);
        }),
        _buildAttributeSlider('Presença', _presencaSlider, (value) {
          setState(() => _presencaSlider = value);
        }),
      ],
    );
  }

  Widget _buildAttributeSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.lightGray,
              ),
            ),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: 0,
              max: 6,
              divisions: 6,
              activeColor: AppColors.neonRed,
              inactiveColor: AppColors.silver.withValues(alpha: 0.3),
              onChanged: onChanged,
            ),
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              value.toInt().toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.neonRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return GenerateButton(
      onPressed: _handleGenerate,
      isLoading: _isGenerating,
    );
  }

  Future<void> _handleGenerate() async {
    setState(() => _isGenerating = true);

    try {
      final iniciativa = int.tryParse(_iniciativaController.text);

      // Gera personagem com itens e poderes
      final result = UnifiedCharacterGenerator.generate(
        userId: widget.userId,
        tier: _selectedTier,
        customName: _nameController.text.isEmpty ? null : _nameController.text,
        sexo: _selectedSexo,
        customIniciativa: iniciativa,
        // Modo avançado: atributos customizados
        forcaCustom: _isAdvancedMode ? _forcaSlider.toInt() : null,
        agilidadeCustom: _isAdvancedMode ? _agilidadeSlider.toInt() : null,
        vigorCustom: _isAdvancedMode ? _vigorSlider.toInt() : null,
        intelectoCustom: _isAdvancedMode ? _intelectoSlider.toInt() : null,
        presencaCustom: _isAdvancedMode ? _presencaSlider.toInt() : null,
        classeCustom: _customClasse,
        origemCustom: _customOrigem,
        // Auto-gera itens e poderes
        generateItems: true,
        generatePowers: true,
      );

      // Salva personagem no banco
      await _repository.create(result.character);

      // Salva itens gerados
      for (final item in result.items) {
        await _itemRepository.create(item);
      }

      // Salva poderes gerados
      for (final power in result.powers) {
        await _powerRepository.create(power);
      }

      if (mounted) {
        setState(() => _isGenerating = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${result.character.nome} criado com sucesso!\n'
              '${result.itemCount} itens e ${result.powerCount} poderes gerados.',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.conhecimentoGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );

        // Limpa campos
        _nameController.clear();
        _iniciativaController.clear();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar personagem: $e'),
            backgroundColor: AppColors.neonRed,
          ),
        );
      }
    }
  }

}
