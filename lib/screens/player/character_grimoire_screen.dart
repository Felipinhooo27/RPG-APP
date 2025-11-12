import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/character.dart';
import '../../widgets/character_sheet_tab_view.dart';

/// Ficha Completa do Personagem (Grimório)
/// Agora renderiza CharacterSheetTabView para garantir consistência de design
/// entre MESTRE e PLAYER
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

class _CharacterGrimoireScreenState extends State<CharacterGrimoireScreen> {
  late Character _character;

  @override
  void initState() {
    super.initState();
    _character = widget.character;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: _buildAppBar(),
      body: CharacterSheetTabView(
        character: _character,
        onCharacterChanged: () {
          setState(() {
            // Atualiza a UI quando o personagem for modificado
          });
        },
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
    );
  }
}
