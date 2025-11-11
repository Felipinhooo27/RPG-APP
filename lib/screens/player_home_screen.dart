import 'package:flutter/material.dart';
import 'character_list_screen.dart';
import 'dice_roller_screen.dart';
import 'shop_screen.dart';
import '../models/character.dart';
import '../services/local_database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class PlayerHomeScreen extends StatefulWidget {
  const PlayerHomeScreen({super.key});

  @override
  State<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends State<PlayerHomeScreen> {
  int _currentIndex = 0;
  final LocalDatabaseService _dbService = LocalDatabaseService();
  Character? _selectedCharacter;

  @override
  void initState() {
    super.initState();
    _loadSelectedCharacter();
  }

  Future<void> _loadSelectedCharacter() async {
    try {
      // Get first character as default (in a real app, would persist selection)
      final characters = await _dbService.getAllCharactersList();
      if (characters.isNotEmpty && mounted) {
        setState(() {
          _selectedCharacter = characters.first;
        });
      }
    } catch (e) {
      // Silently fail, user can select character later
    }
  }

  List<Widget> get _screens => [
    const CharacterListScreen(isMasterMode: false),
    const DiceRollerScreen(),
    if (_selectedCharacter != null)
      ShopScreen(character: _selectedCharacter!)
    else
      const Center(
        child: Text(
          'Selecione um personagem primeiro',
          style: TextStyle(color: AppTheme.coldGray),
        ),
      ),
    _buildOptionsPlaceholder(),
  ];

  Widget _buildOptionsPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            size: 64,
            color: AppTheme.silver.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Opções do Jogador',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.silver,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configurações em desenvolvimento',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.coldGray,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

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
        backgroundColor: AppTheme.obscureGray,
        selectedItemColor: AppTheme.ritualRed,
        unselectedItemColor: AppTheme.coldGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Personagens',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: 'Dados',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Loja',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Opções',
          ),
        ],
      ),
    );
  }
}
