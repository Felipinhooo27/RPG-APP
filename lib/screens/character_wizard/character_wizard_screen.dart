import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/database/character_repository.dart';
import '../../core/utils/character_generator.dart';
import '../../models/character.dart';
import '../../widgets/hexatombe_ui_components.dart';

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

  // Step 5: Perícias
  List<String> _periciasTreinadasSelecionadas = [];

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
    // Garante que valores estão no range correto (0 a 5)
    _forca = char.forca.clamp(0, 5);
    _agilidade = char.agilidade.clamp(0, 5);
    _vigor = char.vigor.clamp(0, 5);
    _intelecto = char.intelecto.clamp(0, 5);
    _presenca = char.presenca.clamp(0, 5);
    _periciasTreinadasSelecionadas = List.from(char.periciasTreinadas);
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
      body: SafeArea(
        child: Column(
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

          // Nome - usando componente temático
          HexatombeTextField(
            label: 'NOME DO PERSONAGEM',
            hintText: 'Ex: Enzo Rodrigues',
            controller: _nomeController,
            textCapitalization: TextCapitalization.words,
            onChanged: (value) => setState(() {}), // FIX: Reage em tempo real para validação
          ),

          const SizedBox(height: 8),

          // Link de nome aleatório (não é mais um botão com caixa)
          InkWell(
            onTap: () {
              setState(() {
                _nomeController.text = CharacterGenerator.generateRandomName();
              });
            },
            child: Text(
              '[ GERAR NOME ALEATÓRIO ]',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AppColors.scarletRed,
                fontFamily: 'monospace',
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Patente (opcional) - usando componente temático
          HexatombeTextField(
            label: 'PATENTE (OPCIONAL)',
            hintText: 'Ex: Líder, Recruta, Operador',
            controller: _patenteController,
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
    );
  }

  // ==================== STEP 2: ORIGEM & CLASSE ====================

  Widget _buildStep2OrigemClasse() {
    // Controller temporário para Trilha (para usar HexatombeTextField)
    final trilhaController = TextEditingController(text: _selectedTrilha ?? '');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ORIGEM & CLASSE', style: AppTextStyles.title),
          const SizedBox(height: 24),

          // Origem - usando componente temático
          HexatombeDropdown<Origem>(
            label: 'ORIGEM',
            value: _selectedOrigemValue,
            hintText: 'Selecione uma origem',
            items: Origem.values.map((origem) {
              return DropdownMenuItem(
                value: origem,
                child: Text(origem.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedOrigemValue = value),
          ),

          // Descrição da origem (sem caixa, apenas texto cinza "typewriter")
          if (_selectedOrigemValue != null) ...[
            const SizedBox(height: 12),
            Text(
              CharacterGenerator.getOrigemDescription(_selectedOrigemValue!),
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF888888),
                height: 1.5,
                fontFamily: 'monospace',
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Classe - usando componente temático
          HexatombeDropdown<CharacterClass>(
            label: 'CLASSE',
            value: _selectedClasse,
            hintText: 'Selecione uma classe',
            items: CharacterClass.values.map((classe) {
              return DropdownMenuItem(
                value: classe,
                child: Text(classe.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedClasse = value),
          ),

          // Descrição da classe (sem caixa, apenas texto cinza "typewriter")
          if (_selectedClasse != null) ...[
            const SizedBox(height: 12),
            Text(
              CharacterGenerator.getClasseDescription(_selectedClasse!),
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF888888),
                height: 1.5,
                fontFamily: 'monospace',
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Trilha (opcional) - usando componente temático
          HexatombeTextField(
            label: 'TRILHA (OPCIONAL)',
            hintText: 'Ex: Operações Especiais, Medicina',
            controller: trilhaController,
            textCapitalization: TextCapitalization.words,
            onChanged: (value) => setState(() => _selectedTrilha = value.isEmpty ? null : value),
          ),
        ],
      ),
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

    final pontosRestantes = pontosDisponiveis - pontosUsados;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DISTRIBUIR ATRIBUTOS', style: AppTextStyles.title),
          const SizedBox(height: 24),

          // Display de pontos restantes (sem caixa, apenas texto temático)
          Row(
            children: [
              Text(
                'PONTOS RESTANTES:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Color(0xFFe0e0e0),
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$pontosRestantes',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.scarletRed,
                  height: 1.0,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Dica em cinza-claro
          Text(
            'Distribua até 4 pontos (recomendado). Máximo +5 por atributo. Você pode avançar com pontos restantes.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF888888),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),
          GrungeDivider(color: AppColors.scarletRed.withOpacity(0.3)),
          const SizedBox(height: 24),

          // Sliders - usando componentes temáticos (mínimo 0, máximo 5)
          HexatombeSlider(
            label: 'FORÇA',
            value: _forca,
            min: 0,
            max: 5,
            color: AppColors.forRed,
            onChanged: (v) => setState(() => _forca = v),
          ),
          const SizedBox(height: 20),

          HexatombeSlider(
            label: 'AGILIDADE',
            value: _agilidade,
            min: 0,
            max: 5,
            color: AppColors.agiGreen,
            onChanged: (v) => setState(() => _agilidade = v),
          ),
          const SizedBox(height: 20),

          HexatombeSlider(
            label: 'VIGOR',
            value: _vigor,
            min: 0,
            max: 5,
            color: AppColors.vigBlue,
            onChanged: (v) => setState(() => _vigor = v),
          ),
          const SizedBox(height: 20),

          HexatombeSlider(
            label: 'INTELECTO',
            value: _intelecto,
            min: 0,
            max: 5,
            color: AppColors.intMagenta,
            onChanged: (v) => setState(() => _intelecto = v),
          ),
          const SizedBox(height: 20),

          HexatombeSlider(
            label: 'PRESENÇA',
            value: _presenca,
            min: 0,
            max: 5,
            color: AppColors.preGold,
            onChanged: (v) => setState(() => _presenca = v),
          ),

          const SizedBox(height: 32),
          GrungeDivider(color: AppColors.scarletRed.withOpacity(0.3)),
          const SizedBox(height: 24),

          // Link de distribuição aleatória (não é mais um botão com caixa)
          Center(
            child: InkWell(
              onTap: () {
                final randomDist = CharacterGenerator.generateRandomDistribution();
                _applySuggestedDistribution(randomDist);
              },
              child: Text(
                '[ DISTRIBUIÇÃO ALEATÓRIA ]',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: AppColors.scarletRed,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),

          // REMOVIDO: Distribuições sugeridas (conforme solicitado)
        ],
      ),
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

    // Calcular Carga Máxima: 2 + (Força x 5)
    final cargaMaxima = (2 + (_forca * 5)).clamp(5, 999); // Mínimo 5

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ESTATÍSTICAS CALCULADAS', style: AppTextStyles.title),
          const SizedBox(height: 8),

          // Subtítulo
          Text(
            'Estatísticas derivadas dos atributos do seu agente',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF888888),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),
          GrungeDivider(color: AppColors.scarletRed.withOpacity(0.3)),
          const SizedBox(height: 16),

          // Usando componente StatDisplay para layout de dossiê limpo
          StatDisplay(
            label: 'PV - PONTOS DE VIDA',
            formula: 'Base ${CharacterGenerator.pvBase[_selectedClasse]} + Vigor $_vigor',
            value: '${stats['pvMax']}',
          ),

          GrungeDivider(color: AppColors.silver.withOpacity(0.1)),

          StatDisplay(
            label: 'PE - PONTOS DE ESFORÇO',
            formula: 'Base ${CharacterGenerator.peBase[_selectedClasse]} + Presença $_presenca',
            value: '${stats['peMax']}',
          ),

          GrungeDivider(color: AppColors.silver.withOpacity(0.1)),

          StatDisplay(
            label: 'SAN - SANIDADE',
            formula: 'Base ${CharacterGenerator.sanBase[_selectedClasse]}',
            value: '${stats['sanMax']}',
          ),

          const SizedBox(height: 16),
          GrungeDivider(color: AppColors.scarletRed.withOpacity(0.3)),
          const SizedBox(height: 16),

          StatDisplay(
            label: 'DEFESA',
            formula: '10 + Agilidade $_agilidade',
            value: '${stats['defesa']}',
          ),

          GrungeDivider(color: AppColors.silver.withOpacity(0.1)),

          StatDisplay(
            label: 'BLOQUEIO',
            formula: 'Padrão',
            value: '10',
          ),

          GrungeDivider(color: AppColors.silver.withOpacity(0.1)),

          StatDisplay(
            label: 'DESLOCAMENTO',
            formula: '9 metros (padrão)',
            value: '9m',
          ),

          GrungeDivider(color: AppColors.silver.withOpacity(0.1)),

          // NOVO: Carga Máxima
          StatDisplay(
            label: 'CARGA MÁXIMA',
            formula: 'Base 2 + (Força $_forca × 5)',
            value: '$cargaMaxima',
          ),

          const SizedBox(height: 16),
          GrungeDivider(color: AppColors.scarletRed.withOpacity(0.3)),

          // REMOVIDO: Caixa de resumo verde (não faz parte do tema Hexatombe)
        ],
      ),
    );
  }

  // ==================== STEP 5: PERÍCIAS ====================

  Widget _buildStep5Pericias() {
    final pericias = {
      'Acrobacia': {'attr': 'AGI', 'bonus': _agilidade},
      'Adestramento': {'attr': 'PRE', 'bonus': _presenca},
      'Artes': {'attr': 'PRE', 'bonus': _presenca},
      'Atletismo': {'attr': 'FOR', 'bonus': _forca},
      'Atualidades': {'attr': 'INT', 'bonus': _intelecto},
      'Ciências': {'attr': 'INT', 'bonus': _intelecto},
      'Crime': {'attr': 'AGI', 'bonus': _agilidade},
      'Diplomacia': {'attr': 'PRE', 'bonus': _presenca},
      'Enganação': {'attr': 'PRE', 'bonus': _presenca},
      'Fortitude': {'attr': 'VIG', 'bonus': _vigor},
      'Furtividade': {'attr': 'AGI', 'bonus': _agilidade},
      'Iniciativa': {'attr': 'AGI', 'bonus': _agilidade},
      'Intimidação': {'attr': 'PRE', 'bonus': _presenca},
      'Intuição': {'attr': 'PRE', 'bonus': _presenca},
      'Investigação': {'attr': 'INT', 'bonus': _intelecto},
      'Luta': {'attr': 'FOR', 'bonus': _forca},
      'Medicina': {'attr': 'INT', 'bonus': _intelecto},
      'Ocultismo': {'attr': 'INT', 'bonus': _intelecto},
      'Percepção': {'attr': 'PRE', 'bonus': _presenca},
      'Pilotagem': {'attr': 'AGI', 'bonus': _agilidade},
      'Pontaria': {'attr': 'AGI', 'bonus': _agilidade},
      'Profissão': {'attr': 'INT', 'bonus': _intelecto},
      'Reflexos': {'attr': 'AGI', 'bonus': _agilidade},
      'Religião': {'attr': 'PRE', 'bonus': _presenca},
      'Sobrevivência': {'attr': 'INT', 'bonus': _intelecto},
      'Tática': {'attr': 'INT', 'bonus': _intelecto},
      'Tecnologia': {'attr': 'INT', 'bonus': _intelecto},
      'Vontade': {'attr': 'PRE', 'bonus': _presenca},
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SELEÇÃO DE PERÍCIAS', style: AppTextStyles.title),
          const SizedBox(height: 16),

          // Contador (sem caixa, apenas texto)
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: Color(0xFFe0e0e0),
                fontFamily: 'monospace',
              ),
              children: [
                TextSpan(
                  text: '${_periciasTreinadasSelecionadas.length}',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.scarletRed,
                  ),
                ),
                TextSpan(text: ' PERÍCIAS SELECIONADAS'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Dica em cinza-claro
          Text(
            'Perícias treinadas ganham +5 de bônus. Recomendado: 4-5 perícias.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF888888),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),
          GrungeDivider(color: AppColors.scarletRed.withOpacity(0.3)),
          const SizedBox(height: 16),

          // Lista de perícias (sem caixas, apenas divisórias)
          ...pericias.entries.map((entry) {
            final nome = entry.key;
            final isTreinada = _periciasTreinadasSelecionadas.contains(nome);
            final bonus = entry.value['bonus'] as int;
            final bonusTreinada = isTreinada ? 5 : 0;
            final total = bonus + bonusTreinada;
            final attr = entry.value['attr'] as String;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      // Checkbox hexagonal
                      HexagonCheckbox(
                        value: isTreinada,
                        size: 24,
                        onChanged: (value) {
                          setState(() {
                            if (value) {
                              _periciasTreinadasSelecionadas.add(nome);
                            } else {
                              _periciasTreinadasSelecionadas.remove(nome);
                            }
                          });
                        },
                      ),

                      const SizedBox(width: 16),

                      // Nome
                      Expanded(
                        child: Text(
                          nome.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Color(0xFFe0e0e0),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),

                      // Tag de atributo (apenas texto colorido, sem caixa)
                      Text(
                        attr,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: _getAttrColor(attr),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Bônus total
                      Text(
                        total >= 0 ? '+$total' : '$total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFe0e0e0),
                        ),
                      ),
                    ],
                  ),
                ),

                // Divisória arranhada cinza-escura
                GrungeDivider(color: Color(0xFF2a2a2a)),
              ],
            );
          }).toList(),
        ],
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
          const SizedBox(height: 8),

          // Subtítulo
          Text(
            'Revise as informações do dossiê antes de finalizar',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF888888),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),
          GrungeDivider(color: AppColors.scarletRed.withOpacity(0.3), heavy: true),
          const SizedBox(height: 24),

          // Seção: Informações Básicas (sem caixa, apenas divisórias)
          Text(
            'INFORMAÇÕES BÁSICAS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.5,
              color: AppColors.scarletRed,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 16),

          _buildDossierEntry('Nome', _nomeController.text),
          if (_patenteController.text.isNotEmpty)
            _buildDossierEntry('Patente', _patenteController.text),

          const SizedBox(height: 24),
          GrungeDivider(color: AppColors.scarletRed.withOpacity(0.3), heavy: true),
          const SizedBox(height: 24),

          // Seção: Origem & Classe
          Text(
            'ORIGEM & CLASSE',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.5,
              color: AppColors.scarletRed,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 16),

          _buildDossierEntry('Origem', _selectedOrigemValue?.name.toUpperCase() ?? '-'),
          _buildDossierEntry('Classe', _selectedClasse?.name.toUpperCase() ?? '-'),
          if (_selectedTrilha != null)
            _buildDossierEntry('Trilha', _selectedTrilha!),

          const SizedBox(height: 24),
          GrungeDivider(color: AppColors.scarletRed.withOpacity(0.3), heavy: true),
          const SizedBox(height: 24),

          // Seção: Atributos
          Text(
            'ATRIBUTOS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.5,
              color: AppColors.scarletRed,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 16),

          _buildDossierEntry('Força', _forca >= 0 ? '+$_forca' : '$_forca'),
          _buildDossierEntry('Agilidade', _agilidade >= 0 ? '+$_agilidade' : '$_agilidade'),
          _buildDossierEntry('Vigor', _vigor >= 0 ? '+$_vigor' : '$_vigor'),
          _buildDossierEntry('Intelecto', _intelecto >= 0 ? '+$_intelecto' : '$_intelecto'),
          _buildDossierEntry('Presença', _presenca >= 0 ? '+$_presenca' : '$_presenca'),

          const SizedBox(height: 32),
          GrungeDivider(color: AppColors.scarletRed.withOpacity(0.3), heavy: true),
          const SizedBox(height: 32),

          // Botão final
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

  Widget _buildDossierEntry(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Color(0xFF888888),
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFe0e0e0),
                height: 1.4,
              ),
            ),
          ),
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
          // Botão ANTERIOR (apenas texto, sem borda)
          if (_currentStep > 0)
            Expanded(
              child: InkWell(
                onTap: _previousStep,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: Text(
                    'ANTERIOR',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Color(0xFFe0e0e0),
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),

          // Botão PRÓXIMO (vermelho sólido)
          if (_currentStep < 5)
            Expanded(
              child: ElevatedButton(
                onPressed: _canProceed() ? _nextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.scarletRed,
                  disabledBackgroundColor: Color(0xFF2a2a2a),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'PRÓXIMO',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: _canProceed() ? Colors.white : Color(0xFF666666),
                    fontFamily: 'monospace',
                  ),
                ),
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
      case 2: // Atributos - Permite avançar mesmo ultrapassando o limite
        final pontosUsados = _forca + _agilidade + _vigor + _intelecto + _presenca;
        return pontosUsados <= 25; // Máximo possível: 5×5 = 25 pontos
      case 3: // Stats
        return true;
      case 4: // Perícias
        return _periciasTreinadasSelecionadas.length >= 4;
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

    // Verificar se estourou o limite de 4 pontos
    final pontosUsados = _forca + _agilidade + _vigor + _intelecto + _presenca;

    if (pontosUsados > 4) {
      // Mostrar dialog de confirmação
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkGray,
          title: Text(
            'ATENÇÃO',
            style: TextStyle(
              color: AppColors.scarletRed,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          content: Text(
            'Você distribuiu $pontosUsados pontos (limite recomendado: 4).\n\n'
            'Tem certeza que deseja criar seu personagem estourando o limite de pontos?',
            style: TextStyle(
              color: Color(0xFFe0e0e0),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'CANCELAR',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.scarletRed,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'CRIAR MESMO ASSIM',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirm != true) return; // Usuário cancelou
    }

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

      // Adicionar perícias selecionadas
      final characterWithSkills = character.copyWith(
        periciasTreinadas: _periciasTreinadasSelecionadas,
      );

      if (widget.characterToEdit == null) {
        await _characterRepo.create(characterWithSkills);
      } else {
        await _characterRepo.update(characterWithSkills.copyWith(id: widget.characterToEdit!.id));
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

  Color _getAttrColor(String attr) {
    switch (attr) {
      case 'FOR':
        return AppColors.forRed;
      case 'AGI':
        return AppColors.agiGreen;
      case 'VIG':
        return AppColors.vigBlue;
      case 'INT':
        return AppColors.intMagenta;
      case 'PRE':
        return AppColors.preGold;
      default:
        return AppColors.silver;
    }
  }
}
