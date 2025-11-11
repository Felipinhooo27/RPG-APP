import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/database/character_repository.dart';
import '../../models/character.dart';
import '../../core/utils/clipboard_helper.dart';
import '../character_wizard/character_wizard_screen.dart';
import '../master/advanced_generator_screen.dart';
import '../player/player_home_screen.dart';

/// Tela de seleção de personagem
/// Aparece IMEDIATAMENTE após selecionar JOGADOR/MESTRE
/// Design inline sem caixas
class CharacterSelectionScreen extends StatefulWidget {
  final String userId;
  final bool isMasterMode;

  const CharacterSelectionScreen({
    super.key,
    required this.userId,
    this.isMasterMode = false,
  });

  @override
  State<CharacterSelectionScreen> createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
  final CharacterRepository _characterRepo = CharacterRepository();
  List<Character> _characters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    setState(() => _isLoading = true);

    try {
      final characters = widget.isMasterMode
          ? await _characterRepo.getAll()
          : await _characterRepo.getByUserId(widget.userId);

      setState(() {
        _characters = characters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar personagens: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        title: const Text('COM QUEM VOCÊ QUER JOGAR?'),
        actions: [
          if (!widget.isMasterMode)
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: _importCharacter,
              tooltip: 'Importar',
            ),
          if (widget.isMasterMode)
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              onPressed: _openAdvancedGenerator,
              tooltip: 'Gerador Avançado',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.scarletRed),
            )
          : _characters.isEmpty
              ? _buildEmptyState()
              : _buildCharacterList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewCharacter,
        backgroundColor: AppColors.scarletRed,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 80,
            color: AppColors.silver.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'NENHUM PERSONAGEM',
            style: AppTextStyles.title.copyWith(
              color: AppColors.silver.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no botão + para criar seu primeiro personagem',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.silver.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _characters.length,
      separatorBuilder: (_, __) => Divider(
        color: AppColors.silver.withOpacity(0.2),
        height: 1,
      ),
      itemBuilder: (context, index) {
        final character = _characters[index];
        return _buildCharacterTile(character);
      },
    );
  }

  Widget _buildCharacterTile(Character character) {
    final classColor = _getClassColor(character.classe);

    return InkWell(
      onTap: () => _selectCharacter(character),
      onLongPress: () => _showContextMenu(character),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            // Avatar hexagonal (simplificado por enquanto)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: classColor.withOpacity(0.2),
                border: Border.all(color: classColor, width: 2),
              ),
              child: Center(
                child: Text(
                  character.nome[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: classColor,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Info inline
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome
                  Text(
                    character.nome.toUpperCase(),
                    style: AppTextStyles.uppercase,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Classe e NEX
                  Row(
                    children: [
                      Text(
                        character.classe.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: classColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'NEX ${character.nex}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.magenta,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Barras inline (SEM CONTAINER)
                  Row(
                    children: [
                      _buildInlineBar(
                        'PV',
                        character.pvAtual,
                        character.pvMax,
                        AppColors.neonRed,
                      ),
                      const SizedBox(width: 8),
                      _buildInlineBar(
                        'PE',
                        character.peAtual,
                        character.peMax,
                        AppColors.magenta,
                      ),
                      const SizedBox(width: 8),
                      _buildInlineBar(
                        'PS',
                        character.sanAtual,
                        character.sanMax,
                        Colors.amber,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Ícone classe
            Icon(
              _getClassIcon(character.classe),
              color: classColor,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineBar(String label, int current, int max, Color color) {
    final percent = max > 0 ? current / max : 0.0;
    final isLow = percent <= 0.25;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label $current/$max',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isLow ? AppColors.neonRed : color,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
            ),
            child: FractionallySizedBox(
              widthFactor: percent,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: isLow ? AppColors.neonRed : color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getClassColor(CharacterClass classe) {
    switch (classe) {
      case CharacterClass.combatente:
        return AppColors.neonRed;
      case CharacterClass.especialista:
        return AppColors.conhecimentoGreen;
      case CharacterClass.ocultista:
        return AppColors.magenta;
    }
  }

  IconData _getClassIcon(CharacterClass classe) {
    switch (classe) {
      case CharacterClass.combatente:
        return Icons.gavel;
      case CharacterClass.especialista:
        return Icons.build;
      case CharacterClass.ocultista:
        return Icons.auto_stories;
    }
  }

  void _selectCharacter(Character character) {
    if (widget.isMasterMode) {
      // Mestre: apenas mostra snackbar (TODO: abrir ficha do NPC)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecionado: ${character.nome}')),
      );
    } else {
      // Jogador: navega para PlayerHomeScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerHomeScreen(
            userId: widget.userId,
            selectedCharacter: character,
          ),
        ),
      );
    }
  }

  void _showContextMenu(Character character) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkGray,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: AppColors.silver),
            title: const Text('EDITAR'),
            onTap: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CharacterWizardScreen(
                    userId: widget.userId,
                    characterToEdit: character,
                  ),
                ),
              );
              if (result == true) {
                _loadCharacters(); // Reload characters after edit
              }
            },
          ),
          if (widget.isMasterMode)
            ListTile(
              leading: const Icon(Icons.file_upload, color: AppColors.scarletRed),
              title: const Text('EXPORTAR'),
              onTap: () {
                Navigator.pop(context);
                _exportCharacter(character);
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete, color: AppColors.neonRed),
            title: const Text('DELETAR'),
            onTap: () {
              Navigator.pop(context);
              _deleteCharacter(character);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _createNewCharacter() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CharacterWizardScreen(userId: widget.userId),
      ),
    );

    if (result == true) {
      // Recarrega a lista
      await _loadCharacters();
    }
  }

  Future<void> _importCharacter() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        title: const Text('IMPORTAR PERSONAGENS'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cole os dados do personagem copiados',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.silver),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await _importFromClipboard();
              },
              icon: const Icon(Icons.content_paste),
              label: const Text('COLAR DA ÁREA DE TRANSFERÊNCIA'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showManualImport();
              },
              icon: const Icon(Icons.edit),
              label: const Text('DIGITAR MANUALMENTE'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
        ],
      ),
    );
  }

