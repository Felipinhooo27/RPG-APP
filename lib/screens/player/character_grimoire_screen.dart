import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/character.dart';
import '../../core/database/character_repository.dart';
import '../../core/database/item_repository.dart';
import '../../core/database/power_repository.dart';
import '../../core/database/local_storage.dart';
import '../../widgets/hexatombe_ui_components.dart';
import 'inventory_management_screen.dart';
import 'powers_management_screen.dart';
import 'dart:math' as math;

/// @deprecated Esta tela foi substituída pelo widget CharacterSheetTabView
/// que agora é exibido diretamente na aba PERSONAGENS do PlayerHomeScreen.
/// Mantido apenas para referência.
///
/// Ficha Completa do Personagem (Grimório)
/// 4 abas: STATUS | ATRIBUTOS | PERÍCIAS | OUTROS
@Deprecated('Use CharacterSheetTabView dentro do PlayerHomeScreen')
class CharacterGrimoireScreen extends StatefulWidget {
  final Character character;

  const CharacterGrimoireScreen({
    super.key,
    required this.character,
  });

  @override
  State<CharacterGrimoireScreen> createState() =>
      _CharacterGrimoireScreenState();
}

class _CharacterGrimoireScreenState extends State<CharacterGrimoireScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Character _character;
  final CharacterRepository _repo = CharacterRepository();

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

  Future<void> _saveCharacter() async {
    try {
      await _repo.update(_character);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Personagem salvo!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: _buildAppBar(),
      body: Column(
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.deepBlack,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.silver),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _character.nome.toUpperCase(),
            style: AppTextStyles.uppercase.copyWith(
              fontSize: 16,
              color: AppColors.scarletRed,
            ),
          ),
          Text(
            '${_character.classe.name.toUpperCase()} • ${_character.origem.name.toUpperCase()}',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 9,
              color: AppColors.silver,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.save, color: AppColors.conhecimentoGreen),
          onPressed: _saveCharacter,
          tooltip: 'Salvar alterações',
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
          // NEX e Patente (SEM CAIXAS - design minimalista)
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
                color: AppColors.silver.withValues(alpha: 0.2),
              ),
              SimpleStat(
                label: 'PATENTE',
                value: _character.patente ?? 'Recruta',
                labelColor: AppColors.conhecimentoGreen,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Divisor Grunge
          GrungeDivider(
            color: AppColors.scarletRed.withValues(alpha: 0.3),
            height: 2,
            heavy: false,
          ),

          const SizedBox(height: 24),

          // PV (barra minimalista SEM BORDAS)
          HexatombeStatusBar(
            title: 'PONTOS DE VIDA',
            current: _character.pvAtual,
            max: _character.pvMax,
            fillColor: AppColors.pvRed,
            onIncrement: () {
              setState(() {
                if (_character.pvAtual < _character.pvMax) {
                  _character.pvAtual++;
                }
              });
            },
            onDecrement: () {
              setState(() {
                if (_character.pvAtual > 0) {
                  _character.pvAtual--;
                }
              });
            },
          ),

          const SizedBox(height: 20),

          // PE (barra minimalista SEM BORDAS)
          HexatombeStatusBar(
            title: 'PONTOS DE ESFORÇO',
            current: _character.peAtual,
            max: _character.peMax,
            fillColor: AppColors.pePurple,
            onIncrement: () {
              setState(() {
                if (_character.peAtual < _character.peMax) {
                  _character.peAtual++;
                }
              });
            },
            onDecrement: () {
              setState(() {
                if (_character.peAtual > 0) {
                  _character.peAtual--;
                }
              });
            },
          ),

          const SizedBox(height: 20),

          // SAN (barra minimalista SEM BORDAS)
          HexatombeStatusBar(
            title: 'SANIDADE',
            current: _character.sanAtual,
            max: _character.sanMax,
            fillColor: AppColors.sanYellow,
            onIncrement: () {
              setState(() {
                if (_character.sanAtual < _character.sanMax) {
                  _character.sanAtual++;
                }
              });
            },
            onDecrement: () {
              setState(() {
                if (_character.sanAtual > 0) {
                  _character.sanAtual--;
                }
              });
            },
          ),

          const SizedBox(height: 32),

          // Divisor Grunge
          GrungeDivider(
            color: AppColors.scarletRed.withValues(alpha: 0.3),
            height: 2,
            heavy: true,
          ),

          const SizedBox(height: 24),

          // Stats de combate (minimalista)
          Text(
            'COMBATE',
            style: AppTextStyles.uppercase.copyWith(
              fontSize: 16,
              color: AppColors.scarletRed,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SimpleStat(
                label: 'DEFESA',
                value: _character.defesaCalculada.toString(),
                labelColor: AppColors.forRed,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.silver.withValues(alpha: 0.2),
              ),
              SimpleStat(
                label: 'BLOQUEIO',
                value: _character.bloqueioCalculado.toString(),
                labelColor: AppColors.vigBlue,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.silver.withValues(alpha: 0.2),
              ),
              SimpleStat(
                label: 'DESLOCAMENTO',
                value: '${_character.deslocamentoCalculado}m',
                labelColor: AppColors.agiGreen,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Divisor Grunge
          GrungeDivider(
            color: AppColors.scarletRed.withValues(alpha: 0.3),
            height: 2,
            heavy: false,
          ),

          const SizedBox(height: 16),

          // Peso do inventário
          _buildWeightSection(),

          const SizedBox(height: 24),

          // Créditos
          _buildCreditSection(),
        ],
      ),
    );
  }

  Widget _buildWeightSection() {
    final itemRepo = ItemRepository();

    return FutureBuilder<int>(
      future: itemRepo.getTotalWeight(_character.id),
      builder: (context, snapshot) {
        final pesoAtual = snapshot.data ?? 0;
        final pesoMax = _character.pesoMaximo;
        final percentual = pesoMax > 0 ? (pesoAtual / pesoMax) : 0.0;

        Color weightColor;
        if (percentual >= 1.0) {
          weightColor = AppColors.neonRed; // Sobrecarga
        } else if (percentual >= 0.75) {
          weightColor = AppColors.sanYellow; // Quase cheio
        } else {
          weightColor = AppColors.conhecimentoGreen; // OK
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            border: Border.all(color: weightColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PESO DO INVENTÁRIO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: weightColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    '$pesoAtual / $pesoMax kg',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: weightColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Barra de progresso
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.deepBlack,
                  border: Border.all(color: weightColor.withOpacity(0.3)),
                ),
                child: FractionallySizedBox(
                  widthFactor: percentual.clamp(0.0, 1.0),
                  alignment: Alignment.centerLeft,
                  child: Container(
                    color: weightColor,
                  ),
                ),
              ),
              if (percentual >= 1.0) ...[
                const SizedBox(height: 8),
                Text(
                  '⚠ SOBRECARGA! Velocidade e agilidade reduzidas.',
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.neonRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCreditSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CRÉDITOS', style: AppTextStyles.title),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            border: Border.all(color: AppColors.conhecimentoGreen),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SALDO',
                style: AppTextStyles.uppercase.copyWith(
                  fontSize: 12,
                  color: AppColors.conhecimentoGreen,
                ),
              ),
              Text(
                '\$${_character.creditos}',
                style: AppTextStyles.title.copyWith(
                  fontSize: 24,
                  color: AppColors.conhecimentoGreen,
                ),
              ),
            ],
          ),
        ),
      ],
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
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
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
            // Círculo com ícone (SEM BORDA)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
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
                      color: AppColors.silver.withValues(alpha: 0.7),
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
                          color: color.withValues(alpha: 0.2),
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

            // Valor grande (SEM BORDA)
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
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
              color: AppColors.conhecimentoGreen.withValues(alpha: 0.1),
              border: Border(
                left: BorderSide(color: AppColors.conhecimentoGreen, width: 4),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.conhecimentoGreen, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Perícias treinadas ganham +5 de bônus',
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
                color: isTreinada ? AppColors.conhecimentoGreen.withValues(alpha: 0.1) : AppColors.darkGray,
                border: isTreinada
                    ? Border(
                        left: BorderSide(color: AppColors.conhecimentoGreen, width: 4),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  // Checkbox (SEM BORDA)
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isTreinada) {
                          _character.periciasTreinadas.remove(nome);
                        } else {
                          _character.periciasTreinadas.add(nome);
                        }
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isTreinada
                            ? AppColors.conhecimentoGreen
                            : AppColors.darkGray.withValues(alpha: 0.3),
                      ),
                      child: isTreinada
                          ? const Icon(Icons.check, color: AppColors.deepBlack, size: 16)
                          : null,
                    ),
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

                  // Atributo (SEM BORDA)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getAttrColor(attr).withValues(alpha: 0.2),
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
    return FutureBuilder<int>(
      future: _countItems(),
      builder: (context, snapshot) {
        final itemCount = snapshot.data ?? 0;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InventoryManagementScreen(character: _character),
              ),
            ).then((_) => setState(() {})); // Refresh ao voltar
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.energiaYellow.withValues(alpha: 0.1),
              border: Border(
                left: BorderSide(color: AppColors.energiaYellow, width: 6),
              ),
            ),
            child: Row(
              children: [
                // Ícone grande (SEM BORDERRADIUS)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.energiaYellow.withValues(alpha: 0.2),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: AppColors.energiaYellow,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),

                // Conteúdo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'INVENTÁRIO',
                            style: AppTextStyles.title.copyWith(
                              color: AppColors.energiaYellow,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.energiaYellow.withValues(alpha: 0.3),
                            ),
                            child: Text(
                              '$itemCount ITENS',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.energiaYellow,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Gerencie seus itens e equipamentos',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.silver.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Seta
                const SizedBox(width: 12),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.energiaYellow,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPoderesSection() {
    return FutureBuilder<int>(
      future: _countPowers(),
      builder: (context, snapshot) {
        final powerCount = snapshot.data ?? 0;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PowersManagementScreen(character: _character),
              ),
            ).then((_) => setState(() {})); // Refresh ao voltar
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.medoPurple.withValues(alpha: 0.1),
              border: Border(
                left: BorderSide(color: AppColors.medoPurple, width: 6),
              ),
            ),
            child: Row(
              children: [
                // Ícone grande (SEM BORDERRADIUS)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.medoPurple.withValues(alpha: 0.2),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.medoPurple,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),

                // Conteúdo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'PODERES E RITUAIS',
                            style: AppTextStyles.title.copyWith(
                              color: AppColors.medoPurple,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.medoPurple.withValues(alpha: 0.3),
                            ),
                            child: Text(
                              '$powerCount PODERES',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.medoPurple,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Gerencie seus poderes paranormais',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.silver.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Seta
                const SizedBox(width: 12),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.medoPurple,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
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
                    color: AppColors.silver.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // Métodos _buildEmptyState, _buildItemCard e _buildPowerCard removidos
  // Não são mais necessários após refatoração para botões de navegação

  Future<List<dynamic>> _loadItems() async {
    final storage = LocalStorage();
    final allItems = await storage.loadItems();
    return allItems.where((item) {
      final itemId = item['id'] as String?;
      return itemId != null && _character.inventarioIds.contains(itemId);
    }).toList();
  }

  Future<List<dynamic>> _loadPowers() async {
    final storage = LocalStorage();
    final allPowers = await storage.loadPowers();
    return allPowers.where((power) {
      final powerId = power['id'] as String?;
      return powerId != null && _character.poderesIds.contains(powerId);
    }).toList();
  }

  /// Conta itens diretamente do banco por characterId
  Future<int> _countItems() async {
    try {
      final itemRepository = ItemRepository();
      return await itemRepository.countByCharacterId(_character.id);
    } catch (e) {
      debugPrint('Erro ao contar itens: $e');
      return 0;
    }
  }

  /// Conta poderes diretamente do banco por characterId
  Future<int> _countPowers() async {
    try {
      final powerRepository = PowerRepository();
      return await powerRepository.countByCharacterId(_character.id);
    } catch (e) {
      debugPrint('Erro ao contar poderes: $e');
      return 0;
    }
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

  Widget _buildPlaceholderSection(String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border.all(color: AppColors.silver.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppColors.silver.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              description.toUpperCase(),
              style: AppTextStyles.uppercase.copyWith(
                color: AppColors.silver.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Em desenvolvimento',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.silver.withOpacity(0.3),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
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
