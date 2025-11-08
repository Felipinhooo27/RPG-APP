import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../models/character.dart';
import '../models/power.dart';
import '../models/item.dart';
import '../models/skill.dart';
import '../services/local_database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../utils/item_generator.dart';

/// Editor manual completo de personagens
/// Permite editar TUDO sem usar o gerador automático
class CharacterFullEditorScreen extends StatefulWidget {
  final Character? character; // null = criar novo
  final String createdBy;

  const CharacterFullEditorScreen({
    super.key,
    this.character,
    required this.createdBy,
  });

  @override
  State<CharacterFullEditorScreen> createState() => _CharacterFullEditorScreenState();
}

class _CharacterFullEditorScreenState extends State<CharacterFullEditorScreen> with SingleTickerProviderStateMixin {
  final LocalDatabaseService _dbService = LocalDatabaseService();
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Controllers
  late TextEditingController _nomeController;
  late TextEditingController _patenteController;
  late TextEditingController _origemController;
  late TextEditingController _trilhaController;

  // Atributos
  int _forca = 0;
  int _agilidade = 0;
  int _vigor = 0;
  int _inteligencia = 0;
  int _presenca = 0;

  // Status
  int _nex = 5;
  int _pvMax = 10;
  int _pvAtual = 10;
  int _peMax = 1;
  int _peAtual = 1;
  int _psMax = 10;
  int _psAtual = 10;
  int _creditos = 0;
  int _iniciativaBase = 0;

  // Classe e trilha
  String _classe = 'Combatente';
  final List<String> _classes = ['Combatente', 'Especialista', 'Ocultista'];

  // Perícias
  Map<String, Skill> _pericias = {};
  final List<String> _allSkills = [
    'Acrobacia', 'Adestramento', 'Artes', 'Atletismo', 'Atualidades',
    'Ciências', 'Crime', 'Diplomacia', 'Enganação', 'Fortitude',
    'Furtividade', 'Iniciativa', 'Intimidação', 'Intuição', 'Investigação',
    'Luta', 'Medicina', 'Ocultismo', 'Percepção', 'Pilotagem',
    'Pontaria', 'Profissão', 'Reflexos', 'Religião', 'Sobrevivência',
    'Tática', 'Tecnologia', 'Vontade',
  ];

