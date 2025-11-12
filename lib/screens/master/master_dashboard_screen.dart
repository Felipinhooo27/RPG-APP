import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/database/character_repository.dart';
import '../../models/character.dart';
import '../player/google_dice_roller_screen.dart';
import 'advanced_generator_screen.dart';
import 'quick_character_generator_screen.dart';
import 'iniciativa_screen.dart';
import 'notes_screen.dart';
import 'mass_payment_screen.dart';
import 'npc_generator_screen.dart';

/// Dashboard Principal do Mestre com BottomNavigationBar
/// 6 abas: NPCs | Gerador | Loja | Iniciativa | Notas | Dados
class MasterDashboardScreen extends StatefulWidget {
  final String userId;

  const MasterDashboardScreen({
    super.key,
    required this.userId,
  });

  @override
  State<MasterDashboardScreen> createState() => _MasterDashboardScreenState();
}

class _MasterDashboardScreenState extends State<MasterDashboardScreen> {
  int _currentIndex = 0;
  final CharacterRepository _repo = CharacterRepository();
  List<Character> _allCharacters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    setState(() => _isLoading = true);
    try {
      final characters = await _repo.getAll();
      setState(() {
        _allCharacters = characters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MassPaymentScreen(),
                  ),
                ).then((_) => _loadCharacters());
              },
              backgroundColor: AppColors.conhecimentoGreen,
              icon: const Icon(Icons.payments),
              label: const Text('PAGAMENTO EM MASSA'),
            )
          : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.deepBlack,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.silver),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Voltar',
      ),
      title: Row(
        children: [
          const Icon(Icons.shield, color: AppColors.scarletRed, size: 20),
          const SizedBox(width: 8),
          Text(
            'MODO MESTRE',
            style: AppTextStyles.uppercase.copyWith(
              fontSize: 16,
              color: AppColors.scarletRed,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.scarletRed.withOpacity(0.2),
                border: Border.all(color: AppColors.scarletRed),
              ),
              child: Text(
                '${_allCharacters.length} NPCs',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.scarletRed,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildNPCsTab();
      case 1:
        return _buildGeradorTab();
      case 2:
        return _buildLojaTab();
      case 3:
        return _buildIniciativaTab();
      case 4:
        return _buildNotasTab();
      case 5:
        return _buildDadosTab();
      default:
        return const SizedBox();
    }
  }

  // ==========================================================================
  // TAB 1: NPCs (Lista de todos os personagens)
  // ==========================================================================
  Widget _buildNPCsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.scarletRed),
      );
    }

    if (_allCharacters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off, size: 64, color: AppColors.silver),
            const SizedBox(height: 16),
            Text(
              'NENHUM NPC CRIADO',
              style: AppTextStyles.title.copyWith(color: AppColors.silver),
            ),
            const SizedBox(height: 8),
            Text(
              'Use o Gerador Avançado para criar NPCs',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.silver.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCharacters,
      color: AppColors.scarletRed,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _allCharacters.length,
        separatorBuilder: (_, __) => Divider(
          color: AppColors.silver.withOpacity(0.2),
          height: 24,
        ),
        itemBuilder: (context, index) {
          final character = _allCharacters[index];
          return _buildNPCCard(character);
        },
      ),
    );
  }

  Widget _buildNPCCard(Character character) {
    return InkWell(
      onTap: () => _showNPCDetails(character),
      onLongPress: () => _showNPCOptions(character),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          border: Border.all(color: AppColors.silver.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.scarletRed.withOpacity(0.2),
                border: Border.all(color: AppColors.scarletRed, width: 2),
              ),
              child: Center(
                child: Text(
                  character.nome[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.scarletRed,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character.nome.toUpperCase(),
                    style: AppTextStyles.uppercase.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${character.classe.name.toUpperCase()} • NEX ${character.nex}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.silver.withOpacity(0.7),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildQuickStat('PV', character.pvAtual, character.pvMax, AppColors.pvRed),
                      const SizedBox(width: 8),
                      _buildQuickStat('PE', character.peAtual, character.peMax, AppColors.pePurple),
                      const SizedBox(width: 8),
                      _buildQuickStat('SAN', character.sanAtual, character.sanMax, AppColors.sanYellow),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(Icons.chevron_right, color: AppColors.silver.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, int current, int max, Color color) {
    return Row(
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 9,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          '$current/$max',
          style: TextStyle(
            fontSize: 9,
            color: color.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  void _showNPCDetails(Character character) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          character.nome.toUpperCase(),
          style: AppTextStyles.uppercase.copyWith(color: AppColors.scarletRed),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Classe', character.classe.name.toUpperCase()),
            _buildDetailRow('Origem', character.origem.name.toUpperCase()),
            _buildDetailRow('NEX', '${character.nex}%'),
            const Divider(color: AppColors.silver),
            _buildDetailRow('FOR', character.forca.toString()),
            _buildDetailRow('AGI', character.agilidade.toString()),
            _buildDetailRow('VIG', character.vigor.toString()),
            _buildDetailRow('INT', character.intelecto.toString()),
            _buildDetailRow('PRE', character.presenca.toString()),
            const Divider(color: AppColors.silver),
            _buildDetailRow('PV', '${character.pvAtual}/${character.pvMax}'),
            _buildDetailRow('PE', '${character.peAtual}/${character.peMax}'),
            _buildDetailRow('SAN', '${character.sanAtual}/${character.sanMax}'),
            _buildDetailRow('Defesa', character.defesa.toString()),
            _buildDetailRow('Créditos', '\$${character.creditos}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('FECHAR'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showNPCOptions(character);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.scarletRed,
            ),
            child: const Text('OPÇÕES'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.silver.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.lightGray,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showNPCOptions(Character character) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkGray,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: AppColors.conhecimentoGreen),
            title: const Text('EDITAR'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edição será implementada')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.share, color: AppColors.magenta),
            title: const Text('EXPORTAR'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exportação será implementada')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: AppColors.neonRed),
            title: const Text('EXCLUIR'),
            onTap: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.darkGray,
                  title: const Text('CONFIRMAR EXCLUSÃO'),
                  content: Text('Deseja realmente excluir ${character.nome}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('CANCELAR'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonRed,
                      ),
                      child: const Text('EXCLUIR'),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                try {
                  await _repo.delete(character.id);
                  _loadCharacters();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('NPC excluído')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao excluir: $e')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 2: GERADOR
  // ==========================================================================
  Widget _buildGeradorTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick Generator Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            border: Border.all(color: AppColors.neonRed, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flash_on, color: AppColors.neonRed, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'GERADOR RÁPIDO',
                      style: AppTextStyles.uppercase.copyWith(
                        fontSize: 16,
                        color: AppColors.neonRed,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Gere NPCs instantaneamente para combates e encontros. '
                'Selecione apenas o nível de poder e deixe o sistema criar automaticamente.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.silver,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildFeatureBadge('4 Níveis de Poder'),
                  const SizedBox(width: 8),
                  _buildFeatureBadge('Geração Instantânea'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuickCharacterGeneratorScreen(),
                      ),
                    );
                    _loadCharacters();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonRed,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text(
                    'ABRIR GERADOR RÁPIDO',
                    style: TextStyle(letterSpacing: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Advanced Generator Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            border: Border.all(color: AppColors.magenta, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.magenta, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'GERADOR AVANÇADO',
                      style: AppTextStyles.uppercase.copyWith(
                        fontSize: 16,
                        color: AppColors.magenta,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Crie personagens completos e balanceados com controle total. '
                'Sistema de tiers, distribuição de atributos, seleção de perícias e poderes.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.silver,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildFeatureBadge('Totalmente Customizável'),
                  const SizedBox(width: 8),
                  _buildFeatureBadge('Sistema de Tiers'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdvancedGeneratorScreen(userId: widget.userId),
                      ),
                    );

                    if (result == true) {
                      _loadCharacters();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.magenta,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text(
                    'ABRIR GERADOR AVANÇADO',
                    style: TextStyle(letterSpacing: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // NPC Personality Generator Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            border: Border.all(color: AppColors.energiaYellow, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology, color: AppColors.energiaYellow, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'GERADOR DE PERSONALIDADE',
                      style: AppTextStyles.uppercase.copyWith(
                        fontSize: 16,
                        color: AppColors.energiaYellow,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Gere NPCs com personalidades únicas e profundas. '
                'Motivações, segredos, medos, backgrounds e peculiaridades gerados proceduralmente.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.silver,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildFeatureBadge('Geração Procedural'),
                  const SizedBox(width: 8),
                  _buildFeatureBadge('9 Aspectos Únicos'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NPCGeneratorScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.energiaYellow,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: Text(
                    'ABRIR GERADOR DE PERSONALIDADE',
                    style: TextStyle(
                      letterSpacing: 1.5,
                      color: AppColors.deepBlack,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            border: Border.all(color: AppColors.conhecimentoGreen.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.conhecimentoGreen, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Use o Gerador Rápido para combates, Avançado para NPCs importantes e Personalidade para criar backgrounds únicos',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.silver.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.conhecimentoGreen.withOpacity(0.2),
        border: Border.all(color: AppColors.conhecimentoGreen.withOpacity(0.5)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 8,
          color: AppColors.conhecimentoGreen,
          letterSpacing: 1.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ==========================================================================
  // TAB 3: LOJA (Placeholder)
  // ==========================================================================
  Widget _buildLojaTab() {
    return _buildPlaceholderTab(
      icon: Icons.store,
      title: 'GERENCIAR LOJAS',
      description: 'Crie e gerencie lojas para os jogadores',
    );
  }

  // ==========================================================================
  // TAB 4: INICIATIVA
  // ==========================================================================
  Widget _buildIniciativaTab() {
    return const IniciativaScreen();
  }

  // ==========================================================================
  // TAB 5: NOTAS
  // ==========================================================================
  Widget _buildNotasTab() {
    return const NotesScreen();
  }

  Widget _buildPlaceholderTab({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.silver.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.title.copyWith(
              color: AppColors.silver.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.silver.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'EM DESENVOLVIMENTO',
            style: AppTextStyles.uppercase.copyWith(
              color: AppColors.scarletRed.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BOTTOM NAVIGATION
  // ==========================================================================
  // ==========================================================================
  // TAB 6: DADOS (Rolador de dados)
  // ==========================================================================
  Widget _buildDadosTab() {
    return const GoogleDiceRollerScreen();
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border(
          top: BorderSide(color: AppColors.scarletRed.withOpacity(0.3), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.scarletRed,
        unselectedItemColor: AppColors.silver.withOpacity(0.5),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 9,
          letterSpacing: 1.0,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'NPCs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'GERADOR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'LOJA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_martial_arts),
            label: 'INICIATIVA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notes),
            label: 'NOTAS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: 'DADOS',
          ),
        ],
      ),
    );
  }
}
