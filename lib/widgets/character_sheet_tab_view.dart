import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/character.dart';
import '../core/database/local_storage.dart';
import '../core/database/item_repository.dart';
import '../core/database/power_repository.dart';
import '../screens/player/inventory_management_screen.dart';
import '../screens/player/powers_management_screen.dart';
import 'dart:math' as math;

/// Widget de visualização da ficha do personagem com abas
/// Contém: STATUS | ATRIBUTOS | PERÍCIAS | OUTROS
class CharacterSheetTabView extends StatefulWidget {
  final Character character;
  final VoidCallback? onCharacterChanged;

  const CharacterSheetTabView({
    super.key,
    required this.character,
    this.onCharacterChanged,
  });

  @override
  State<CharacterSheetTabView> createState() => _CharacterSheetTabViewState();
}

class _CharacterSheetTabViewState extends State<CharacterSheetTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Character _character;

  @override
  void initState() {
    super.initState();
    _character = widget.character;
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildStatusTab(),
              _buildAtributosTab(),
              _buildPericiasTab(),
              _buildOutrosTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border(
          bottom: BorderSide(color: AppColors.scarletRed.withOpacity(0.3)),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.scarletRed,
        indicatorWeight: 3,
        labelColor: AppColors.scarletRed,
        unselectedLabelColor: AppColors.silver.withOpacity(0.5),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        tabs: const [
          Tab(text: 'STATUS'),
          Tab(text: 'ATRIBUTOS'),
          Tab(text: 'PERÍCIAS'),
          Tab(text: 'OUTROS'),
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 1: STATUS (PV/PE/SAN com controles)
  // ==========================================================================
  Widget _buildStatusTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NEX e Patente
          Row(
            children: [
              Expanded(
                child: _buildInfoCard('NEX', '${_character.nex}%', AppColors.magenta),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard('PATENTE', 'Recruta', AppColors.conhecimentoGreen),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // PV
          _buildResourceSection(
            label: 'PONTOS DE VIDA',
            current: _character.pvAtual,
            max: _character.pvMax,
            color: AppColors.pvRed,
            onIncrement: () {
              setState(() {
                if (_character.pvAtual < _character.pvMax) {
                  _character.pvAtual++;
                  widget.onCharacterChanged?.call();
                }
              });
            },
            onDecrement: () {
              setState(() {
                if (_character.pvAtual > 0) {
                  _character.pvAtual--;
                  widget.onCharacterChanged?.call();
                }
              });
            },
          ),

          const SizedBox(height: 24),

          // PE
          _buildResourceSection(
            label: 'PONTOS DE ESFORÇO',
            current: _character.peAtual,
            max: _character.peMax,
            color: AppColors.pePurple,
            onIncrement: () {
              setState(() {
                if (_character.peAtual < _character.peMax) {
                  _character.peAtual++;
                  widget.onCharacterChanged?.call();
                }
              });
            },
            onDecrement: () {
              setState(() {
                if (_character.peAtual > 0) {
                  _character.peAtual--;
                  widget.onCharacterChanged?.call();
                }
              });
            },
          ),

          const SizedBox(height: 24),

          // SAN
          _buildResourceSection(
            label: 'SANIDADE',
            current: _character.sanAtual,
            max: _character.sanMax,
            color: AppColors.sanYellow,
            onIncrement: () {
              setState(() {
                if (_character.sanAtual < _character.sanMax) {
                  _character.sanAtual++;
                  widget.onCharacterChanged?.call();
                }
              });
            },
            onDecrement: () {
              setState(() {
                if (_character.sanAtual > 0) {
                  _character.sanAtual--;
                  widget.onCharacterChanged?.call();
                }
              });
            },
          ),

          const SizedBox(height: 32),

          // Stats de combate
          Text('COMBATE', style: AppTextStyles.title),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatCard('DEFESA', _character.defesa.toString(), AppColors.forRed),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('BLOQUEIO', _character.bloqueio.toString(), AppColors.vigBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('DESL', _character.deslocamento.toString(), AppColors.agiGreen),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.uppercase.copyWith(
              fontSize: 10,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.title.copyWith(
              fontSize: 24,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceSection({
    required String label,
    required int current,
    required int max,
    required Color color,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    final percentage = current / max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.uppercase.copyWith(
            fontSize: 12,
            color: color,
          ),
        ),
        const SizedBox(height: 12),

        // Barra
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            border: Border.all(color: color, width: 2),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage.clamp(0.0, 1.0),
                child: Container(color: color.withOpacity(0.3)),
              ),
              Center(
                child: Text(
                  '$current / $max',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Controles
        Row(
          children: [
            Expanded(
              child: _buildControlButton('-', onDecrement, color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildControlButton('+', onIncrement, color),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton(String label, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          border: Border.all(color: color),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 2: ATRIBUTOS (Display hexagonal)
  // ==========================================================================
  Widget _buildAtributosTab() {
    return Container(
      color: AppColors.deepBlack,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título da seção
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'ATRIBUTOS',
                    style: AppTextStyles.uppercase.copyWith(
                      fontSize: 20,
                      color: AppColors.scarletRed,
                      letterSpacing: 3.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 2,
                    width: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.scarletRed,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Display hexagonal dos atributos (maior)
            Center(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.scarletRed.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 340,
                  height: 340,
                  child: CustomPaint(
                    painter: HexagonalAttributesPainter(
                      forca: _character.forca,
                      agilidade: _character.agilidade,
                      vigor: _character.vigor,
                      intelecto: _character.intelecto,
                      presenca: _character.presenca,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Info sobre atributos
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.scarletRed.withOpacity(0.1),
                border: Border.all(color: AppColors.scarletRed.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.scarletRed, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Os atributos determinam suas capacidades e modificam seus testes',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.silver,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Divisor
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.scarletRed.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'DETALHAMENTO',
                    style: AppTextStyles.uppercase.copyWith(
                      fontSize: 10,
                      color: AppColors.scarletRed,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.scarletRed.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Lista detalhada de atributos
            _buildAttributeDetail('FORÇA', _character.forca, AppColors.forRed, Icons.fitness_center),
            _buildAttributeDetail('AGILIDADE', _character.agilidade, AppColors.agiGreen, Icons.directions_run),
            _buildAttributeDetail('VIGOR', _character.vigor, AppColors.vigBlue, Icons.favorite),
            _buildAttributeDetail('INTELECTO', _character.intelecto, AppColors.intMagenta, Icons.psychology),
            _buildAttributeDetail('PRESENÇA', _character.presenca, AppColors.preGold, Icons.group),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeDetail(String label, int value, Color color, IconData icon) {
    final modifier = value >= 0 ? '+$value' : '$value';

    // Descrições dos atributos
    final descriptions = {
      'FORÇA': 'Poder físico, dano em combate corpo a corpo',
      'AGILIDADE': 'Reflexos, esquiva, ataques à distância',
      'VIGOR': 'Resistência, pontos de vida, fortitude',
      'INTELECTO': 'Raciocínio, investigação, perícias mentais',
      'PRESENÇA': 'Carisma, intimidação, pontos de esforço',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.deepBlack,
        border: Border(
          left: BorderSide(color: color, width: 6),
          top: BorderSide(color: color.withOpacity(0.3), width: 1),
          right: BorderSide(color: color.withOpacity(0.3), width: 1),
          bottom: BorderSide(color: color.withOpacity(0.3), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Círculo com ícone
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.15),
                border: Border.all(color: color, width: 2.5),
              ),
              child: Icon(icon, color: color, size: 28),
            ),

            const SizedBox(width: 20),

            // Informações do atributo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.uppercase.copyWith(
                      fontSize: 16,
                      color: color,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    descriptions[label] ?? '',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.silver.withOpacity(0.7),
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          border: Border.all(color: color, width: 1),
                        ),
                        child: Text(
                          'MODIFICADOR: $modifier',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Valor grande
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                border: Border.all(color: color, width: 2.5),
              ),
              child: Center(
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // TAB 3: PERÍCIAS (COMPLETO)
  // ==========================================================================
  Widget _buildPericiasTab() {
    // Perícias padrão de Ordem Paranormal
    final pericias = {
      'Acrobacia': {'attr': 'AGI', 'bonus': _character.agilidade},
      'Adestramento': {'attr': 'PRE', 'bonus': _character.presenca},
      'Artes': {'attr': 'PRE', 'bonus': _character.presenca},
      'Atletismo': {'attr': 'FOR', 'bonus': _character.forca},
      'Atualidades': {'attr': 'INT', 'bonus': _character.intelecto},
      'Ciências': {'attr': 'INT', 'bonus': _character.intelecto},
      'Crime': {'attr': 'AGI', 'bonus': _character.agilidade},
      'Diplomacia': {'attr': 'PRE', 'bonus': _character.presenca},
      'Enganação': {'attr': 'PRE', 'bonus': _character.presenca},
      'Fortitude': {'attr': 'VIG', 'bonus': _character.vigor},
      'Furtividade': {'attr': 'AGI', 'bonus': _character.agilidade},
      'Iniciativa': {'attr': 'AGI', 'bonus': _character.agilidade},
      'Intimidação': {'attr': 'PRE', 'bonus': _character.presenca},
      'Intuição': {'attr': 'PRE', 'bonus': _character.presenca},
      'Investigação': {'attr': 'INT', 'bonus': _character.intelecto},
      'Luta': {'attr': 'FOR', 'bonus': _character.forca},
      'Medicina': {'attr': 'INT', 'bonus': _character.intelecto},
      'Ocultismo': {'attr': 'INT', 'bonus': _character.intelecto},
      'Percepção': {'attr': 'PRE', 'bonus': _character.presenca},
      'Pilotagem': {'attr': 'AGI', 'bonus': _character.agilidade},
      'Pontaria': {'attr': 'AGI', 'bonus': _character.agilidade},
      'Profissão': {'attr': 'INT', 'bonus': _character.intelecto},
      'Reflexos': {'attr': 'AGI', 'bonus': _character.agilidade},
      'Religião': {'attr': 'PRE', 'bonus': _character.presenca},
      'Sobrevivência': {'attr': 'INT', 'bonus': _character.intelecto},
      'Tática': {'attr': 'INT', 'bonus': _character.intelecto},
      'Tecnologia': {'attr': 'INT', 'bonus': _character.intelecto},
      'Vontade': {'attr': 'PRE', 'bonus': _character.presenca},
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.conhecimentoGreen.withOpacity(0.1),
              border: Border.all(color: AppColors.conhecimentoGreen),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.conhecimentoGreen, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Perícias treinadas ganham +5 de bônus. Para treinar novas perícias, edite a ficha do personagem.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.conhecimentoGreen,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de perícias
          ...pericias.entries.map((entry) {
            final nome = entry.key;
            final isTreinada = _character.periciasTreinadas.contains(nome);
            final bonus = entry.value['bonus'] as int;
            final bonusTreinada = isTreinada ? 5 : 0;
            final total = bonus + bonusTreinada;
            final attr = entry.value['attr'] as String;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isTreinada ? AppColors.conhecimentoGreen.withOpacity(0.1) : AppColors.darkGray,
                border: Border.all(
                  color: isTreinada ? AppColors.conhecimentoGreen : AppColors.silver.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  // Checkbox (read-only)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isTreinada ? AppColors.conhecimentoGreen : Colors.transparent,
                      border: Border.all(
                        color: isTreinada ? AppColors.conhecimentoGreen : AppColors.silver.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: isTreinada
                        ? const Icon(Icons.check, color: AppColors.deepBlack, size: 16)
                        : null,
                  ),

                  const SizedBox(width: 12),

                  // Nome
                  Expanded(
                    child: Text(
                      nome.toUpperCase(),
                      style: AppTextStyles.uppercase.copyWith(
                        fontSize: 11,
                        color: isTreinada ? AppColors.conhecimentoGreen : AppColors.silver,
                      ),
                    ),
                  ),

                  // Atributo
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getAttrColor(attr).withOpacity(0.2),
                      border: Border.all(color: _getAttrColor(attr)),
                    ),
                    child: Text(
                      attr,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: _getAttrColor(attr),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Bônus total
                  Text(
                    total >= 0 ? '+$total' : '$total',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isTreinada ? AppColors.conhecimentoGreen : AppColors.silver,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
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

  // ==========================================================================
  // TAB 4: OUTROS (Inventário e Poderes)
  // ==========================================================================
  Widget _buildOutrosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inventário
          _buildInventarioSection(),
          const SizedBox(height: 32),

          // Poderes
          _buildPoderesSection(),
          const SizedBox(height: 32),

          // Habilidades de Classe
          _buildHabilidadesSection(),
        ],
      ),
    );
  }

  Widget _buildInventarioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.inventory_2, color: AppColors.energiaYellow, size: 20),
            const SizedBox(width: 8),
            Text('INVENTÁRIO', style: AppTextStyles.title.copyWith(color: AppColors.energiaYellow)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.energiaYellow.withOpacity(0.2),
                border: Border.all(color: AppColors.energiaYellow),
              ),
              child: Text(
                '${_character.inventarioIds.length} ITENS',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppColors.energiaYellow,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Botão para acessar inventário completo
        InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InventoryManagementScreen(character: _character),
              ),
            );
            if (result == true && mounted) {
              setState(() {});
              widget.onCharacterChanged?.call();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.energiaYellow),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.open_in_new, color: AppColors.energiaYellow, size: 16),
                const SizedBox(width: 8),
                Text(
                  'GERENCIAR INVENTÁRIO COMPLETO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.energiaYellow,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        _character.inventarioIds.isEmpty
            ? _buildEmptyState('Nenhum item no inventário', Icons.inventory)
            : FutureBuilder<List<dynamic>>(
                future: _loadItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.energiaYellow),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState('Nenhum item encontrado', Icons.inventory);
                  }

                  return Column(
                    children: snapshot.data!.map((item) => _buildItemCard(item)).toList(),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildPoderesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.medoPurple, size: 20),
            const SizedBox(width: 8),
            Text('PODERES E RITUAIS', style: AppTextStyles.title.copyWith(color: AppColors.medoPurple)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.medoPurple.withOpacity(0.2),
                border: Border.all(color: AppColors.medoPurple),
              ),
              child: Text(
                '${_character.poderesIds.length} PODERES',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppColors.medoPurple,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Botão para acessar poderes completo
        InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PowersManagementScreen(character: _character),
              ),
            );
            if (result == true && mounted) {
              setState(() {});
              widget.onCharacterChanged?.call();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.medoPurple),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.open_in_new, color: AppColors.medoPurple, size: 16),
                const SizedBox(width: 8),
                Text(
                  'GERENCIAR PODERES E RITUAIS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.medoPurple,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        _character.poderesIds.isEmpty
            ? _buildEmptyState('Nenhum poder aprendido', Icons.auto_awesome)
            : FutureBuilder<List<dynamic>>(
                future: _loadPowers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.medoPurple),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState('Nenhum poder encontrado', Icons.auto_awesome);
                  }

                  return Column(
                    children: snapshot.data!.map((power) => _buildPowerCard(power)).toList(),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildHabilidadesSection() {
    final habilidades = _getClasseHabilidades();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: AppColors.conhecimentoGreen, size: 20),
            const SizedBox(width: 8),
            Text('HABILIDADES DE CLASSE', style: AppTextStyles.title.copyWith(color: AppColors.conhecimentoGreen)),
          ],
        ),
        const SizedBox(height: 16),
        ...habilidades.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkGray,
              border: Border(
                left: BorderSide(color: AppColors.conhecimentoGreen, width: 4),
                top: BorderSide(color: AppColors.silver.withOpacity(0.3)),
                right: BorderSide(color: AppColors.silver.withOpacity(0.3)),
                bottom: BorderSide(color: AppColors.silver.withOpacity(0.3)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key.toUpperCase(),
                  style: AppTextStyles.uppercase.copyWith(
                    fontSize: 12,
                    color: AppColors.conhecimentoGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.value,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.silver.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border.all(color: AppColors.silver.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppColors.silver.withOpacity(0.3)),
            const SizedBox(height: 12),
            Text(
              message.toUpperCase(),
              style: AppTextStyles.uppercase.copyWith(
                color: AppColors.silver.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(dynamic itemJson) {
    final nome = itemJson['nome'] as String? ?? 'Item Desconhecido';
    final descricao = itemJson['descricao'] as String? ?? '';
    final tipo = itemJson['tipo'] as String? ?? 'equipamento';
    final quantidade = itemJson['quantidade'] as int? ?? 1;
    final espaco = itemJson['espaco'] as int? ?? 1;

    final tipoColor = _getItemTypeColor(tipo);
    final tipoLabel = _getItemTypeLabel(tipo);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border(
          left: BorderSide(color: tipoColor, width: 4),
          top: BorderSide(color: AppColors.silver.withOpacity(0.3)),
          right: BorderSide(color: AppColors.silver.withOpacity(0.3)),
          bottom: BorderSide(color: AppColors.silver.withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tipoColor.withOpacity(0.2),
                  border: Border.all(color: tipoColor),
                ),
                child: Text(
                  tipoLabel,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: tipoColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'QTD: $quantidade',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.silver.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.inventory_2, size: 14, color: AppColors.silver.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text(
                '${espaco * quantidade}',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.silver.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            nome.toUpperCase(),
            style: AppTextStyles.uppercase.copyWith(
              fontSize: 13,
              color: AppColors.lightGray,
            ),
          ),
          if (descricao.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              descricao,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.silver.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPowerCard(dynamic powerJson) {
    final nome = powerJson['nome'] as String? ?? 'Poder Desconhecido';
    final descricao = powerJson['descricao'] as String? ?? '';
    final elemento = powerJson['elemento'] as String? ?? 'conhecimento';
    final custoPE = powerJson['custoPE'] as int? ?? 0;
    final circulo = powerJson['circulo'] as int?;

    final elementoColor = _getElementoColor(elemento);
    final elementoLabel = _getElementoLabel(elemento);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border(
          left: BorderSide(color: elementoColor, width: 4),
          top: BorderSide(color: AppColors.silver.withOpacity(0.3)),
          right: BorderSide(color: AppColors.silver.withOpacity(0.3)),
          bottom: BorderSide(color: AppColors.silver.withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: elementoColor.withOpacity(0.2),
                  border: Border.all(color: elementoColor),
                ),
                child: Text(
                  elementoLabel,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: elementoColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              if (circulo != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.medoPurple.withOpacity(0.2),
                    border: Border.all(color: AppColors.medoPurple),
                  ),
                  child: Text(
                    '$circuloº CÍRCULO',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: AppColors.medoPurple,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Icon(Icons.flash_on, size: 14, color: AppColors.energiaYellow),
              const SizedBox(width: 4),
              Text(
                '$custoPE PE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.energiaYellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            nome.toUpperCase(),
            style: AppTextStyles.uppercase.copyWith(
              fontSize: 13,
              color: AppColors.lightGray,
            ),
          ),
          if (descricao.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              descricao,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.silver.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<List<dynamic>> _loadItems() async {
    final itemRepo = ItemRepository();
    final items = await itemRepo.getByCharacterId(_character.id);
    // Converte Items para JSON para manter compatibilidade com _buildItemCard
    return items.map((item) => {
      'id': item.id,
      'nome': item.nome,
      'descricao': item.descricao,
      'tipo': item.tipo,
      'quantidade': item.quantidade,
      'espaco': item.espaco,
    }).toList();
  }

  Future<List<dynamic>> _loadPowers() async {
    final powerRepo = PowerRepository();
    final powers = await powerRepo.getByCharacterId(_character.id);
    // Converte Powers para JSON para manter compatibilidade com _buildPowerCard
    return powers.map((power) => {
      'id': power.id,
      'nome': power.nome,
      'descricao': power.descricao,
      'elemento': power.elemento,
      'custoPE': power.custoPE,
      'circulo': power.circulo,
    }).toList();
  }

  Map<String, String> _getClasseHabilidades() {
    switch (_character.classe) {
      case CharacterClass.combatente:
        return {
          'Ataque Especial': 'Você pode realizar ataques especiais com armas corpo a corpo e à distância.',
          'Durão': 'Seu PV máximo aumenta em +4 por NEX.',
          'Manha': 'Escolha duas perícias (exceto Luta ou Pontaria). Você pode usar essas perícias com AGI ao invés do atributo normal.',
        };
      case CharacterClass.especialista:
        return {
          'Perito': 'Escolha um número de perícias treinadas igual a sua Inteligência (mínimo 1). Você recebe +5 de bônus nessas perícias.',
          'Engenhoso': 'Uma vez por rodada, você pode gastar 2 PE para realizar uma ação padrão adicional.',
          'Sortudo': 'Você recebe +2 PE por NEX.',
        };
      case CharacterClass.ocultista:
        return {
          'Potencial Paranormal': 'Você pode conjurar rituais.',
          'Sensitivo': 'Você começa com +5 pontos de esforço.',
          'Conexão Paranormal': 'Escolha um elemento. Você recebe +1 PE por NEX associado a esse elemento.',
        };
    }
  }

  Color _getItemTypeColor(String tipo) {
    switch (tipo) {
      case 'arma':
        return AppColors.sangueRed;
      case 'cura':
        return AppColors.conhecimentoGreen;
      case 'municao':
        return AppColors.energiaYellow;
      case 'equipamento':
        return AppColors.silver;
      case 'consumivel':
        return AppColors.medoPurple;
      default:
        return AppColors.silver;
    }
  }

  String _getItemTypeLabel(String tipo) {
    switch (tipo) {
      case 'arma':
        return 'ARMA';
      case 'cura':
        return 'CURA';
      case 'municao':
        return 'MUNIÇÃO';
      case 'equipamento':
        return 'EQUIPAMENTO';
      case 'consumivel':
        return 'CONSUMÍVEL';
      default:
        return tipo.toUpperCase();
    }
  }

  Color _getElementoColor(String elemento) {
    switch (elemento) {
      case 'conhecimento':
        return AppColors.conhecimentoGreen;
      case 'energia':
        return AppColors.energiaYellow;
      case 'morte':
        return AppColors.silver;
      case 'sangue':
        return AppColors.sangueRed;
      case 'medo':
        return AppColors.medoPurple;
      default:
        return AppColors.silver;
    }
  }

  String _getElementoLabel(String elemento) {
    switch (elemento) {
      case 'conhecimento':
        return 'CONHECIMENTO';
      case 'energia':
        return 'ENERGIA';
      case 'morte':
        return 'MORTE';
      case 'sangue':
        return 'SANGUE';
      case 'medo':
        return 'MEDO';
      default:
        return elemento.toUpperCase();
    }
  }
}

// =============================================================================
// CUSTOM PAINTER: Hexagonal Attributes Display
// =============================================================================
class HexagonalAttributesPainter extends CustomPainter {
  final int forca;
  final int agilidade;
  final int vigor;
  final int intelecto;
  final int presenca;

  HexagonalAttributesPainter({
    required this.forca,
    required this.agilidade,
    required this.vigor,
    required this.intelecto,
    required this.presenca,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    // Desenha grade hexagonal de fundo
    _drawHexagonalGrid(canvas, center, radius);

    // Desenha polígono de atributos
    _drawAttributesPolygon(canvas, center, radius);

    // Desenha símbolo central
    _drawCentralSymbol(canvas, center);

    // Desenha labels e valores
    _drawLabels(canvas, center, radius);
  }

  void _drawCentralSymbol(Canvas canvas, Offset center) {
    // Círculo externo (glow vermelho)
    canvas.drawCircle(
      center,
      32,
      Paint()
        ..color = AppColors.scarletRed.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Círculo de fundo
    canvas.drawCircle(
      center,
      28,
      Paint()..color = AppColors.deepBlack,
    );

    // Círculo de borda principal
    canvas.drawCircle(
      center,
      28,
      Paint()
        ..color = AppColors.scarletRed
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Círculo interno menor
    canvas.drawCircle(
      center,
      20,
      Paint()
        ..color = AppColors.scarletRed.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Desenha símbolo do Outro Lado (estrela de 5 pontas)
    final symbolPath = Path();
    final symbolRadius = 14.0;

    for (int i = 0; i < 5; i++) {
      // Pontas externas
      final angle1 = -math.pi / 2 + (2 * math.pi * i / 5);
      final outerPoint = Offset(
        center.dx + symbolRadius * math.cos(angle1),
        center.dy + symbolRadius * math.sin(angle1),
      );

      // Pontas internas
      final angle2 = angle1 + (math.pi / 5);
      final innerPoint = Offset(
        center.dx + (symbolRadius * 0.4) * math.cos(angle2),
        center.dy + (symbolRadius * 0.4) * math.sin(angle2),
      );

      if (i == 0) {
        symbolPath.moveTo(outerPoint.dx, outerPoint.dy);
      } else {
        symbolPath.lineTo(outerPoint.dx, outerPoint.dy);
      }
      symbolPath.lineTo(innerPoint.dx, innerPoint.dy);
    }
    symbolPath.close();

    // Preenche a estrela
    canvas.drawPath(
      symbolPath,
      Paint()..color = AppColors.scarletRed.withOpacity(0.6),
    );

    // Contorno da estrela
    canvas.drawPath(
      symbolPath,
      Paint()
        ..color = AppColors.scarletRed
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Ponto central
    canvas.drawCircle(
      center,
      3,
      Paint()..color = AppColors.scarletRed,
    );
  }

  void _drawHexagonalGrid(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppColors.scarletRed.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Desenha 5 níveis (0-5)
    for (int level = 1; level <= 5; level++) {
      final levelRadius = radius * (level / 5);
      final path = _createHexagonPath(center, levelRadius);
      canvas.drawPath(path, paint);
    }

    // Desenha linhas radiais (6 linhas para hexágono)
    final radialPaint = Paint()
      ..color = AppColors.scarletRed.withOpacity(0.15)
      ..strokeWidth = 1.5;

    for (int i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / 6);
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, end, radialPaint);
    }
  }

  void _drawAttributesPolygon(Canvas canvas, Offset center, double radius) {
    // Distribuição dos atributos no hexágono (6 posições, usando 5)
    // Posições: AGI(0-topo), INT(1-sup.dir), PRE(2-inf.dir), VIG(4-inf.esq), FOR(5-sup.esq)
    final attributePositions = [
      {'attr': agilidade, 'color': AppColors.agiGreen, 'index': 0},
      {'attr': intelecto, 'color': AppColors.intMagenta, 'index': 1},
      {'attr': presenca, 'color': AppColors.preGold, 'index': 2},
      {'attr': vigor, 'color': AppColors.vigBlue, 'index': 4},
      {'attr': forca, 'color': AppColors.forRed, 'index': 5},
    ];

    final path = Path();
    bool firstPoint = true;

    // Desenha polígono conectando os atributos
    for (var attrData in attributePositions) {
      final value = ((attrData['attr'] as int) + 1).clamp(0, 6); // -1 a 5 → 0 a 6
      final index = attrData['index'] as int;
      final angle = -math.pi / 2 + (2 * math.pi * index / 6);
      final distance = radius * (value / 6);

      final point = Offset(
        center.dx + distance * math.cos(angle),
        center.dy + distance * math.sin(angle),
      );

      if (firstPoint) {
        path.moveTo(point.dx, point.dy);
        firstPoint = false;
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    // Preenche polígono com gradiente
    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.scarletRed.withOpacity(0.3),
          AppColors.scarletRed.withOpacity(0.1),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Contorno do polígono
    final strokePaint = Paint()
      ..color = AppColors.scarletRed.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(path, strokePaint);

    // Desenha círculos dos atributos (maiores e mais destacados)
    for (var attrData in attributePositions) {
      final value = ((attrData['attr'] as int) + 1).clamp(0, 6);
      final index = attrData['index'] as int;
      final color = attrData['color'] as Color;
      final angle = -math.pi / 2 + (2 * math.pi * index / 6);
      final distance = radius * (value / 6);

      final point = Offset(
        center.dx + distance * math.cos(angle),
        center.dy + distance * math.sin(angle),
      );

      // Círculo externo (glow)
      canvas.drawCircle(
        point,
        10,
        Paint()..color = color.withOpacity(0.3),
      );

      // Círculo principal
      canvas.drawCircle(
        point,
        7,
        Paint()..color = color,
      );

      // Círculo interno (destaque)
      canvas.drawCircle(
        point,
        3,
        Paint()..color = AppColors.deepBlack,
      );
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double radius) {
    // Mesma distribuição do hexágono
    final labelData = [
      {'label': 'AGI', 'value': agilidade, 'color': AppColors.agiGreen, 'index': 0},
      {'label': 'INT', 'value': intelecto, 'color': AppColors.intMagenta, 'index': 1},
      {'label': 'PRE', 'value': presenca, 'color': AppColors.preGold, 'index': 2},
      {'label': 'VIG', 'value': vigor, 'color': AppColors.vigBlue, 'index': 4},
      {'label': 'FOR', 'value': forca, 'color': AppColors.forRed, 'index': 5},
    ];

    for (var data in labelData) {
      final index = data['index'] as int;
      final angle = -math.pi / 2 + (2 * math.pi * index / 6);
      final labelRadius = radius + 40;

      final labelPos = Offset(
        center.dx + labelRadius * math.cos(angle),
        center.dy + labelRadius * math.sin(angle),
      );

      final color = data['color'] as Color;
      final label = data['label'] as String;
      final value = data['value'] as int;

      // Círculo de fundo para label
      canvas.drawCircle(
        labelPos,
        24,
        Paint()..color = AppColors.deepBlack.withOpacity(0.8),
      );

      canvas.drawCircle(
        labelPos,
        24,
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Label (nome do atributo)
      final labelPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(labelPos.dx - labelPainter.width / 2, labelPos.dy - 14),
      );

      // Valor do atributo
      final modifier = value >= 0 ? '+$value' : '$value';
      final valuePainter = TextPainter(
        text: TextSpan(
          text: modifier,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      valuePainter.layout();
      valuePainter.paint(
        canvas,
        Offset(labelPos.dx - valuePainter.width / 2, labelPos.dy + 2),
      );
    }
  }

  Path _createHexagonPath(Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / 6);
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant HexagonalAttributesPainter oldDelegate) {
    return forca != oldDelegate.forca ||
        agilidade != oldDelegate.agilidade ||
        vigor != oldDelegate.vigor ||
        intelecto != oldDelegate.intelecto ||
        presenca != oldDelegate.presenca;
  }
}
