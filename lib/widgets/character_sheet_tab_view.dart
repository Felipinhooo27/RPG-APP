import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/character.dart';
import '../core/database/local_storage.dart';
import '../core/database/character_repository.dart';
import '../core/database/item_repository.dart';
import '../core/database/power_repository.dart';
import '../screens/player/inventory_management_screen.dart';
import '../screens/player/powers_management_screen.dart';
import 'hexatombe_ui_components.dart';
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
  final _characterRepo = CharacterRepository();

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

  /// Salva personagem no storage local
  Future<void> _saveCharacter() async {
    await _characterRepo.update(_character);
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
  // TAB 1: STATUS (Design Hexatombe - SEM CAIXAS)
  // ==========================================================================
  Widget _buildStatusTab() {
    return GrungeBackground(
      baseColor: const Color(0xFF0d0d0d),
      opacity: 0.06,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NEX e Patente (SEM caixas, texto hierárquico)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SimpleStat(
                  label: 'NEX',
                  value: '${_character.nex}%',
                  labelColor: AppColors.magenta,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.silver.withOpacity(0.2),
                ),
                SimpleStat(
                  label: 'PATENTE',
                  value: _character.patente ?? 'Recruta',
                  labelColor: AppColors.conhecimentoGreen,
                ),
              ],
            ),

            const SizedBox(height: 32),
            const GrungeDivider(heavy: true),
            const SizedBox(height: 32),

            // PV - Barra de status temática
            HexatombeStatusBar(
              title: 'PONTOS DE VIDA',
              current: _character.pvAtual,
              max: _character.pvMax,
              fillColor: AppColors.pvRed,
              onIncrement: () {
                setState(() {
                  if (_character.pvAtual < _character.pvMax) {
                    _character.pvAtual++;
                    _saveCharacter();
                    widget.onCharacterChanged?.call();
                  }
                });
              },
              onDecrement: () {
                setState(() {
                  if (_character.pvAtual > 0) {
                    _character.pvAtual--;
                    _saveCharacter();
                    widget.onCharacterChanged?.call();
                  }
                });
              },
            ),

            const SizedBox(height: 24),

            // PE
            HexatombeStatusBar(
              title: 'PONTOS DE ESFORÇO',
              current: _character.peAtual,
              max: _character.peMax,
              fillColor: AppColors.pePurple,
              onIncrement: () {
                setState(() {
                  if (_character.peAtual < _character.peMax) {
                    _character.peAtual++;
                    _saveCharacter();
                    widget.onCharacterChanged?.call();
                  }
                });
              },
              onDecrement: () {
                setState(() {
                  if (_character.peAtual > 0) {
                    _character.peAtual--;
                    _saveCharacter();
                    widget.onCharacterChanged?.call();
                  }
                });
              },
            ),

            const SizedBox(height: 24),

            // SAN
            HexatombeStatusBar(
              title: 'SANIDADE',
              current: _character.sanAtual,
              max: _character.sanMax,
              fillColor: AppColors.sanYellow,
              onIncrement: () {
                setState(() {
                  if (_character.sanAtual < _character.sanMax) {
                    _character.sanAtual++;
                    _saveCharacter();
                    widget.onCharacterChanged?.call();
                  }
                });
              },
              onDecrement: () {
                setState(() {
                  if (_character.sanAtual > 0) {
                    _character.sanAtual--;
                    _saveCharacter();
                    widget.onCharacterChanged?.call();
                  }
                });
              },
            ),

            const SizedBox(height: 40),
            const GrungeDivider(heavy: true),
            const SizedBox(height: 32),

            // Stats de combate - Hexágonos temáticos
            const SectionTitle(title: 'COMBATE'),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                HexagonStat(
                  label: 'DEFESA',
                  value: _character.defesa.toString(),
                  color: AppColors.forRed,
                ),
                HexagonStat(
                  label: 'BLOQUEIO',
                  value: _character.bloqueio.toString(),
                  color: AppColors.vigBlue,
                ),
                HexagonStat(
                  label: 'DESL',
                  value: '${_character.deslocamento}m',
                  color: AppColors.agiGreen,
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
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
  // TAB 2: ATRIBUTOS (Runa Paranormal)
  // ==========================================================================
  Widget _buildAtributosTab() {
    return GrungeBackground(
      baseColor: const Color(0xFF0d0d0d),
      opacity: 0.06,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Runa de Atributo (pentágono paranormal)
            Center(
              child: RunaAtributo(
                forca: _character.forca,
                agilidade: _character.agilidade,
                vigor: _character.vigor,
                intelecto: _character.intelecto,
                presenca: _character.presenca,
              ),
            ),

            const SizedBox(height: 40),
            const GrungeDivider(heavy: true),
            const SizedBox(height: 32),

            // Cabeçalho de Lâmina para detalhamento
            const BladeHeader(title: 'DETALHAMENTO'),

            const SizedBox(height: 24),

            // Lista detalhada de atributos (SEM CAIXAS)
            _buildAttributeDetailMinimal('FORÇA', _character.forca, AppColors.forRed, 'Poder físico, dano em combate corpo a corpo'),
            const SizedBox(height: 20),

            _buildAttributeDetailMinimal('AGILIDADE', _character.agilidade, AppColors.agiGreen, 'Reflexos, esquiva, ataques à distância'),
            const SizedBox(height: 20),

            _buildAttributeDetailMinimal('VIGOR', _character.vigor, AppColors.vigBlue, 'Resistência, pontos de vida, fortitude'),
            const SizedBox(height: 20),

            _buildAttributeDetailMinimal('INTELECTO', _character.intelecto, AppColors.intMagenta, 'Raciocínio, investigação, perícias mentais'),
            const SizedBox(height: 20),

            _buildAttributeDetailMinimal('PRESENÇA', _character.presenca, AppColors.preGold, 'Carisma, intimidação, pontos de esforço'),

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

  // Versão minimal SEM CAIXAS para atributos
  Widget _buildAttributeDetailMinimal(String label, int value, Color color, String description) {
    final modifier = value >= 0 ? '+$value' : '$value';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label do atributo (pequeno, colorido)
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.5,
            color: color,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 6),

        // Linha com valor grande + modificador + descrição
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Valor grande
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.0,
              ),
            ),

            const SizedBox(width: 16),

            // Modificador + Descrição
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // Modificador
                  Text(
                    'MOD: $modifier',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: color.withOpacity(0.8),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Descrição
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888888),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Linha divisória grunge
        Container(
          height: 1,
          color: color.withOpacity(0.2),
        ),
      ],
    );
  }

  // ==========================================================================
  // TAB 3: PERÍCIAS (Refatorado - Apenas Treinadas)
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

    // Filtra apenas perícias treinadas
    final periciasTreinadas = pericias.entries
        .where((entry) => _character.periciasTreinadas.contains(entry.key))
        .toList();

    return GrungeBackground(
      baseColor: const Color(0xFF0d0d0d),
      opacity: 0.06,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título da seção
            const SectionTitle(
              title: 'PERÍCIAS TREINADAS',
              color: AppColors.conhecimentoGreen,
            ),

            const SizedBox(height: 8),

            // Lista de perícias treinadas (SEM CAIXAS)
            if (periciasTreinadas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'Nenhuma perícia treinada',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.silver.withOpacity(0.5),
                    ),
                  ),
                ),
              )
            else
              ...periciasTreinadas.map((entry) {
                final nome = entry.key;
                final bonus = entry.value['bonus'] as int;
                final bonusTreinada = 5;
                final total = bonus + bonusTreinada;
                final attr = entry.value['attr'] as String;
                final attrColor = _getAttrColor(attr);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Linha principal: Nome + Badge + Bônus
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        // Nome da perícia
                        Expanded(
                          child: Text(
                            nome.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Color(0xFFe0e0e0),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),

                        // Badge de atributo (sem caixa, apenas texto)
                        Text(
                          attr,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: attrColor,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Bônus total (vermelho-sangue para destaque)
                        Text(
                          total >= 0 ? '+$total' : '$total',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.scarletRed,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Linha de modificadores (opcional)
                    Text(
                      'Modificadores: ${bonus >= 0 ? '+$bonus' : '$bonus'} ($attr), +$bonusTreinada (Treino)',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF888888),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Divisor
                    Container(
                      height: 1,
                      color: AppColors.conhecimentoGreen.withOpacity(0.2),
                    ),
                  ],
                );
              }).toList(),

            const SizedBox(height: 32),

            // Botão "Treinar Nova Perícia"
            Center(
              child: InkWell(
                onTap: () {
                  // TODO: Abrir modal de seleção de perícias
                  _showTrainSkillDialog(pericias);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '[ + TREINAR NOVA PERÍCIA ]',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: AppColors.scarletRed,
                      fontFamily: 'monospace',
                      shadows: [
                        Shadow(
                          color: AppColors.scarletRed.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Modal para treinar nova perícia
  void _showTrainSkillDialog(Map<String, Map<String, dynamic>> pericias) {
    // Lista de perícias disponíveis (não treinadas)
    final disponiveisParaTreino = pericias.entries
        .where((entry) => !_character.periciasTreinadas.contains(entry.key))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.deepBlack,
        title: Text(
          'TREINAR NOVA PERÍCIA',
          style: TextStyle(
            color: AppColors.conhecimentoGreen,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: disponiveisParaTreino.map((entry) {
              final nome = entry.key;
              final attr = entry.value['attr'] as String;

              return InkWell(
                onTap: () {
                  setState(() {
                    _character.periciasTreinadas.add(nome);
                    _saveCharacter();
                  });
                  Navigator.of(context).pop();
                  widget.onCharacterChanged?.call();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.silver.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          nome,
                          style: const TextStyle(
                            color: Color(0xFFe0e0e0),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        attr,
                        style: TextStyle(
                          color: _getAttrColor(attr),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCELAR'),
          ),
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
  // TAB 4: OUTROS (Arquivo do Agente - Refatorado)
  // ==========================================================================
  Widget _buildOutrosTab() {
    return GrungeBackground(
      baseColor: const Color(0xFF0d0d0d),
      opacity: 0.06,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item de navegação: Inventário
            ArchiveListItem(
              icon: Icons.inventory_2,
              title: 'INVENTÁRIO',
              subtitle: 'Gerencie seus itens, armas e equipamentos',
              count: _character.inventarioIds.length,
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
            ),

            const SizedBox(height: 8),
            const GrungeDivider(heavy: true),
            const SizedBox(height: 8),

            // Item de navegação: Poderes
            ArchiveListItem(
              icon: Icons.auto_awesome,
              title: 'PODERES E RITUAIS',
              subtitle: 'Gerencie suas habilidades paranormais',
              count: _character.poderesIds.length,
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
            ),

            const SizedBox(height: 8),
            const GrungeDivider(heavy: true),
            const SizedBox(height: 32),

            // Seção de Habilidades de Classe
            const SectionTitle(
              title: 'HABILIDADES DE CLASSE',
              color: AppColors.conhecimentoGreen,
            ),

            const SizedBox(height: 20),

            // Lista de habilidades (SEM CAIXAS)
            ..._getClasseHabilidades().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: DossierEntry(
                  title: entry.key.toUpperCase(),
                  description: entry.value,
                  titleColor: AppColors.conhecimentoGreen,
                ),
              );
            }).toList(),

            const SizedBox(height: 24),
          ],
        ),
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