  Future<void> _importFromClipboard() async {
    try {
      final result = await ClipboardHelper.importFromClipboard();

      if (!result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: ${result.errorMessage}')),
          );
        }
        return;
      }

      // Confirma quantos personagens serão importados
      final count = result.characters!.length;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkGray,
          title: const Text('CONFIRMAR IMPORTAÇÃO'),
          content: Text(
            'Importar $count personage${count > 1 ? 'ns' : 'm'}?\n\n'
            '${result.characters!.map((c) => '• ${c.nome}').join('\n')}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('IMPORTAR'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        // Importa personagens
        await _characterRepo.importCharacters(result.characters!, replace: false);
        await _loadCharacters();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$count personagem(ns) importado(s) com sucesso!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao importar: $e')),
        );
      }
    }
  }

  void _showManualImport() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        title: const Text('DIGITAR JSON'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 10,
            style: AppTextStyles.bodySmall,
            decoration: const InputDecoration(
              hintText: '{\n  "version": "1.0",\n  "type": "character",\n  ...\n}',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              final json = controller.text.trim();
              Navigator.pop(context);

              if (json.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('JSON vazio')),
                );
                return;
              }

              final result = ClipboardHelper.importFromJson(json);

              if (!result.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro: ${result.errorMessage}')),
                );
                return;
              }

              await _characterRepo.importCharacters(result.characters!, replace: false);
              await _loadCharacters();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${result.characters!.length} personagem(ns) importado(s)!')),
              );
            },
            child: const Text('IMPORTAR'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCharacter(Character character) async {
    try {
      final json = ClipboardHelper.exportCharacter(character);
      await ClipboardHelper.copyToClipboard(json);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.darkGray,
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.conhecimentoGreen),
                const SizedBox(width: 8),
                const Text('COPIADO!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personagem "${character.nome}" copiado para área de transferência.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 16),
                Text(
                  'Agora você pode compartilhar com outros jogadores!',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.silver),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar: $e')),
        );
      }
    }
  }

  Future<void> _deleteCharacter(Character character) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        title: const Text('DELETAR PERSONAGEM'),
        content: Text(
          'Tem certeza que deseja deletar ${character.nome}?\nEsta ação não pode ser desfeita.',
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
            ),
            child: const Text('DELETAR'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _characterRepo.delete(character.id);
        await _loadCharacters();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${character.nome} deletado')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao deletar: $e')),
          );
        }
      }
    }
  }

  Future<void> _openAdvancedGenerator() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdvancedGeneratorScreen(userId: widget.userId),
      ),
    );

    if (result == true) {
      await _loadCharacters();
    }
  }
}
