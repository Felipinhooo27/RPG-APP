import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/database/character_repository.dart';
import '../../core/utils/character_generator.dart';
import '../../models/character.dart';

/// Wizard de criação de personagem em 6 etapas
/// Design inline sem caixas, seguindo regras de Ordem Paranormal
class CharacterWizardScreen extends StatefulWidget {
  final String userId;
  final Character? characterToEdit;

  const CharacterWizardScreen({
    super.key,
    required this.userId,
    this.characterToEdit,
  });

  @override
  State<CharacterWizardScreen> createState() => _CharacterWizardScreenState();
}

class _CharacterWizardScreenState extends State<CharacterWizardScreen> {
  final PageController _pageController = PageController();
  final CharacterRepository _characterRepo = CharacterRepository();

  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: Info Básica
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _patenteController = TextEditingController();

  // Step 2: Origem & Classe
  Origem? _selectedOrigemValue;
  CharacterClass? _selectedClasse;
  String? _selectedTrilha;

  // Step 3: Atributos
  int _forca = 0;
  int _agilidade = 0;
  int _vigor = 0;
  int _intelecto = 0;
  int _presenca = 0;

  @override
  void initState() {
    super.initState();
    if (widget.characterToEdit != null) {
      _loadExistingCharacter();
    }
  }

