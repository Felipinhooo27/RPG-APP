import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/character.dart';
import '../models/skill.dart';
import '../services/local_database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'dart:async';

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
  int _forca = 0;
  int _agilidade = 0;
  int _vigor = 0;
  int _inteligencia = 0;
  int _presenca = 0;
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
    _forca = char?.forca ?? 0;
    _agilidade = char?.agilidade ?? 0;
    _vigor = char?.vigor ?? 0;
    _inteligencia = char?.inteligencia ?? 0;
    _presenca = char?.presenca ?? 0;
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
        body: Stack(
          children: [
            Column(
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
            // Loading overlay
            if (_isLoading)
              Container(
                color: AppTheme.abyssalBlack.withOpacity(0.8),
                child: const Center(
                  child: HexLoading.large(
                    color: AppTheme.ritualRed,
                    message: 'Salvando Agente...',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(_totalSteps, (index) {
              final isActive = index == _currentStep;
              final isCompleted = index < _currentStep;

              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? AppTheme.ritualRed
                        : AppTheme.coldGray.withOpacity(0.2),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppTheme.ritualRed.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms),
              );
            }),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Progresso: ${(_currentStep + 1)} de $_totalSteps',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.coldGray,
                fontFamily: 'Montserrat',
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
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
    // Calculate points used and available
    int pointsUsed = _forca + _agilidade + _vigor + _inteligencia + _presenca;
    int basePoints = 4;

    // Count attributes at -1 (each gives +1 extra point)
    int negativeCount = 0;
    if (_forca == -1) negativeCount++;
    if (_agilidade == -1) negativeCount++;
    if (_vigor == -1) negativeCount++;
    if (_inteligencia == -1) negativeCount++;
    if (_presenca == -1) negativeCount++;

    int totalAvailable = basePoints + negativeCount;
    int pointsRemaining = totalAvailable - pointsUsed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Point Pool Display
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkGray,
              border: Border.all(
                color: pointsRemaining == 0 ? AppTheme.scarletRed : AppTheme.steel,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'PONTOS DISPONÍVEIS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: AppTheme.lightGray,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$pointsRemaining',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'BebasNeue',
                    color: pointsRemaining == 0 ? AppTheme.scarletRed : AppTheme.pureWhite,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Base: $basePoints + Bônus: $negativeCount = Total: $totalAvailable',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.iron,
                    fontFamily: 'SpaceMono',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Limite: -1 a +3 • Cada -1 dá +1 ponto extra',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.iron,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),

          RitualCard(
            glowEffect: false,
            ritualCorners: false,
            child: Column(
              children: [
                const Text(
                  'ATRIBUTOS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'BebasNeue',
                    color: AppTheme.pureWhite,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Distribua seus pontos entre os cinco atributos',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.iron,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 24),
                _buildAttributeSlider('FOR', 'Força', _forca, AppTheme.scarletRed, (val) {
                  if (_canSetAttribute(val)) {
                    setState(() => _forca = val);
                  }
                }),
                const SizedBox(height: 16),
                _buildAttributeSlider('AGI', 'Agilidade', _agilidade, AppTheme.mutagenGreen, (val) {
                  if (_canSetAttribute(val)) {
                    setState(() => _agilidade = val);
                  }
                }),
                const SizedBox(height: 16),
                _buildAttributeSlider('VIG', 'Vigor', _vigor, AppTheme.scarletRed, (val) {
                  if (_canSetAttribute(val)) {
                    setState(() => _vigor = val);
                  }
                }),
                const SizedBox(height: 16),
                _buildAttributeSlider('INT', 'Inteligência', _inteligencia, AppTheme.alertYellow, (val) {
                  if (_canSetAttribute(val)) {
                    setState(() => _inteligencia = val);
                  }
                }),
                const SizedBox(height: 16),
                _buildAttributeSlider('PRE', 'Presença', _presenca, AppTheme.alertYellow, (val) {
                  if (_canSetAttribute(val)) {
                    setState(() => _presenca = val);
                  }
                }),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
        ],
      ),
    );
  }

  bool _canSetAttribute(int newValue) {
    // Calculate current points without the attribute being changed
    int currentTotal = _forca + _agilidade + _vigor + _inteligencia + _presenca;
    int negativeCount = 0;
    if (_forca == -1) negativeCount++;
    if (_agilidade == -1) negativeCount++;
    if (_vigor == -1) negativeCount++;
    if (_inteligencia == -1) negativeCount++;
    if (_presenca == -1) negativeCount++;

    int totalAvailable = 4 + negativeCount;

    // Allow if within limits
    return true; // We'll validate in slider min/max and on next step
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
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.alertYellow.withOpacity(0.15),
                    border: Border.all(color: AppTheme.alertYellow, width: 2),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: AppTheme.alertYellow,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'PERÍCIAS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'BebasNeue',
                    color: AppTheme.alertYellow,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Você poderá configurar as perícias após criar o personagem. Isso permite ajustar habilidades específicas conforme sua estratégia.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.coldGray,
                    fontFamily: 'Montserrat',
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.alertYellow.withOpacity(0.08),
                                        border: Border.all(
                      color: AppTheme.alertYellow.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_rounded,
                        color: AppTheme.alertYellow,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Dica: Escolha perícias que complementem sua classe e origem.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.alertYellow,
                            fontFamily: 'Montserrat',
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
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
                            borderSide: const BorderSide(color: AppTheme.coldGray, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppTheme.coldGray, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
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
                    borderSide: const BorderSide(color: AppTheme.coldGray, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
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
    // In Ordem Paranormal, attribute value = number of d20 dice you roll
    String displayValue = value >= 0 ? '+$value' : '$value';

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.darkGray,
                border: Border.all(
                  color: color.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.lightGray,
                      fontFamily: 'Montserrat',
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    displayValue,
                    style: TextStyle(
                      fontSize: 20,
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
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.lightGray,
                      fontFamily: 'Montserrat',
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: color,
                      inactiveTrackColor: AppTheme.steel.withOpacity(0.3),
                      thumbColor: color,
                      overlayColor: color.withOpacity(0.2),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: value.toDouble(),
                      min: -1,
                      max: 3,
                      divisions: 4,
                      label: displayValue,
                      onChanged: (val) => onChanged(val.round()),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              alignment: Alignment.centerRight,
              child: Text(
                value >= 0 ? '$value d20' : '$value',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFamily: 'SpaceMono',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    final isFinalStep = _currentStep == _totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.abyssalBlack.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: AppTheme.coldGray.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.abyssalBlack.withOpacity(0.6),
            blurRadius: 12,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: GlowingButton(
                  label: 'Anterior',
                  icon: Icons.arrow_back_rounded,
                  onPressed: _previousStep,
                  style: GlowingButtonStyle.secondary,
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: GlowingButton(
                label: isFinalStep ? 'Finalizar' : 'Próximo',
                icon: isFinalStep ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                onPressed: isFinalStep ? _saveCharacter : _nextStep,
                isLoading: _isLoading,
                pulsateGlow: isFinalStep,
                style: isFinalStep
                    ? GlowingButtonStyle.primary
                    : GlowingButtonStyle.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCharacter() async {
    if (_nomeController.text.isEmpty) {
      _showModernDialog(
        title: 'VALIDAÇÃO',
        message: 'Por favor, preencha o nome do personagem',
        icon: Icons.warning_rounded,
        accentColor: AppTheme.alertYellow,
        hasConfirmButton: true,
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
        _showModernDialog(
          title: widget.character == null ? 'SUCESSO' : 'ATUALIZADO',
          message: widget.character == null
            ? 'Agente criado com sucesso! Prepare-se para a jornada.'
            : 'Agente atualizado com êxito.',
          icon: Icons.check_circle_rounded,
          accentColor: AppTheme.mutagenGreen,
          hasConfirmButton: true,
          onConfirm: () {
            Navigator.pop(context);
            Navigator.pop(context, true);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        _showModernDialog(
          title: 'ERRO',
          message: 'Falha ao salvar: ${e.toString()}',
          icon: Icons.error_rounded,
          accentColor: AppTheme.ritualRed,
          hasConfirmButton: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showModernDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color accentColor,
    bool hasConfirmButton = false,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        child: RitualCard(
          glowEffect: true,
          glowColor: accentColor,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  border: Border.all(color: accentColor, width: 2),
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: accentColor,
                ),
              ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.coldGray,
                  fontFamily: 'Montserrat',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GlowingButton(
                label: 'Confirmar',
                icon: Icons.check,
                onPressed: onConfirm ?? () => Navigator.pop(context),
                style: GlowingButtonStyle.primary,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
