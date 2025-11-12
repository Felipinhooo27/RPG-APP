import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/character.dart';
import '../../core/database/character_repository.dart';
import '../../core/utils/clipboard_helper.dart';
import '../../widgets/character_sheet_tab_view.dart';
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
  final CharacterRepository _repo = CharacterRepository();

  @override
  void initState() {
    super.initState();
    _currentCharacter = widget.selectedCharacter;
  }

  Future<void> _saveCharacter() async {
    try {
      await _repo.update(_currentCharacter);
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

  /// Recarrega o personagem do banco de dados para obter dados atualizados
  Future<void> _reloadCharacter() async {
    try {
      final updated = await _repo.getById(_currentCharacter.id);
      if (updated != null && mounted) {
        setState(() {
          _currentCharacter = updated;
        });
      }
    } catch (e) {
      // Falha silenciosa - não mostra erro ao usuário
      debugPrint('Erro ao recarregar personagem: $e');
    }
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
        // Botão de salvar (apenas na aba PERSONAGENS)
        if (_currentIndex == 0)
          IconButton(
            icon: const Icon(Icons.save, color: AppColors.conhecimentoGreen),
            onPressed: _saveCharacter,
            tooltip: 'Salvar alterações',
          ),
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
    return CharacterSheetTabView(
      character: _currentCharacter,
      onCharacterChanged: () {
        setState(() {
          // Atualiza o AppBar quando o personagem muda
        });
      },
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
    return ShopScreen(
      character: _currentCharacter,
      onCharacterChanged: _reloadCharacter,
    );
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
                  'Desenvolvido por estudantes de Ciências da Computação',
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

  Future<void> _exportCharacter() async {
    try {
      // Exporta em JSON para fácil importação (versão 2.0 com itens e poderes)
      final json = await ClipboardHelper.exportCharacterJson(_currentCharacter);
      final jsonController = TextEditingController(text: json);

      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.darkGray,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            title: Row(
              children: [
                const Icon(Icons.share, color: AppColors.magenta, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'EXPORTAR PERSONAGEM',
                    style: AppTextStyles.uppercase.copyWith(
                      fontSize: 14,
                      color: AppColors.magenta,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personagem: ${_currentCharacter.nome}',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.lightGray,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Copie o JSON abaixo e compartilhe com o mestre:',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.silver,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: AppColors.deepBlack,
                      border: Border.all(color: AppColors.silver.withValues(alpha: 0.3)),
                    ),
                    child: TextField(
                      controller: jsonController,
                      maxLines: null,
                      readOnly: true,
                      style: TextStyle(
                        color: AppColors.lightGray,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('FECHAR'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await ClipboardHelper.copyToClipboard(json);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${_currentCharacter.nome} copiado para área de transferência!'),
                        backgroundColor: AppColors.conhecimentoGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.copy),
                label: const Text('COPIAR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.magenta,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              ),
            ],
          ),
        );
      }

      jsonController.dispose();
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
        onTap: (index) {
          setState(() => _currentIndex = index);
          _reloadCharacter(); // Recarrega personagem ao trocar de aba
        },
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
