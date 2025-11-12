import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/character.dart';
import '../../models/power.dart';
import '../../core/database/power_repository.dart';
import '../../core/database/character_repository.dart';
import '../../widgets/hexatombe_ui_components.dart';
import 'power_form_screen.dart';

/// Tela completa de gerenciamento de poderes e rituais
/// Funcionalidades: Pesquisa, Filtros, CRUD, Export/Import
class PowersManagementScreen extends StatefulWidget {
  final Character character;

  const PowersManagementScreen({
    super.key,
    required this.character,
  });

  @override
  State<PowersManagementScreen> createState() => _PowersManagementScreenState();
}

class _PowersManagementScreenState extends State<PowersManagementScreen> {
  final _powerRepo = PowerRepository();
  final _characterRepo = CharacterRepository();
  final _searchController = TextEditingController();

  List<Power> _allPowers = [];
  List<Power> _filteredPowers = [];
  String _searchQuery = '';
  ElementoOutroLado? _filterElemento;
  bool? _filterRitual; // true = rituais, false = poderes, null = todos
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPowers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPowers() async {
    setState(() => _isLoading = true);
    try {
      final powers = await _powerRepo.getByCharacterId(widget.character.id);
      setState(() {
        _allPowers = powers;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar poderes: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    _filteredPowers = _allPowers.where((power) {
      // Filtro de pesquisa
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!power.nome.toLowerCase().contains(query) &&
            !power.descricao.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filtro de elemento
      if (_filterElemento != null && power.elemento != _filterElemento) {
        return false;
      }

      // Filtro de ritual
      if (_filterRitual != null && power.isRitual != _filterRitual) {
        return false;
      }

      return true;
    }).toList();

    // Ordena por nome
    _filteredPowers.sort((a, b) => a.nome.compareTo(b.nome));
  }

  @override
  Widget build(BuildContext context) {
    final custoPETotal = _allPowers.fold<int>(0, (sum, power) => sum + power.custoPE);

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: AppColors.darkGray,
        elevation: 0,
        title: Text('PODERES E RITUAIS', style: AppTextStyles.title),
        actions: [
          // Menu de opções
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.silver),
            color: AppColors.darkGray,
            onSelected: (value) {
              switch (value) {
                case 'export_all':
                  _exportPowers();
                  break;
                case 'import':
                  _importPowers();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_all',
                child: Text('Exportar Poderes', style: TextStyle(color: AppColors.lightGray)),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Text('Importar Poderes', style: TextStyle(color: AppColors.lightGray)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Header: Info de PE
          _buildHeader(custoPETotal),

          // Pesquisa e Filtros
          _buildSearchAndFilters(),

          // Lista de Poderes
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.medoPurple),
                  )
                : _filteredPowers.isEmpty
                    ? _buildEmptyState()
                    : _buildPowerList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int custoPETotal) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.darkGray,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.flash_on, color: AppColors.energiaYellow, size: 20),
                const SizedBox(width: 8),
                Text(
                  'CUSTO TOTAL:',
                  style: AppTextStyles.uppercase.copyWith(
                    fontSize: 11,
                    color: AppColors.silver.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$custoPETotal PE',
                  style: AppTextStyles.title.copyWith(
                    fontSize: 20,
                    color: AppColors.energiaYellow,
                  ),
                ),
              ],
            ),
          ),
          // Botão de adicionar como texto vermelho (substitui FAB)
          InkWell(
            onTap: _addPower,
            child: Row(
              children: [
                Icon(Icons.add, size: 16, color: AppColors.scarletRed),
                const SizedBox(width: 4),
                Text(
                  'NOVO PODER',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.scarletRed,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.darkGray,
      child: Column(
        children: [
          // Barra de Pesquisa
          TextField(
            controller: _searchController,
            style: AppTextStyles.body.copyWith(color: AppColors.lightGray),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _applyFilters();
              });
            },
            decoration: InputDecoration(
              hintText: 'Pesquisar poderes...',
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.silver.withOpacity(0.3),
              ),
              prefixIcon: const Icon(Icons.search, color: AppColors.silver),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.silver),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _applyFilters();
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.deepBlack,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: AppColors.silver),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: AppColors.silver.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: AppColors.silver.withOpacity(0.5), width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),

          const SizedBox(height: 12),

          // Filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'Todos',
                  _filterElemento == null && _filterRitual == null,
                  () {
                    setState(() {
                      _filterElemento = null;
                      _filterRitual = null;
                      _applyFilters();
                    });
                  },
                  AppColors.silver,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Apenas Rituais',
                  _filterRitual == true,
                  () {
                    setState(() {
                      _filterRitual = _filterRitual == true ? null : true;
                      _applyFilters();
                    });
                  },
                  AppColors.medoPurple,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Apenas Poderes',
                  _filterRitual == false,
                  () {
                    setState(() {
                      _filterRitual = _filterRitual == false ? null : false;
                      _applyFilters();
                    });
                  },
                  AppColors.magenta,
                ),
                const SizedBox(width: 8),
                ...ElementoOutroLado.values.map((elemento) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      _getElementoNome(elemento),
                      _filterElemento == elemento,
                      () {
                        setState(() {
                          _filterElemento = _filterElemento == elemento ? null : elemento;
                          _applyFilters();
                        });
                      },
                      _getElementoColor(elemento),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.scarletRed : AppColors.silver.withOpacity(0.7),
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 64, color: AppColors.silver.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _filterElemento != null || _filterRitual != null
                ? 'NENHUM PODER ENCONTRADO'
                : 'NENHUM PODER APRENDIDO',
            style: AppTextStyles.uppercase.copyWith(
              color: AppColors.silver.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _filterElemento != null || _filterRitual != null
                ? 'Tente ajustar os filtros'
                : 'Toque em + para adicionar um poder',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.silver.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPowers.length,
      itemBuilder: (context, index) {
        final power = _filteredPowers[index];
        return _buildPowerCard(power);
      },
    );
  }

  Widget _buildPowerCard(Power power) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Elemento como texto vermelho
                  Text(
                    _getElementoNome(power.elemento).toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.scarletRed,
                      letterSpacing: 1.0,
                    ),
                  ),
                  if (power.isRitual) ...[
                    const SizedBox(width: 8),
                    Text(
                      '• ${power.circulo}º CÍRCULO',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.scarletRed,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Icon(Icons.flash_on, size: 14, color: AppColors.energiaYellow),
                  const SizedBox(width: 4),
                  Text(
                    '${power.custoPE} PE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.energiaYellow,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Nome
              Text(
                power.nome.toUpperCase(),
                style: AppTextStyles.uppercase.copyWith(
                  fontSize: 13,
                  color: AppColors.lightGray,
                ),
              ),
              const SizedBox(height: 8),

              // Descrição
              Text(
                power.descricao,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.silver.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),

              if (power.efeitos != null) ...[
                const SizedBox(height: 8),
                Text(
                  'EFEITOS: ${power.efeitos}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.silver.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
              ],

              if (power.duracao != null || power.alcance != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (power.duracao != null) ...[
                      const Icon(Icons.timer, size: 12, color: AppColors.silver),
                      const SizedBox(width: 4),
                      Text(
                        power.duracao!,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.silver.withOpacity(0.7),
                        ),
                      ),
                    ],
                    if (power.duracao != null && power.alcance != null) const SizedBox(width: 16),
                    if (power.alcance != null) ...[
                      const Icon(Icons.my_location, size: 12, color: AppColors.silver),
                      const SizedBox(width: 4),
                      Text(
                        power.alcance!,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.silver.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              // Ações como texto simples
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildActionButton(
                    'EDITAR',
                    Icons.edit,
                    AppColors.scarletRed,
                    () => _editPower(power),
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(
                    'EXCLUIR',
                    Icons.delete,
                    AppColors.scarletRed,
                    () => _deletePower(power),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Divisor arranhado entre poderes
        const GrungeDivider(heavy: false),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addPower() async {
    final result = await Navigator.push<Power>(
      context,
      MaterialPageRoute(
        builder: (context) => PowerFormScreen(characterId: widget.character.id),
      ),
    );

    if (result != null) {
      await _updateCharacterPowers(result.id, add: true);
      _loadPowers();
    }
  }

  Future<void> _editPower(Power power) async {
    final result = await Navigator.push<Power>(
      context,
      MaterialPageRoute(
        builder: (context) => PowerFormScreen(
          characterId: widget.character.id,
          powerToEdit: power,
        ),
      ),
    );

    if (result != null) {
      _loadPowers();
    }
  }

  Future<void> _deletePower(Power power) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text('CONFIRMAR EXCLUSÃO', style: TextStyle(color: AppColors.lightGray)),
        content: Text(
          'Deseja realmente excluir ${power.nome}?',
          style: const TextStyle(color: AppColors.silver),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonRed,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _powerRepo.delete(power.id);
        await _updateCharacterPowers(power.id, add: false);
        _loadPowers();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${power.nome} excluído!'),
              backgroundColor: AppColors.conhecimentoGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
              backgroundColor: AppColors.neonRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _updateCharacterPowers(String powerId, {required bool add}) async {
    try {
      final character = await _characterRepo.getById(widget.character.id);
      if (character == null) return;

      final updatedPowerIds = List<String>.from(character.poderesIds);
      if (add && !updatedPowerIds.contains(powerId)) {
        updatedPowerIds.add(powerId);
      } else if (!add) {
        updatedPowerIds.remove(powerId);
      }

      final updatedCharacter = character.copyWith(poderesIds: updatedPowerIds);
      await _characterRepo.update(updatedCharacter);
    } catch (e) {
      // Silently handle error, main operation already succeeded
    }
  }

  Future<void> _exportPowers() async {
    try {
      final powersData = await _powerRepo.exportByCharacterId(widget.character.id);
      final jsonString = jsonEncode(powersData);

      await Clipboard.setData(ClipboardData(text: jsonString));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Poderes copiados para a área de transferência!'),
            backgroundColor: AppColors.conhecimentoGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar: $e'),
            backgroundColor: AppColors.neonRed,
          ),
        );
      }
    }
  }

  Future<void> _importPowers() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData == null || clipboardData.text == null) {
        throw Exception('Área de transferência vazia');
      }

      final jsonData = jsonDecode(clipboardData.text!) as List<dynamic>;
      final powers = jsonData.map((json) {
        final power = Power.fromJson(json as Map<String, dynamic>);
        return power.copyWith(characterId: widget.character.id);
      }).toList();

      await _powerRepo.importPowers(powers);

      // Update character powers list
      for (final power in powers) {
        await _updateCharacterPowers(power.id, add: true);
      }

      _loadPowers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${powers.length} poder(es) importado(s)!'),
            backgroundColor: AppColors.conhecimentoGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao importar: $e'),
            backgroundColor: AppColors.neonRed,
          ),
        );
      }
    }
  }

  String _getElementoNome(ElementoOutroLado elemento) {
    switch (elemento) {
      case ElementoOutroLado.conhecimento:
        return 'CONHECIMENTO';
      case ElementoOutroLado.energia:
        return 'ENERGIA';
      case ElementoOutroLado.morte:
        return 'MORTE';
      case ElementoOutroLado.sangue:
        return 'SANGUE';
      case ElementoOutroLado.medo:
        return 'MEDO';
    }
  }

  Color _getElementoColor(ElementoOutroLado elemento) {
    switch (elemento) {
      case ElementoOutroLado.conhecimento:
        return AppColors.conhecimentoGreen;
      case ElementoOutroLado.energia:
        return AppColors.energiaYellow;
      case ElementoOutroLado.morte:
        return AppColors.silver;
      case ElementoOutroLado.sangue:
        return AppColors.sangueRed;
      case ElementoOutroLado.medo:
        return AppColors.medoPurple;
    }
  }
}
