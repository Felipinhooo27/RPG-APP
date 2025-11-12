import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/database/character_repository.dart';
import '../../core/database/item_repository.dart';
import '../../core/database/power_repository.dart';
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
  List<Character> _filteredCharacters = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCharacters();
    _searchController.addListener(_filterCharacters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCharacters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCharacters = _characters;
      } else {
        _filteredCharacters = _characters
            .where((char) => char.nome.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _loadCharacters() async {
    setState(() => _isLoading = true);

    try {
      // Sempre filtra por userId (player_001 ou master_001)
      // para garantir separação entre personagens de jogador e NPCs de mestre
      final characters = await _characterRepo.getByUserId(widget.userId);

      setState(() {
        _characters = characters;
        _filteredCharacters = characters;
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
        title: Text(
          widget.isMasterMode ? 'SELECIONAR NPC' : 'SELECIONAR PERSONAGEM',
          style: AppTextStyles.title,
        ),
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
          : Column(
              children: [
                if (_characters.isNotEmpty) _buildSearchBar(),
                Expanded(
                  child: _filteredCharacters.isEmpty && _searchController.text.isNotEmpty
                      ? _buildNoResultsState()
                      : _characters.isEmpty
                          ? _buildEmptyState()
                          : _buildCharacterList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewCharacter,
        backgroundColor: AppColors.scarletRed,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.scarletRed.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColors.silver.withOpacity(0.7), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: AppTextStyles.body.copyWith(color: AppColors.lightGray),
              decoration: InputDecoration(
                hintText: widget.isMasterMode ? 'Pesquisar NPCs...' : 'Pesquisar personagens...',
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.silver.withOpacity(0.3),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.scarletRed.withOpacity(0.5)),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.scarletRed.withOpacity(0.3)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.scarletRed, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close, color: AppColors.silver.withOpacity(0.7), size: 20),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.silver.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'NENHUM RESULTADO',
            style: AppTextStyles.title.copyWith(
              color: AppColors.silver.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nenhum personagem encontrado com "${_searchController.text}"',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.silver.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
      itemCount: _filteredCharacters.length,
      separatorBuilder: (_, __) => Divider(
        color: AppColors.silver.withOpacity(0.2),
        height: 1,
      ),
      itemBuilder: (context, index) {
        final character = _filteredCharacters[index];
        return _buildCharacterTile(character);
      },
    );
  }

  Widget _buildCharacterTile(Character character) {
    return InkWell(
      onTap: () => _selectCharacter(character),
      onLongPress: () => _showContextMenu(character),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            // Ícone simples em vermelho-sangue
            Icon(
              Icons.person,
              color: AppColors.scarletRed,
              size: 32,
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
                    style: AppTextStyles.uppercase.copyWith(
                      fontSize: 14,
                      color: AppColors.lightGray,
                    ),
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
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.scarletRed,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• NEX ${character.nex}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.silver.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Barras inline
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

            // Seta direita
            Icon(
              Icons.chevron_right,
              color: AppColors.scarletRed,
              size: 24,
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
      ).then((_) => _loadCharacters()); // FIX: Recarrega dados ao voltar!
    }
  }

  void _showContextMenu(Character character) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkGray,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: AppColors.lightGray),
            title: Text('EDITAR', style: TextStyle(color: AppColors.lightGray)),
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
                _loadCharacters();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.share, color: AppColors.lightGray),
            title: Text('EXPORTAR', style: TextStyle(color: AppColors.lightGray)),
            onTap: () {
              Navigator.pop(context);
              _exportCharacter(character);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: AppColors.scarletRed),
            title: Text('DELETAR', style: TextStyle(color: AppColors.scarletRed)),
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
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          'IMPORTAR PERSONAGEM',
          style: AppTextStyles.uppercase.copyWith(
            fontSize: 14,
            color: AppColors.scarletRed,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cole os dados do personagem copiados',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.silver),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await _importFromClipboard();
                },
                icon: const Icon(Icons.content_paste),
                label: const Text('COLAR DA ÁREA DE TRANSFERÊNCIA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.scarletRed,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showManualImport();
                },
                icon: const Icon(Icons.edit),
                label: const Text('DIGITAR MANUALMENTE'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.scarletRed),
                  foregroundColor: AppColors.scarletRed,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.silver),
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
        // Importa personagens com novo userId e novo ID
        final importedCharacters = await _characterRepo.importCharacters(
          result.characters!,
          replace: false,
          newUserId: widget.userId,
          generateNewId: true,
        );

        // Importa itens (se houver) com o novo characterId
        if (result.items != null && result.items!.isNotEmpty) {
          final itemRepo = ItemRepository();
          for (final item in result.items!) {
            // Atualiza characterId para o novo ID do personagem importado
            final newItem = item.copyWith(
              characterId: importedCharacters.first.id,
            );
            await itemRepo.create(newItem);
          }
        }

        // Importa poderes (se houver) com o novo characterId
        if (result.powers != null && result.powers!.isNotEmpty) {
          final powerRepo = PowerRepository();
          for (final power in result.powers!) {
            // Atualiza characterId para o novo ID do personagem importado
            final newPower = power.copyWith(
              characterId: importedCharacters.first.id,
            );
            await powerRepo.create(newPower);
          }
        }

        await _loadCharacters();

        if (mounted) {
          final itemCount = result.items?.length ?? 0;
          final powerCount = result.powers?.length ?? 0;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$count personagem(ns) + $itemCount itens + $powerCount poderes importados!'),
            ),
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
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          'DIGITAR JSON',
          style: AppTextStyles.uppercase.copyWith(
            fontSize: 14,
            color: AppColors.scarletRed,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          height: 300,
          padding: const EdgeInsets.all(12),
          color: AppColors.deepBlack,
          child: TextField(
            controller: controller,
            maxLines: null,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.lightGray,
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              hintText: '{\n  "version": "2.0",\n  "type": "character",\n  ...\n}',
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.silver.withOpacity(0.3),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.silver),
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

              // Importa personagem com novo userId e novo ID
              final importedCharacters = await _characterRepo.importCharacters(
                result.characters!,
                replace: false,
                newUserId: widget.userId,
                generateNewId: true,
              );

              // Importa itens (se houver) com o novo characterId
              if (result.items != null && result.items!.isNotEmpty) {
                final itemRepo = ItemRepository();
                for (final item in result.items!) {
                  // Atualiza characterId para o novo ID do personagem importado
                  final newItem = item.copyWith(
                    characterId: importedCharacters.first.id,
                  );
                  await itemRepo.create(newItem);
                }
              }

              // Importa poderes (se houver) com o novo characterId
              if (result.powers != null && result.powers!.isNotEmpty) {
                final powerRepo = PowerRepository();
                for (final power in result.powers!) {
                  // Atualiza characterId para o novo ID do personagem importado
                  final newPower = power.copyWith(
                    characterId: importedCharacters.first.id,
                  );
                  await powerRepo.create(newPower);
                }
              }

              await _loadCharacters();

              // Força atualização da UI
              if (mounted) {
                setState(() {});
              }

              final itemCount = result.items?.length ?? 0;
              final powerCount = result.powers?.length ?? 0;
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${result.characters!.length} personagem(ns) + $itemCount itens + $powerCount poderes importados!',
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.scarletRed,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('IMPORTAR'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCharacter(Character character) async {
    try {
      // Exporta em JSON para fácil importação (versão 2.0 com itens e poderes)
      final json = await ClipboardHelper.exportCharacterJson(character);
      final jsonController = TextEditingController(text: json);

      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.darkGray,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            title: Text(
              'EXPORTAR PERSONAGEM',
              style: AppTextStyles.uppercase.copyWith(
                fontSize: 14,
                color: AppColors.scarletRed,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personagem: ${character.nome}',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.lightGray,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Copie o JSON abaixo e compartilhe:',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.silver,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 300,
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
                        content: Text('${character.nome} copiado para área de transferência!'),
                        backgroundColor: AppColors.scarletRed,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.copy),
                label: const Text('COPIAR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.scarletRed,
                  foregroundColor: AppColors.lightGray,
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