  // Poderes e itens
  List<Power> _poderes = [];
  List<Item> _inventario = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    if (widget.character != null) {
      _loadCharacterData();
    } else {
      _initializeNewCharacter();
    }
  }

  void _loadCharacterData() {
    final char = widget.character!;
    _nomeController = TextEditingController(text: char.nome);
    _patenteController = TextEditingController(text: char.patente);
    _origemController = TextEditingController(text: char.origem);
    _trilhaController = TextEditingController(text: char.trilha);

    _forca = char.forca;
    _agilidade = char.agilidade;
    _vigor = char.vigor;
    _inteligencia = char.inteligencia;
    _presenca = char.presenca;

    _nex = char.nex;
    _pvMax = char.pvMax;
    _pvAtual = char.pvAtual;
    _peMax = char.peMax;
    _peAtual = char.peAtual;
    _psMax = char.psMax;
    _psAtual = char.psAtual;
    _creditos = char.creditos;
    _iniciativaBase = char.iniciativaBase;

    _classe = char.classe;
    _pericias = Map.from(char.pericias);
    _poderes = List.from(char.poderes);
    _inventario = List.from(char.inventario);
  }

  void _initializeNewCharacter() {
    _nomeController = TextEditingController();
    _patenteController = TextEditingController(text: 'Recruta');
    _origemController = TextEditingController(text: 'Acadêmico');
    _trilhaController = TextEditingController(text: 'Nenhuma');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomeController.dispose();
    _patenteController.dispose();
    _origemController.dispose();
    _trilhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HexatombeBackground(
      showParticles: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppTheme.abyssalBlack.withOpacity(0.9),
          title: Text(
            widget.character == null ? 'CRIAR PERSONAGEM' : 'EDITAR PERSONAGEM',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'BebasNeue',
              letterSpacing: 2,
            ),
          ),
          actions: [
            if (!_isSaving)
              IconButton(
                icon: const Icon(Icons.save, color: AppTheme.mutagenGreen),
                onPressed: _saveCharacter,
                tooltip: 'Salvar',
              ),
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Loading(),
                ),
              ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.alertYellow,
            labelColor: AppTheme.alertYellow,
            unselectedLabelColor: AppTheme.coldGray,
            tabs: const [
              Tab(icon: Icon(Icons.person), text: 'BÁSICO'),
              Tab(icon: Icon(Icons.school), text: 'PERÍCIAS'),
              Tab(icon: Icon(Icons.flash_on), text: 'PODERES'),
              Tab(icon: Icon(Icons.inventory), text: 'ITENS'),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBasicTab(),
              _buildSkillsTab(),
              _buildPowersTab(),
              _buildInventoryTab(),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== ABA BÁSICO ====================
  Widget _buildBasicTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Informações Básicas
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.obscureGray, AppTheme.industrialGray],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppTheme.alertYellow.withOpacity(0.4),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('INFORMAÇÕES BÁSICAS', Icons.person),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nomeController,
                style: const TextStyle(color: AppTheme.paleWhite),
                decoration: _buildInputDecoration('Nome', Icons.badge),
                validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _classe,
                decoration: _buildInputDecoration('Classe', Icons.work),
                dropdownColor: AppTheme.obscureGray,
                style: const TextStyle(color: AppTheme.paleWhite),
                items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (value) => setState(() => _classe = value!),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _origemController,
                      style: const TextStyle(color: AppTheme.paleWhite),
                      decoration: _buildInputDecoration('Origem', Icons.location_city),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _patenteController,
                      style: const TextStyle(color: AppTheme.paleWhite),
                      decoration: _buildInputDecoration('Patente', Icons.military_tech),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _trilhaController,
                style: const TextStyle(color: AppTheme.paleWhite),
                decoration: _buildInputDecoration('Trilha', Icons.route),
              ),
            ],
          ),
        ),

        // Atributos
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.obscureGray, AppTheme.industrialGray],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppTheme.ritualRed.withOpacity(0.4),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('ATRIBUTOS', Icons.fitness_center),
              const SizedBox(height: 16),

              _buildAttributeSlider('Força', _forca, (v) => setState(() => _forca = v)),
              _buildAttributeSlider('Agilidade', _agilidade, (v) => setState(() => _agilidade = v)),
              _buildAttributeSlider('Vigor', _vigor, (v) => setState(() => _vigor = v)),
              _buildAttributeSlider('Inteligência', _inteligencia, (v) => setState(() => _inteligencia = v)),
              _buildAttributeSlider('Presença', _presenca, (v) => setState(() => _presenca = v)),
            ],
          ),
        ),

        // Status
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.obscureGray, AppTheme.industrialGray],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppTheme.mutagenGreen.withOpacity(0.4),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('STATUS', Icons.favorite),
              const SizedBox(height: 16),

              _buildStatusRow('NEX', _nex, (v) => setState(() => _nex = v), max: 99),
              _buildStatusRow('PV Máximo', _pvMax, (v) => setState(() => _pvMax = v), max: 200),
              _buildStatusRow('PV Atual', _pvAtual, (v) => setState(() => _pvAtual = v), max: _pvMax),
              _buildStatusRow('PE Máximo', _peMax, (v) => setState(() => _peMax = v), max: 100),
              _buildStatusRow('PE Atual', _peAtual, (v) => setState(() => _peAtual = v), max: _peMax),
              _buildStatusRow('PS Máximo', _psMax, (v) => setState(() => _psMax = v), max: 100),
              _buildStatusRow('PS Atual', _psAtual, (v) => setState(() => _psAtual = v), max: _psMax),
              _buildStatusRow('Créditos', _creditos, (v) => setState(() => _creditos = v), max: 1000000),
              _buildStatusRow('Iniciativa Base', _iniciativaBase, (v) => setState(() => _iniciativaBase = v), max: 50),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== ABA PERÍCIAS ====================
  Widget _buildSkillsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.obscureGray, AppTheme.industrialGray],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppTheme.etherealPurple.withOpacity(0.4),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader('PERÍCIAS', Icons.school),
                  GlowingButton(
                    label: 'Limpar Todas',
                    icon: Icons.clear_all,
                    onPressed: () {
                      setState(() => _pericias.clear());
                    },
                    style: GlowingButtonStyle.danger,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ..._allSkills.map((skill) {
                final skillObj = _pericias[skill];
                final level = skillObj?.level.toString().split('.').last ?? 'untrained';
                final levelString = level == 'untrained' ? 'nao_treinado' : level;
                return _buildSkillRow(skill, levelString);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillRow(String skill, String level) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.obscureGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: (level != 'nao_treinado' ? AppTheme.etherealPurple : AppTheme.coldGray).withOpacity(0.35),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              skill,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.paleWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownButton<String>(
            value: level,
            dropdownColor: AppTheme.obscureGray,
            underline: const SizedBox(),
            style: const TextStyle(color: AppTheme.etherealPurple, fontSize: 12),
            items: const [
              DropdownMenuItem(value: 'nao_treinado', child: Text('Não Treinado')),
              DropdownMenuItem(value: 'treinado', child: Text('Treinado (+5)')),
              DropdownMenuItem(value: 'veterano', child: Text('Veterano (+10)')),
              DropdownMenuItem(value: 'expert', child: Text('Expert (+15)')),
            ],
            onChanged: (value) {
              setState(() {
                if (value == 'nao_treinado') {
                  _pericias.remove(skill);
                } else {
                  // Convert string level to SkillLevel enum
                  SkillLevel skillLevel;
                  switch (value) {
                    case 'expert':
                      skillLevel = SkillLevel.expert;
                      break;
                    case 'veterano':
                      skillLevel = SkillLevel.veteran;
                      break;
                    case 'treinado':
                      skillLevel = SkillLevel.trained;
                      break;
                    default:
                      skillLevel = SkillLevel.untrained;
                  }

                  // Get skill info
                  final skillInfo = OrdemSkills.allSkills[skill];
                  final categoryString = skillInfo?['category'] ?? 'combat';
                  final attribute = skillInfo?['attribute'] ?? 'INT';

                  // Convert category string to enum
                  SkillCategory category;
                  switch (categoryString) {
                    case 'investigation':
                      category = SkillCategory.investigation;
                      break;
                    case 'social':
                      category = SkillCategory.social;
                      break;
                    case 'occult':
                      category = SkillCategory.occult;
                      break;
                    case 'survival':
                      category = SkillCategory.survival;
                      break;
                    default:
                      category = SkillCategory.combat;
                  }

                  _pericias[skill] = Skill(
                    name: skill,
                    category: category,
                    level: skillLevel,
                    attribute: attribute,
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }

  // ==================== ABA PODERES ====================
  Widget _buildPowersTab() {
    return Column(
      children: [
        Expanded(
          child: _poderes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.flash_off, size: 80, color: AppTheme.coldGray),
                      const SizedBox(height: 16),
                      const Text(
                        'NENHUM PODER',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.coldGray,
                          fontFamily: 'BebasNeue',
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _poderes.length,
                  itemBuilder: (context, index) => _buildPowerCard(_poderes[index], index),
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.obscureGray,
            border: Border(top: BorderSide(color: AppTheme.alertYellow.withOpacity(0.3), width: 2)),
          ),
          child: GlowingButton(
            label: 'Adicionar Poder',
            icon: Icons.add,
            onPressed: _addPower,
            style: GlowingButtonStyle.primary,
            pulsateGlow: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPowerCard(Power power, int index) {
    return RitualCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      glowEffect: true,
      glowColor: AppTheme.ritualRed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  power.nome.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.alertYellow,
                    fontFamily: 'BebasNeue',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: AppTheme.etherealPurple, size: 20),
                onPressed: () => _editPower(index),
                tooltip: 'Editar',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: AppTheme.ritualRed, size: 20),
                onPressed: () => setState(() => _poderes.removeAt(index)),
                tooltip: 'Excluir',
              ),
            ],
          ),
          if (power.descricao.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              power.descricao,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.coldGray,
              ),
            ),
          ],
          const SizedBox(height: 8),
          _buildBadge('Elemento: ${power.elemento}', AppTheme.etherealPurple),
        ],
      ),
    );
  }

  // ==================== ABA INVENTÁRIO ====================
  Widget _buildInventoryTab() {
    final totalEspaco = _inventario.fold<int>(0, (sum, item) => sum + (item.espaco * item.quantidade));

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.obscureGray.withOpacity(0.5),
            border: Border(bottom: BorderSide(color: AppTheme.alertYellow.withOpacity(0.3), width: 2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatChip('Total de Itens', '${_inventario.length}', AppTheme.mutagenGreen),
              _buildStatChip('Espaço Usado', '$totalEspaco', AppTheme.alertYellow),
              _buildStatChip('Créditos', '$_creditos¢', AppTheme.etherealPurple),
            ],
          ),
        ),
        Expanded(
          child: _inventario.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2, size: 80, color: AppTheme.coldGray),
                      const SizedBox(height: 16),
                      const Text(
                        'INVENTÁRIO VAZIO',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.coldGray,
                          fontFamily: 'BebasNeue',
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _inventario.length,
                  itemBuilder: (context, index) => _buildInventoryCard(_inventario[index], index),
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.obscureGray,
            border: Border(top: BorderSide(color: AppTheme.alertYellow.withOpacity(0.3), width: 2)),
          ),
          child: GlowingButton(
            label: 'Adicionar Item',
            icon: Icons.add,
            onPressed: _addItem,
            style: GlowingButtonStyle.primary,
            pulsateGlow: true,
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryCard(Item item, int index) {
    return RitualCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nome,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.paleWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.preco}¢ • ${item.espaco} espaço • Qtd: ${item.quantidade}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.coldGray,
                  ),
                ),
                if (item.descricao.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.descricao,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.coldGray,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.etherealPurple),
            onPressed: () => _editItem(index),
            tooltip: 'Editar',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppTheme.ritualRed),
            onPressed: () => setState(() => _inventario.removeAt(index)),
            tooltip: 'Excluir',
          ),
        ],
      ),
    );
  }

  // ==================== HELPERS ====================
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.alertYellow, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.alertYellow,
            fontFamily: 'BebasNeue',
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.coldGray),
      prefixIcon: Icon(icon, color: AppTheme.alertYellow, size: 20),
      filled: true,
      fillColor: AppTheme.obscureGray,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppTheme.alertYellow, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppTheme.coldGray, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppTheme.alertYellow, width: 2),
      ),
    );
  }

  Widget _buildAttributeSlider(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.paleWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.ritualRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.ritualRed.withOpacity(0.35),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Text(
                '$value',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ritualRed,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 20,
          divisions: 20,
          activeColor: AppTheme.ritualRed,
          inactiveColor: AppTheme.obscureGray,
          onChanged: (v) => onChanged(v.toInt()),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildStatusRow(String label, int value, Function(int) onChanged, {int max = 100}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.paleWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: AppTheme.ritualRed, size: 20),
                  onPressed: value > 0 ? () => onChanged(value - 1) : null,
                ),
                Expanded(
                  child: Text(
                    '$value',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.mutagenGreen,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppTheme.mutagenGreen, size: 20),
                  onPressed: value < max ? () => onChanged(value + 1) : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w700,
            fontFamily: 'BebasNeue',
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
            fontFamily: 'BebasNeue',
          ),
        ),
      ],
    );
  }

  // ==================== AÇÕES ====================
  Future<void> _addPower() async {
    final result = await showDialog<Power>(
      context: context,
      builder: (context) => _PowerFormDialog(),
    );

    if (result != null) {
      setState(() => _poderes.add(result));
    }
  }

  Future<void> _editPower(int index) async {
    final result = await showDialog<Power>(
      context: context,
      builder: (context) => _PowerFormDialog(power: _poderes[index]),
    );

    if (result != null) {
      setState(() => _poderes[index] = result);
    }
  }

  Future<void> _addItem() async {
    final result = await showDialog<Item>(
      context: context,
      builder: (context) => _ItemFormDialog(),
    );

    if (result != null) {
      setState(() => _inventario.add(result));
    }
  }

  Future<void> _editItem(int index) async {
    final result = await showDialog<Item>(
      context: context,
      builder: (context) => _ItemFormDialog(item: _inventario[index]),
    );

    if (result != null) {
      setState(() => _inventario[index] = result);
    }
  }

  Future<void> _saveCharacter() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos obrigatórios'),
          backgroundColor: AppTheme.ritualRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final character = Character(
        id: widget.character?.id ?? const Uuid().v4(),
        nome: _nomeController.text,
        patente: _patenteController.text,
        nex: _nex,
        origem: _origemController.text,
        classe: _classe,
        trilha: _trilhaController.text,
        createdBy: widget.createdBy,
        pvAtual: _pvAtual,
        pvMax: _pvMax,
        peAtual: _peAtual,
        peMax: _peMax,
        psAtual: _psAtual,
        psMax: _psMax,
        creditos: _creditos,
        forca: _forca,
        agilidade: _agilidade,
        vigor: _vigor,
        inteligencia: _inteligencia,
        presenca: _presenca,
        iniciativaBase: _iniciativaBase,
        pericias: _pericias,
        poderes: _poderes,
        inventario: _inventario,
      );

      if (widget.character == null) {
        await _dbService.createCharacter(character);
      } else {
        await _dbService.updateCharacter(character);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.character == null ? 'Personagem criado!' : 'Personagem atualizado!'),
            backgroundColor: AppTheme.mutagenGreen,
          ),
        );
        Navigator.pop(context, character);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: AppTheme.ritualRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

