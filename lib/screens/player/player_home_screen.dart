import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/character.dart';
import 'character_grimoire_screen.dart';
import 'google_dice_roller_screen.dart';
import 'shop_screen.dart';
import 'stats_dashboard_screen.dart';
import 'achievements_screen.dart';

/// Tela Principal do Jogador com BottomNavigationBar
/// 4 abas: Personagens | Dados | Loja | Opções
class PlayerHomeScreen extends StatefulWidget {
  final String userId;
  final Character selectedCharacter;

  const PlayerHomeScreen({
    super.key,
    required this.userId,
    required this.selectedCharacter,
  });

  @override
  State<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends State<PlayerHomeScreen> {
  int _currentIndex = 0;
  late Character _currentCharacter;

  @override
  void initState() {
    super.initState();
    _currentCharacter = widget.selectedCharacter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: _buildAppBar(),
      body: _buildBody(),
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
        tooltip: 'Voltar para seleção',
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentCharacter.nome.toUpperCase(),
            style: AppTextStyles.uppercase.copyWith(
              fontSize: 16,
              color: AppColors.scarletRed,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${_currentCharacter.classe.name.toUpperCase()} • NEX ${_currentCharacter.nex}%',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10,
              color: AppColors.silver,
            ),
          ),
        ],
      ),
      actions: [
        // Quick stats indicator
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            children: [
              _buildQuickStat('PV', _currentCharacter.pvAtual, _currentCharacter.pvMax, AppColors.pvRed),
              const SizedBox(width: 8),
              _buildQuickStat('PE', _currentCharacter.peAtual, _currentCharacter.peMax, AppColors.pePurple),
              const SizedBox(width: 8),
              _buildQuickStat('PS', _currentCharacter.sanAtual, _currentCharacter.sanMax, AppColors.sanYellow),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStat(String label, int current, int max, Color color) {
    final percentage = current / max;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            border: Border.all(color: color, width: 0.5),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage.clamp(0.0, 1.0),
            child: Container(color: color),
          ),
        ),
        Text(
          '$current',
          style: TextStyle(
            fontSize: 8,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildPersonagensTab();
      case 1:
        return _buildDadosTab();
      case 2:
        return _buildLojaTab();
      case 3:
        return _buildOpcoesTab();
      default:
        return const SizedBox();
    }
  }

  // ============================================================================
  // TAB 1: PERSONAGENS
  // ============================================================================
  Widget _buildPersonagensTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 64, color: AppColors.silver),
          const SizedBox(height: 16),
          Text(
            'GRIMÓRIO DO PERSONAGEM',
            style: AppTextStyles.title.copyWith(color: AppColors.silver),
          ),
          const SizedBox(height: 8),
          Text(
            'Visualize e edite sua ficha completa',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.silver),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CharacterGrimoireScreen(
                    character: _currentCharacter,
                  ),
                ),
              ).then((value) {
                // Atualiza estado se necessário após voltar
                setState(() {});
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.scarletRed,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('ABRIR FICHA COMPLETA'),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 2: DADOS
  // ============================================================================
  Widget _buildDadosTab() {
    return const GoogleDiceRollerScreen();
  }

  // ============================================================================
  // TAB 3: LOJA
  // ============================================================================
  Widget _buildLojaTab() {
    return ShopScreen(character: _currentCharacter);
  }

  // ============================================================================
  // TAB 4: OPÇÕES
  // ============================================================================
  Widget _buildOpcoesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('OPÇÕES', style: AppTextStyles.title),
          const SizedBox(height: 24),

          // Dashboard de Estatísticas
          _buildOptionButton(
            icon: Icons.bar_chart,
            label: 'DASHBOARD DE ESTATÍSTICAS',
            color: AppColors.energiaYellow,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatsDashboardScreen(
                    character: _currentCharacter,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Conquistas
          _buildOptionButton(
            icon: Icons.emoji_events,
            label: 'CONQUISTAS',
            color: AppColors.magenta,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AchievementsScreen(
                    character: _currentCharacter,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Trocar personagem
          _buildOptionButton(
            icon: Icons.swap_horiz,
            label: 'TROCAR PERSONAGEM',
            color: AppColors.scarletRed,
            onTap: () => Navigator.pop(context),
          ),

          const SizedBox(height: 16),

          // Exportar personagem
          _buildOptionButton(
            icon: Icons.share,
            label: 'EXPORTAR PERSONAGEM',
            color: AppColors.conhecimentoGreen,
            onTap: _exportCharacter,
          ),

          const SizedBox(height: 16),

          // Sobre o app
          _buildOptionButton(
            icon: Icons.info_outline,
            label: 'SOBRE',
            color: AppColors.silver,
            onTap: _showAbout,
          ),

          const SizedBox(height: 32),

          // Créditos
          Center(
            child: Column(
              children: [
                Text(
                  'HEXATOMBE RPG',
                  style: AppTextStyles.uppercase.copyWith(
                    color: AppColors.scarletRed,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Desenvolvido por estudantes de ADS',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.silver,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Inspirado em Ordem Paranormal',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.silver.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: AppTextStyles.uppercase.copyWith(
                color: color,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  void _exportCharacter() async {
    // TODO: Implement export using ClipboardHelper
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exportação será implementada')),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          'SOBRE',
          style: AppTextStyles.uppercase.copyWith(color: AppColors.scarletRed),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HEXATOMBE RPG',
              style: AppTextStyles.uppercase.copyWith(
                color: AppColors.lightGray,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Versão 1.0.0',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.silver),
            ),
            const SizedBox(height: 16),
            Text(
              'Aplicativo de gerenciamento de personagens para RPG de mesa inspirado no sistema Ordem Paranormal.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.silver),
            ),
            const SizedBox(height: 16),
            Text(
              'Desenvolvido como projeto acadêmico.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.silver.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('FECHAR'),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // BOTTOM NAVIGATION
  // ============================================================================
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
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          letterSpacing: 1.0,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'PERSONAGENS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: 'DADOS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'LOJA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'OPÇÕES',
          ),
        ],
      ),
    );
  }
}