  void _loadExistingCharacter() {
    final char = widget.characterToEdit!;
    _nomeController.text = char.nome;
    _patenteController.text = char.patente ?? '';
    _selectedOrigemValue = char.origem;
    _selectedClasse = char.classe;
    _selectedTrilha = char.trilha;
    _forca = char.forca;
    _agilidade = char.agilidade;
    _vigor = char.vigor;
    _intelecto = char.intelecto;
    _presenca = char.presenca;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nomeController.dispose();
    _patenteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        title: Text(widget.characterToEdit == null ? 'NOVO PERSONAGEM' : 'EDITAR PERSONAGEM'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: [
              // Barra de progresso
              _buildProgressBar(),
              const SizedBox(height: 8),
              // Contador
              Text(
                'PASSO ${_currentStep + 1} DE 6',
                style: AppTextStyles.label.copyWith(color: AppColors.silver),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Conteúdo das etapas
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildStep1InfoBasica(),
                _buildStep2OrigemClasse(),
                _buildStep3Atributos(),
                _buildStep4Stats(),
                _buildStep5Pericias(),
                _buildStep6Review(),
              ],
            ),
          ),

          // Botões de navegação
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(6, (index) {
        final isCompleted = index < _currentStep;
        final isCurrent = index == _currentStep;
        final color = isCompleted || isCurrent ? AppColors.scarletRed : AppColors.silver.withOpacity(0.3);

        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            color: color,
          ),
        );
      }),
    );
  }

  // ==================== STEP 1: INFO BÁSICA ====================

  Widget _buildStep1InfoBasica() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('INFORMAÇÕES BÁSICAS', style: AppTextStyles.title),
          const SizedBox(height: 24),

          // Nome
          Text('NOME DO PERSONAGEM', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            controller: _nomeController,
            style: AppTextStyles.body,
            decoration: const InputDecoration(
              hintText: 'Ex: Enzo Rodrigues',
            ),
            textCapitalization: TextCapitalization.words,
          ),

          const SizedBox(height: 24),

          // Patente (opcional)
          Text('PATENTE (OPCIONAL)', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            controller: _patenteController,
            style: AppTextStyles.body,
            decoration: const InputDecoration(
              hintText: 'Ex: Líder, Recruta, Operador',
            ),
            textCapitalization: TextCapitalization.words,
          ),

          const SizedBox(height: 24),

          // Botão nome aleatório
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _nomeController.text = CharacterGenerator.generateRandomName();
                });
              },
              icon: const Icon(Icons.shuffle),
              label: const Text('NOME ALEATÓRIO'),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STEP 2: ORIGEM & CLASSE ====================

  Widget _buildStep2OrigemClasse() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ORIGEM & CLASSE', style: AppTextStyles.title),
          const SizedBox(height: 24),

          // Origem
          Text('ORIGEM', style: AppTextStyles.label),
          const SizedBox(height: 8),
          _buildOrigemDropdown(),

          if (_selectedOrigemValue != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.silver.withOpacity(0.3)),
              ),
              child: Text(
                CharacterGenerator.getOrigemDescription(_selectedOrigemValue!),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.silver),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Classe
          Text('CLASSE', style: AppTextStyles.label),
          const SizedBox(height: 8),
          _buildClasseDropdown(),

          if (_selectedClasse != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.silver.withOpacity(0.3)),
              ),
              child: Text(
                CharacterGenerator.getClasseDescription(_selectedClasse!),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.silver),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Trilha (opcional por enquanto)
          Text('TRILHA (OPCIONAL)', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) => setState(() => _selectedTrilha = value.isEmpty ? null : value),
            style: AppTextStyles.body,
            decoration: const InputDecoration(
              hintText: 'Ex: Operações Especiais, Medicina',
            ),
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
    );
  }

  Widget _buildOrigemDropdown() {
    return DropdownButtonFormField<Origem>(
      value: _selectedOrigemValue,
      style: AppTextStyles.body,
      dropdownColor: AppColors.darkGray,
      decoration: const InputDecoration(
        hintText: 'Selecione uma origem',
      ),
      items: Origem.values.map((origem) {
        return DropdownMenuItem(
          value: origem,
          child: Text(origem.name.toUpperCase()),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedOrigemValue = value),
    );
  }

  Widget _buildClasseDropdown() {
    return DropdownButtonFormField<CharacterClass>(
      value: _selectedClasse,
      style: AppTextStyles.body,
      dropdownColor: AppColors.darkGray,
      decoration: const InputDecoration(
        hintText: 'Selecione uma classe',
      ),
      items: CharacterClass.values.map((classe) {
        return DropdownMenuItem(
          value: classe,
          child: Text(classe.name.toUpperCase()),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedClasse = value),
    );
  }

  // ==================== STEP 3: ATRIBUTOS ====================

  Widget _buildStep3Atributos() {
    final pontosUsados = CharacterGenerator.calculateUsedPoints({
      'forca': _forca,
      'agilidade': _agilidade,
      'vigor': _vigor,
      'intelecto': _intelecto,
      'presenca': _presenca,
    });

    final pontosDisponiveis = CharacterGenerator.calculateAvailablePoints({
      'forca': _forca,
      'agilidade': _agilidade,
      'vigor': _vigor,
      'intelecto': _intelecto,
      'presenca': _presenca,
    });

    final isValid = CharacterGenerator.isValidAttributeDistribution(
      _forca,
      _agilidade,
      _vigor,
      _intelecto,
      _presenca,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DISTRIBUIR ATRIBUTOS', style: AppTextStyles.title),
          const SizedBox(height: 8),

          // Info pontos
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isValid ? AppColors.conhecimentoGreen.withOpacity(0.1) : AppColors.neonRed.withOpacity(0.1),
              border: Border.all(
                color: isValid ? AppColors.conhecimentoGreen : AppColors.neonRed,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PONTOS: $pontosUsados / $pontosDisponiveis',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isValid ? AppColors.conhecimentoGreen : AppColors.neonRed,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Máximo +3 inicial. Reduza 1 para -1 e ganhe +1 ponto extra.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.silver),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sliders
          _buildAttributeSlider('FORÇA', _forca, (v) => setState(() => _forca = v), AppColors.forRed),
          const SizedBox(height: 16),
          _buildAttributeSlider('AGILIDADE', _agilidade, (v) => setState(() => _agilidade = v), AppColors.agiGreen),
          const SizedBox(height: 16),
          _buildAttributeSlider('VIGOR', _vigor, (v) => setState(() => _vigor = v), AppColors.vigBlue),
          const SizedBox(height: 16),
          _buildAttributeSlider('INTELECTO', _intelecto, (v) => setState(() => _intelecto = v), AppColors.intMagenta),
          const SizedBox(height: 16),
          _buildAttributeSlider('PRESENÇA', _presenca, (v) => setState(() => _presenca = v), AppColors.preGold),

          const SizedBox(height: 24),

          // Distribuições sugeridas
          Text('DISTRIBUIÇÕES SUGERIDAS', style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CharacterGenerator.getSuggestedDistributions().map((dist) {
              return OutlinedButton(
                onPressed: () => _applySuggestedDistribution(dist),
                child: Text(
                  'FOR${dist['forca']} AGI${dist['agilidade']} VIG${dist['vigor']} INT${dist['intelecto']} PRE${dist['presenca']}',
                  style: const TextStyle(fontSize: 10),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeSlider(String label, int value, ValueChanged<int> onChanged, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.label),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                border: Border.all(color: color),
              ),
              child: Text(
                value >= 0 ? '+$value' : '$value',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.3),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
          ),
          child: Slider(
            value: value.toDouble(),
            min: -1,
            max: 3,
            divisions: 4,
            onChanged: (val) => onChanged(val.toInt()),
          ),
        ),
        Container(height: 1, color: AppColors.silver.withOpacity(0.2)),
      ],
    );
  }

  void _applySuggestedDistribution(Map<String, int> dist) {
    setState(() {
      _forca = dist['forca']!;
      _agilidade = dist['agilidade']!;
      _vigor = dist['vigor']!;
      _intelecto = dist['intelecto']!;
      _presenca = dist['presenca']!;
    });
  }

  // ==================== STEP 4: STATS ====================

  Widget _buildStep4Stats() {
    if (_selectedClasse == null) {
      return const Center(child: Text('Selecione uma classe primeiro'));
    }

    final stats = CharacterGenerator.calculateStats(
      classe: _selectedClasse!,
      vigor: _vigor,
      presenca: _presenca,
      agilidade: _agilidade,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ESTATÍSTICAS CALCULADAS', style: AppTextStyles.title),
          const SizedBox(height: 24),

          _buildStatRow('PV (PONTOS DE VIDA)', stats['pvMax']!, AppColors.pvRed, 'Base ${CharacterGenerator.pvBase[_selectedClasse]} + Vigor $_vigor'),
          const SizedBox(height: 16),

          _buildStatRow('PE (PONTOS DE ESFORÇO)', stats['peMax']!, AppColors.pePurple, 'Base ${CharacterGenerator.peBase[_selectedClasse]} + Presença $_presenca'),
          const SizedBox(height: 16),

          _buildStatRow('SAN (SANIDADE)', stats['sanMax']!, AppColors.sanYellow, 'Base ${CharacterGenerator.sanBase[_selectedClasse]}'),
          const SizedBox(height: 16),

          _buildStatRow('DEFESA', stats['defesa']!, AppColors.silver, '10 + Agilidade $_agilidade'),
          const SizedBox(height: 16),

          _buildStatRow('BLOQUEIO', 10, AppColors.silver, 'Padrão'),
          const SizedBox(height: 16),

          _buildStatRow('DESLOCAMENTO', 9, AppColors.silver, '9 metros (padrão)'),

          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.conhecimentoGreen.withOpacity(0.1),
              border: Border.all(color: AppColors.conhecimentoGreen),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RESUMO',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.conhecimentoGreen),
                ),
                const SizedBox(height: 8),
                Text(
                  'Seu personagem está pronto para começar sua jornada no Outro Lado.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.silver),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value, Color color, String formula) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.labelMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                border: Border.all(color: color, width: 2),
              ),
              child: Text(
                '$value',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          formula,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.silver),
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: AppColors.silver.withOpacity(0.2)),
      ],
    );
  }

  // ==================== STEP 5: PERÍCIAS ====================

  Widget _buildStep5Pericias() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 64, color: AppColors.silver.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text('PERÍCIAS', style: AppTextStyles.title),
            const SizedBox(height: 16),
            Text(
              'Sistema de perícias será implementado\nna próxima versão',
              style: AppTextStyles.body.copyWith(color: AppColors.silver),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Por enquanto, pule para a revisão final',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.silver.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== STEP 6: REVIEW ====================

  Widget _buildStep6Review() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('REVISÃO FINAL', style: AppTextStyles.title),
          const SizedBox(height: 24),

          _buildReviewSection('INFORMAÇÕES BÁSICAS', [
            'Nome: ${_nomeController.text}',
            if (_patenteController.text.isNotEmpty) 'Patente: ${_patenteController.text}',
          ]),

          const SizedBox(height: 16),

          _buildReviewSection('ORIGEM & CLASSE', [
            'Origem: ${_selectedOrigemValue?.name.toUpperCase() ?? '-'}',
            'Classe: ${_selectedClasse?.name.toUpperCase() ?? '-'}',
            if (_selectedTrilha != null) 'Trilha: $_selectedTrilha',
          ]),

          const SizedBox(height: 16),

          _buildReviewSection('ATRIBUTOS', [
            'Força: ${_forca >= 0 ? '+$_forca' : _forca}',
            'Agilidade: ${_agilidade >= 0 ? '+$_agilidade' : _agilidade}',
            'Vigor: ${_vigor >= 0 ? '+$_vigor' : _vigor}',
            'Intelecto: ${_intelecto >= 0 ? '+$_intelecto' : _intelecto}',
            'Presença: ${_presenca >= 0 ? '+$_presenca' : _presenca}',
          ]),

          const SizedBox(height: 32),

          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.scarletRed))
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canFinish() ? _finishWizard : null,
                child: Text(
                  _isLoading
                    ? 'SALVANDO...'
                    : (widget.characterToEdit != null ? 'SALVAR ALTERAÇÕES' : 'CRIAR PERSONAGEM')
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.silver.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelMedium.copyWith(color: AppColors.scarletRed)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(item, style: AppTextStyles.body),
              )),
        ],
      ),
    );
  }

  // ==================== NAVEGAÇÃO ====================

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border(
          top: BorderSide(color: AppColors.silver.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('ANTERIOR'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          if (_currentStep < 5)
            Expanded(
              child: ElevatedButton(
                onPressed: _canProceed() ? _nextStep : null,
                child: const Text('PRÓXIMO'),
              ),
            ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0: // Info básica
        return _nomeController.text.trim().isNotEmpty;
      case 1: // Origem & Classe
        return _selectedOrigemValue != null && _selectedClasse != null;
      case 2: // Atributos
        return CharacterGenerator.isValidAttributeDistribution(
          _forca,
          _agilidade,
          _vigor,
          _intelecto,
          _presenca,
        );
      case 3: // Stats
        return true;
      case 4: // Perícias
        return true;
      default:
        return false;
    }
  }

  bool _canFinish() {
    return _nomeController.text.trim().isNotEmpty &&
        _selectedOrigemValue != null &&
        _selectedClasse != null &&
        CharacterGenerator.isValidAttributeDistribution(
          _forca,
          _agilidade,
          _vigor,
          _intelecto,
          _presenca,
        );
  }

  Future<void> _finishWizard() async {
    if (!_canFinish() || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final character = CharacterGenerator.generate(
        userId: widget.userId,
        nome: _nomeController.text.trim(),
        classe: _selectedClasse!,
        origem: _selectedOrigemValue!,
        trilha: _selectedTrilha,
        patente: _patenteController.text.trim().isEmpty ? null : _patenteController.text.trim(),
        forca: _forca,
        agilidade: _agilidade,
        vigor: _vigor,
        intelecto: _intelecto,
        presenca: _presenca,
      );

      if (widget.characterToEdit == null) {
        await _characterRepo.create(character);
      } else {
        await _characterRepo.update(character.copyWith(id: widget.characterToEdit!.id));
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Retorna true para indicar sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.characterToEdit != null
                ? '${character.nome} atualizado com sucesso!'
                : '${character.nome} criado com sucesso!'
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar personagem: $e')),
        );
      }
    }
  }
}