// ==================== DIALOG DE PODER ====================
class _PowerFormDialog extends StatefulWidget {
  final Power? power;

  const _PowerFormDialog({this.power});

  @override
  State<_PowerFormDialog> createState() => _PowerFormDialogState();
}

class _PowerFormDialogState extends State<_PowerFormDialog> {
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  String _elemento = 'Energia';

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.power?.nome ?? '');
    _descricaoController = TextEditingController(text: widget.power?.descricao ?? '');
    if (widget.power != null) _elemento = widget.power!.elemento;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.obscureGray, AppTheme.industrialGray],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppTheme.ritualRed.withOpacity(0.4),
              blurRadius: 24,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: AppTheme.ritualRed.withOpacity(0.2),
              blurRadius: 48,
              spreadRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ADICIONAR PODER',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ritualRed,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nomeController,
                style: const TextStyle(color: AppTheme.paleWhite),
                decoration: InputDecoration(
                  labelText: 'Nome do Poder',
                  labelStyle: const TextStyle(color: AppTheme.coldGray),
                  filled: true,
                  fillColor: AppTheme.obscureGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppTheme.ritualRed, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppTheme.coldGray, width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descricaoController,
                style: const TextStyle(color: AppTheme.paleWhite),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  labelStyle: const TextStyle(color: AppTheme.coldGray),
                  filled: true,
                  fillColor: AppTheme.obscureGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppTheme.ritualRed, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppTheme.coldGray, width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _elemento,
                decoration: InputDecoration(
                  labelText: 'Elemento',
                  filled: true,
                  fillColor: AppTheme.obscureGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppTheme.ritualRed, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppTheme.coldGray, width: 1),
                  ),
                ),
                dropdownColor: AppTheme.obscureGray,
                style: const TextStyle(color: AppTheme.paleWhite),
                items: ['Sangue', 'Morte', 'Conhecimento', 'Energia', 'Medo']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _elemento = v!),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: GlowingButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.pop(context),
                      style: GlowingButtonStyle.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlowingButton(
                      label: 'Salvar',
                      icon: Icons.check,
                      onPressed: () {
                        if (_nomeController.text.isEmpty) return;
                        Navigator.pop(
                          context,
                          Power(
                            id: widget.power?.id ?? const Uuid().v4(),
                            nome: _nomeController.text,
                            descricao: _descricaoController.text,
                            elemento: _elemento,
                            habilidades: [],
                          ),
                        );
                      },
                      style: GlowingButtonStyle.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== DIALOG DE ITEM ====================
class _ItemFormDialog extends StatefulWidget {
  final Item? item;

  const _ItemFormDialog({this.item});

  @override
  State<_ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<_ItemFormDialog> {
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _precoController;
  late TextEditingController _espacoController;
  late TextEditingController _quantidadeController;
  String _categoria = 'Equipamento';

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.item?.nome ?? '');
    _descricaoController = TextEditingController(text: widget.item?.descricao ?? '');
    _precoController = TextEditingController(text: widget.item?.preco.toString() ?? '100');
    _espacoController = TextEditingController(text: widget.item?.espaco.toString() ?? '1');
    _quantidadeController = TextEditingController(text: widget.item?.quantidade.toString() ?? '1');
    if (widget.item != null) _categoria = widget.item!.categoria;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _espacoController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.obscureGray, AppTheme.industrialGray],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppTheme.mutagenGreen.withOpacity(0.4),
              blurRadius: 24,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: AppTheme.mutagenGreen.withOpacity(0.2),
              blurRadius: 48,
              spreadRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ADICIONAR ITEM',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.mutagenGreen,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nomeController,
                style: const TextStyle(color: AppTheme.paleWhite),
                decoration: InputDecoration(
                  labelText: 'Nome',
                  filled: true,
                  fillColor: AppTheme.obscureGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppTheme.mutagenGreen, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppTheme.coldGray, width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _categoria,
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  filled: true,
                  fillColor: AppTheme.obscureGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppTheme.mutagenGreen, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppTheme.coldGray, width: 1),
                  ),
                ),
                dropdownColor: AppTheme.obscureGray,
                style: const TextStyle(color: AppTheme.paleWhite),
                items: ['Arma', 'Armadura', 'Equipamento', 'Consumível', 'Paranormal', 'Diversos']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _categoria = v!),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descricaoController,
                style: const TextStyle(color: AppTheme.paleWhite),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  filled: true,
                  fillColor: AppTheme.obscureGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppTheme.mutagenGreen, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppTheme.coldGray, width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precoController,
                      style: const TextStyle(color: AppTheme.paleWhite),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Preço (¢)',
                        filled: true,
                        fillColor: AppTheme.obscureGray,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppTheme.mutagenGreen, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppTheme.coldGray, width: 1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _espacoController,
                      style: const TextStyle(color: AppTheme.paleWhite),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Espaço',
                        filled: true,
                        fillColor: AppTheme.obscureGray,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppTheme.mutagenGreen, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppTheme.coldGray, width: 1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _quantidadeController,
                      style: const TextStyle(color: AppTheme.paleWhite),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Qtd',
                        filled: true,
                        fillColor: AppTheme.obscureGray,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppTheme.mutagenGreen, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppTheme.coldGray, width: 1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: GlowingButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.pop(context),
                      style: GlowingButtonStyle.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlowingButton(
                      label: 'Salvar',
                      icon: Icons.check,
                      onPressed: () {
                        if (_nomeController.text.isEmpty) return;
                        Navigator.pop(
                          context,
                          Item(
                            id: widget.item?.id ?? const Uuid().v4(),
                            nome: _nomeController.text,
                            descricao: _descricaoController.text,
                            quantidade: int.tryParse(_quantidadeController.text) ?? 1,
                            tipo: _categoria,
                            categoria: _categoria,
                            espaco: int.tryParse(_espacoController.text) ?? 1,
                            preco: int.tryParse(_precoController.text) ?? 100,
                          ),
                        );
                      },
                      style: GlowingButtonStyle.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
