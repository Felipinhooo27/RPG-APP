import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../models/character.dart';
import '../services/local_database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'character_list_screen.dart';
import 'character_grimoire_screen.dart';
import 'dice_roller_screen.dart';
import 'iniciativa_screen.dart';
import 'notes_screen.dart';
import 'advanced_character_generator_screen.dart';
import 'mass_payment_screen.dart';
import 'master_shop_manager_screen.dart';

class MasterDashboardScreen extends StatefulWidget {
  const MasterDashboardScreen({super.key});

  @override
  State<MasterDashboardScreen> createState() => _MasterDashboardScreenState();
}

class _MasterDashboardScreenState extends State<MasterDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _MasterHomeTab(),
    CharacterListScreen(isMasterMode: true),
    IniciativaScreen(),
    NotesScreen(),
    DiceRollerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.obscureGray,
        selectedItemColor: AppTheme.ritualRed,
        unselectedItemColor: AppTheme.coldGray,
        selectedLabelStyle: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Montserrat'),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Personagens',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield),
            label: 'Iniciativa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: 'Dados',
          ),
        ],
      ),
    );
  }
}

class _MasterHomeTab extends StatefulWidget {
  const _MasterHomeTab();

  @override
  State<_MasterHomeTab> createState() => _MasterHomeTabState();
}

class _MasterHomeTabState extends State<_MasterHomeTab> {
  final LocalDatabaseService _databaseService = LocalDatabaseService();

  @override
  Widget build(BuildContext context) {
    return HexatombeBackground(
      showParticles: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppTheme.abyssalBlack.withOpacity(0.9),
          elevation: 0,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DASHBOARD DO MESTRE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                  color: AppTheme.ritualRed,
                ),
              ),
              Text(
                'Gerencie sua campanha',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.coldGray,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
        body: StreamBuilder<List<Character>>(
          stream: _databaseService.getAllCharacters(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: HexLoading.large(message: 'Carregando...'));
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppTheme.alertYellow),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.paleWhite,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              );
            }

            final characters = snapshot.data ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ações do Mestre
                  _buildActionsSection(context, characters),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, List<Character> characters) {
    return RitualCard(
      glowEffect: true,
      glowColor: AppTheme.chaoticMagenta,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AÇÕES DO MESTRE',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.ritualRed,
              fontFamily: 'BebasNeue',
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),

          // Exportar
          _ActionTile(
            icon: Icons.share,
            iconColor: AppTheme.mutagenGreen,
            title: 'Exportar Personagens',
            subtitle: 'Compartilhar via WhatsApp',
            onTap: () => _showExportDialog(characters),
          ),
          const SizedBox(height: 8),

          // Importar
          _ActionTile(
            icon: Icons.download,
            iconColor: AppTheme.etherealPurple,
            title: 'Importar Personagens',
            subtitle: 'Importar do JSON',
            onTap: _showImportDialog,
          ),
          const SizedBox(height: 8),

          // Gerador Avançado
          _ActionTile(
            icon: Icons.auto_awesome,
            iconColor: AppTheme.alertYellow,
            title: 'Gerador Avançado',
            subtitle: 'Civil, Soldado, Líder, Deus...',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvancedCharacterGeneratorScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // Pagamentos em Massa
          _ActionTile(
            icon: Icons.monetization_on,
            iconColor: AppTheme.ritualRed,
            title: 'Pagamentos em Massa',
            subtitle: 'Adicionar/remover créditos',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MassPaymentScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // Gerenciar Lojas
          _ActionTile(
            icon: Icons.store,
            iconColor: AppTheme.alertYellow,
            title: 'Gerenciar Lojas',
            subtitle: 'Criar e editar lojas para jogadores',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MasterShopManagerScreen(
                    masterId: 'master_001',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  // Dialog de Exportar
  Future<void> _showExportDialog(List<Character> characters) async {
    if (characters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum personagem para exportar'),
          backgroundColor: AppTheme.alertYellow,
        ),
      );
      return;
    }

    final json = jsonEncode(characters.map((c) => c.toMap()).toList());
    await Share.share(
      json,
      subject: 'Personagens Hexatombe RPG',
    );
  }

  // Dialog de Importar
  Future<void> _showImportDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: 500,
          ),
          child: RitualCard(
            glowEffect: true,
            glowColor: AppTheme.etherealPurple,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.of(context).viewInsets.bottom * 0.5,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'IMPORTAR PERSONAGENS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.etherealPurple,
                      fontFamily: 'BebasNeue',
                      letterSpacing: 2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: TextField(
                      controller: controller,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(
                        color: AppTheme.paleWhite,
                        fontFamily: 'SpaceMono',
                        fontSize: 11,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cole o JSON aqui...',
                        hintStyle: TextStyle(color: AppTheme.coldGray),
                        filled: true,
                        fillColor: AppTheme.obscureGray,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: AppTheme.etherealPurple, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: AppTheme.coldGray, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: AppTheme.etherealPurple, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: GlowingButton(
                            label: 'Cancelar',
                            onPressed: () => Navigator.pop(context),
                            style: GlowingButtonStyle.secondary,
                            width: 120,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: GlowingButton(
                            label: 'Importar',
                            icon: Icons.download,
                            onPressed: () async {
                              try {
                                final json = controller.text.trim();
                                final List<dynamic> data = jsonDecode(json);
                                final characters = data.map((e) => Character.fromMap(e)).toList();

                                await _databaseService.importCharacters(characters, 'master_001');

                                if (mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${characters.length} personagem(ns) importado(s)!'),
                                      backgroundColor: AppTheme.mutagenGreen,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erro: JSON inválido'),
                                      backgroundColor: AppTheme.ritualRed,
                                    ),
                                  );
                                }
                              }
                            },
                            style: GlowingButtonStyle.primary,
                            width: 120,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget customizado para as ações
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RitualCard(
        glowEffect: true,
        glowColor: iconColor,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.35),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.paleWhite,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.coldGray,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppTheme.coldGray, size: 16),
          ],
        ),
      ),
    );
  }
}
