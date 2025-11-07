import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/character.dart';
import '../models/skill.dart';
import '../services/local_database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

/// Wizard de criação de personagem com tema Hexatombe
class CharacterWizardScreen extends StatefulWidget {
  final Character? character;
  final String userId;

  const CharacterWizardScreen({
    super.key,
    this.character,
    required this.userId,
  });

  @override
  State<CharacterWizardScreen> createState() => _CharacterWizardScreenState();
}

class _CharacterWizardScreenState extends State<CharacterWizardScreen> {
  final _dbService = LocalDatabaseService();
  final _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 6;

  // Dados do personagem
  late TextEditingController _nomeController;
  late TextEditingController _patenteController;
  int _nex = 0;
  String _origem = '';
  String _classe = '';
  String _trilha = '';
  int _forca = 10;
  int _agilidade = 10;
  int _vigor = 10;
  int _inteligencia = 10;
  int _presenca = 10;
  int _pvMax = 0;
  int _peMax = 0;
  int _psMax = 0;
  Map<String, Skill> _pericias = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final char = widget.character;
    _nomeController = TextEditingController(text: char?.nome ?? '');
    _patenteController = TextEditingController(text: char?.patente ?? '');
    _nex = char?.nex ?? 0;
    _origem = char?.origem ?? '';
    _classe = char?.classe ?? '';
    _trilha = char?.trilha ?? '';
    _forca = char?.forca ?? 10;
    _agilidade = char?.agilidade ?? 10;
    _vigor = char?.vigor ?? 10;
    _inteligencia = char?.inteligencia ?? 10;
    _presenca = char?.presenca ?? 10;
    _pvMax = char?.pvMax ?? 0;
    _peMax = char?.peMax ?? 0;
    _psMax = char?.psMax ?? 0;
    _pericias = Map.from(char?.pericias ?? {});
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _patenteController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return HexatombeBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppTheme.abyssalBlack.withOpacity(0.9),
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.character == null ? 'NOVO AGENTE' : 'EDITAR AGENTE',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                  color: AppTheme.ritualRed,
                ),
              ),
              Text(
                'Passo ${_currentStep + 1} de $_totalSteps',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.coldGray,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),

            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1BasicInfo(),
                  _buildStep2OriginClass(),
                  _buildStep3Attributes(),
                  _buildStep4Stats(),
                  _buildStep5Skills(),
                  _buildStep6Review(),
                ],
              ),
            ),

            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 8 : 0),
              decoration: BoxDecoration(
                color: isCompleted || isActive
                    ? AppTheme.ritualRed
                    : AppTheme.coldGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms),
          );
        }),
      ),
    );
  }

  Widget _buildStep1BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          RitualCard(
            glowEffect: true,
            glowColor: AppTheme.ritualRed,
            ritualCorners: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INFORMAÇÕES BÁSICAS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'BebasNeue',
                    color: AppTheme.ritualRed,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Identifique seu agente',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.coldGray,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextInput('Nome do Agente', _nomeController, required: true),
                const SizedBox(height: 16),
                _buildTextInput('Patente', _patenteController),
                const SizedBox(height: 16),
                _buildNumberSlider('NEX (Nível de Exposição)', _nex, 0, 100, (val) {
                  setState(() => _nex = val);
                }),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildStep2OriginClass() {
    final List<String> origens = ['Acadêmico', 'Agente de Saúde', 'Artista', 'Atleta', 'Criminoso', 'Cultista Arrependido', 'Desgarrado', 'Engenheiro', 'Executivo', 'Investigador', 'Lutador', 'Magnata', 'Mercenário', 'Militar', 'Operário', 'Policial', 'Religioso', 'Servidor Público', 'Teórico da Conspiração', 'TI', 'Trambiqueiro', 'Universitário', 'Vítima'];
    final List<String> classes = ['Combatente', 'Especialista', 'Ocultista'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          RitualCard(
            glowEffect: true,
            glowColor: AppTheme.chaoticMagenta,
            ritualCorners: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ORIGEM & CLASSE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'BebasNeue',
                    color: AppTheme.chaoticMagenta,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'ORIGEM',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.coldGray,
                    fontFamily: 'Montserrat',
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDropdown('Selecione a origem', origens, _origem, (val) {
                  setState(() => _origem = val ?? '');
                }),
                const SizedBox(height: 24),
                const Text(
                  'CLASSE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.coldGray,
                    fontFamily: 'Montserrat',
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDropdown('Selecione a classe', classes, _classe, (val) {
                  setState(() => _classe = val ?? '');
                }),
                const SizedBox(height: 24),
                _buildTextInput('Trilha (Opcional)', TextEditingController(text: _trilha),
                  onChanged: (val) => _trilha = val),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildStep3Attributes() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          RitualCard(
            glowEffect: true,
            glowColor: AppTheme.etherealPurple,
            ritualCorners: true,
            child: Column(
              children: [
                const Text(
                  'ATRIBUTOS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'BebasNeue',
                    color: AppTheme.etherealPurple,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Distribua os pontos entre os atributos',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.coldGray,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 24),
                _buildAttributeSlider('FOR', 'Força', _forca, AppTheme.ritualRed, (val) {
                  setState(() => _forca = val);
                }),
                const SizedBox(height: 16),
                _buildAttributeSlider('AGI', 'Agilidade', _agilidade, AppTheme.mutagenGreen, (val) {
                  setState(() => _agilidade = val);
                }),
                const SizedBox(height: 16),
                _buildAttributeSlider('VIG', 'Vigor', _vigor, AppTheme.etherealPurple, (val) {
                  setState(() => _vigor = val);
                }),
                const SizedBox(height: 16),
                _buildAttributeSlider('INT', 'Inteligência', _inteligencia, AppTheme.chaoticMagenta, (val) {
                  setState(() => _inteligencia = val);
                }),
                const SizedBox(height: 16),
                _buildAttributeSlider('PRE', 'Presença', _presenca, AppTheme.alertYellow, (val) {
                  setState(() => _presenca = val);
                }),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildStep4Stats() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          RitualCard(
            glowEffect: true,
            glowColor: AppTheme.mutagenGreen,
            ritualCorners: true,
            child: Column(
              children: [
                const Text(
                  'PONTOS DE VIDA & ENERGIA',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'BebasNeue',
                    color: AppTheme.mutagenGreen,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),
                _buildNumberSlider('PV Máximo', _pvMax, 0, 200, (val) {
                  setState(() => _pvMax = val);
                }),
                const SizedBox(height: 16),
                _buildNumberSlider('PE Máximo', _peMax, 0, 100, (val) {
                  setState(() => _peMax = val);
                }),
                const SizedBox(height: 16),
                _buildNumberSlider('PS Máximo', _psMax, 0, 50, (val) {
                  setState(() => _psMax = val);
                }),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildStep5Skills() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          RitualCard(
            glowEffect: true,
            glowColor: AppTheme.alertYellow,
            ritualCorners: true,
            padding: const EdgeInsets.all(20),
            child: const Column(
              children: [
                Icon(Icons.school, color: AppTheme.alertYellow, size: 48),
                SizedBox(height: 16),
                Text(
                  'PERÍCIAS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'BebasNeue',
                    color: AppTheme.alertYellow,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Você poderá configurar as perícias após criar o personagem',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.coldGray,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
        ],
      ),
    );
  }

  Widget _buildStep6Review() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          RitualCard(
            glowEffect: true,
            glowColor: AppTheme.ritualRed,
            pulsate: true,
            ritualCorners: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'REVISÃO FINAL',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'BebasNeue',
                      color: AppTheme.ritualRed,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildReviewRow('Nome', _nomeController.text),
                _buildReviewRow('Patente', _patenteController.text),
                _buildReviewRow('NEX', '$_nex%'),
                _buildReviewRow('Origem', _origem),
                _buildReviewRow('Classe', _classe),
                if (_trilha.isNotEmpty) _buildReviewRow('Trilha', _trilha),
                const Divider(color: AppTheme.coldGray, height: 32),
                _buildReviewRow('FOR', '$_forca (${_getModifier(_forca)})'),
                _buildReviewRow('AGI', '$_agilidade (${_getModifier(_agilidade)})'),
                _buildReviewRow('VIG', '$_vigor (${_getModifier(_vigor)})'),
                _buildReviewRow('INT', '$_inteligencia (${_getModifier(_inteligencia)})'),
                _buildReviewRow('PRE', '$_presenca (${_getModifier(_presenca)})'),
                const Divider(color: AppTheme.coldGray, height: 32),
                _buildReviewRow('PV Máximo', '$_pvMax'),
                _buildReviewRow('PE Máximo', '$_peMax'),
                _buildReviewRow('PS Máximo', '$_psMax'),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.coldGray,
              fontFamily: 'Montserrat',
              letterSpacing: 1,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.paleWhite,
              fontFamily: 'SpaceMono',
            ),
          ),
        ],
      ),
    );
  }

  String _getModifier(int value) {
    final mod = ((value - 10) / 2).floor();
    return mod >= 0 ? '+$mod' : '$mod';
  }

  Widget _buildTextInput(String label, TextEditingController controller,
      {bool required = false, Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.coldGray,
            fontFamily: 'Montserrat',
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(color: AppTheme.paleWhite, fontFamily: 'Montserrat'),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.obscureGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.coldGray, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.coldGray, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.ritualRed, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String hint, List<String> items, String value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      hint: Text(hint, style: const TextStyle(color: AppTheme.coldGray)),
      dropdownColor: AppTheme.obscureGray,
      style: const TextStyle(color: AppTheme.paleWhite, fontFamily: 'Montserrat'),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.obscureGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.coldGray, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.coldGray, width: 1.5),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildNumberSlider(String label, int value, int min, int max, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.coldGray,
                fontFamily: 'Montserrat',
                letterSpacing: 1,
              ),
            ),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.paleWhite,
                fontFamily: 'BebasNeue',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppTheme.ritualRed,
            inactiveTrackColor: AppTheme.coldGray.withOpacity(0.3),
            thumbColor: AppTheme.ritualRed,
            overlayColor: AppTheme.ritualRed.withOpacity(0.3),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: (val) => onChanged(val.round()),
          ),
        ),
      ],
    );
  }

  Widget _buildAttributeSlider(String code, String name, int value, Color color, Function(int) onChanged) {
    final modifier = _getModifier(value);
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontFamily: 'Montserrat',
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    modifier,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontFamily: 'SpaceMono',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.coldGray,
                      fontFamily: 'Montserrat',
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: color,
                      inactiveTrackColor: AppTheme.coldGray.withOpacity(0.3),
                      thumbColor: color,
                      overlayColor: color.withOpacity(0.3),
                    ),
                    child: Slider(
                      value: value.toDouble(),
                      min: 0,
                      max: 20,
                      divisions: 20,
                      label: '$value',
                      onChanged: (val) => onChanged(val.round()),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'BebasNeue',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.abyssalBlack.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: AppTheme.abyssalBlack.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: GlowingButton(
                label: 'Voltar',
                icon: Icons.arrow_back,
                onPressed: _previousStep,
                style: GlowingButtonStyle.secondary,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: GlowingButton(
              label: _currentStep == _totalSteps - 1 ? 'Salvar' : 'Próximo',
              icon: _currentStep == _totalSteps - 1 ? Icons.save : Icons.arrow_forward,
              onPressed: _currentStep == _totalSteps - 1 ? _saveCharacter : _nextStep,
              isLoading: _isLoading,
              pulsateGlow: _currentStep == _totalSteps - 1,
              style: GlowingButtonStyle.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCharacter() async {
    if (_nomeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha o nome do personagem'),
          backgroundColor: AppTheme.ritualRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final character = Character(
        id: widget.character?.id ?? '',
        nome: _nomeController.text,
        patente: _patenteController.text,
        nex: _nex,
        origem: _origem,
        classe: _classe,
        trilha: _trilha,
        createdBy: widget.userId,
        pvAtual: widget.character?.pvAtual ?? _pvMax,
        pvMax: _pvMax,
        peAtual: widget.character?.peAtual ?? _peMax,
        peMax: _peMax,
        psAtual: widget.character?.psAtual ?? _psMax,
        psMax: _psMax,
        creditos: widget.character?.creditos ?? 0,
        forca: _forca,
        agilidade: _agilidade,
        vigor: _vigor,
        inteligencia: _inteligencia,
        presenca: _presenca,
        iniciativaBase: widget.character?.iniciativaBase ?? 0,
        pericias: _pericias,
        poderes: widget.character?.poderes ?? [],
        inventario: widget.character?.inventario ?? [],
      );

      if (widget.character == null) {
        await _dbService.createCharacter(character);
      } else {
        await _dbService.updateCharacter(character);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.character == null ? 'Agente criado com sucesso!' : 'Agente atualizado!',
            ),
            backgroundColor: AppTheme.mutagenGreen,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: AppTheme.ritualRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
