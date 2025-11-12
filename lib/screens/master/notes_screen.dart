import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/hexatombe_ui_components.dart';

/// Tela de Notas da Campanha (Mestre)
/// Sistema de anotações organizadas por categorias
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final List<CampaignNote> _notes = [];
  NoteCategory _selectedCategory = NoteCategory.all;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getStringList('campaign_notes') ?? [];

      setState(() {
        _notes.clear();
        for (final json in notesJson) {
          try {
            // Parse simples: "category|title|content|timestamp"
            final parts = json.split('|||');
            if (parts.length >= 4) {
              _notes.add(CampaignNote(
                category: NoteCategory.values.firstWhere(
                  (c) => c.name == parts[0],
                  orElse: () => NoteCategory.geral,
                ),
                title: parts[1],
                content: parts[2],
                timestamp: DateTime.parse(parts[3]),
              ));
            }
          } catch (e) {
            // Skip malformed notes
          }
        }
        _notes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = _notes.map((note) {
        return '${note.category.name}|||${note.title}|||${note.content}|||${note.timestamp.toIso8601String()}';
      }).toList();
      await prefs.setStringList('campaign_notes', notesJson);
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
    final filteredNotes = _selectedCategory == NoteCategory.all
        ? _notes
        : _notes.where((n) => n.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: Column(
        children: [
          _buildHeader(),
          _buildCategoryFilter(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.magenta),
                  )
                : filteredNotes.isEmpty
                    ? _buildEmptyState()
                    : _buildNotesList(filteredNotes),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.darkGray,
      child: Row(
        children: [
          const Icon(Icons.notes, color: AppColors.scarletRed, size: 20),
          const SizedBox(width: 8),
          Text(
            'NOTAS DA CAMPANHA',
            style: AppTextStyles.uppercase.copyWith(
              fontSize: 14,
              color: AppColors.lightGray,
            ),
          ),
          const Spacer(),
          // Botão de adicionar como texto vermelho (substitui FAB)
          InkWell(
            onTap: _createNote,
            child: Row(
              children: [
                Icon(Icons.add, size: 16, color: AppColors.scarletRed),
                const SizedBox(width: 4),
                Text(
                  'NOVA NOTA',
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

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: NoteCategory.values.map((category) {
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => setState(() => _selectedCategory = category),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Text(
                  _getCategoryLabel(category),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.scarletRed : AppColors.silver.withOpacity(0.7),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add,
            size: 64,
            color: AppColors.silver.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'NENHUMA NOTA',
            style: AppTextStyles.title.copyWith(
              color: AppColors.silver.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no + para criar uma anotação',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.silver.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(List<CampaignNote> notes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteCard(note);
      },
    );
  }

  Widget _buildNoteCard(CampaignNote note) {
    return InkWell(
      onTap: () => _viewNote(note),
      onLongPress: () => _deleteNote(note),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Categoria como texto vermelho
                    Text(
                      _getCategoryLabel(note.category).toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.scarletRed,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatTimestamp(note.timestamp),
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.silver.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  note.title.toUpperCase(),
                  style: AppTextStyles.uppercase.copyWith(
                    fontSize: 13,
                    color: AppColors.lightGray,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  note.content,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.silver.withOpacity(0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Divisor arranhado entre notas
          const GrungeDivider(heavy: false),
        ],
      ),
    );
  }

  Color _getCategoryColor(NoteCategory category) {
    switch (category) {
      case NoteCategory.all:
        return AppColors.silver;
      case NoteCategory.geral:
        return AppColors.magenta;
      case NoteCategory.npcs:
        return AppColors.conhecimentoGreen;
      case NoteCategory.locais:
        return AppColors.energiaYellow;
      case NoteCategory.combate:
        return AppColors.sangueRed;
      case NoteCategory.historia:
        return AppColors.medoPurple;
    }
  }

  String _getCategoryLabel(NoteCategory category) {
    switch (category) {
      case NoteCategory.all:
        return 'TODAS';
      case NoteCategory.geral:
        return 'GERAL';
      case NoteCategory.npcs:
        return 'NPCs';
      case NoteCategory.locais:
        return 'LOCAIS';
      case NoteCategory.combate:
        return 'COMBATE';
      case NoteCategory.historia:
        return 'HISTÓRIA';
    }
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d atrás';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _createNote() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    NoteCategory selectedCategory = NoteCategory.geral;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.darkGray,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: const Text('NOVA NOTA'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CATEGORIA',
                  style: AppTextStyles.uppercase.copyWith(
                    fontSize: 10,
                    color: AppColors.silver,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<NoteCategory>(
                  value: selectedCategory,
                  dropdownColor: AppColors.darkGray,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                  ),
                  items: NoteCategory.values
                      .where((c) => c != NoteCategory.all)
                      .map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(_getCategoryLabel(category)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Conteúdo',
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    _notes.insert(
                      0,
                      CampaignNote(
                        category: selectedCategory,
                        title: titleController.text,
                        content: contentController.text,
                        timestamp: DateTime.now(),
                      ),
                    );
                  });
                  _saveNotes();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.magenta,
              ),
              child: const Text('SALVAR'),
            ),
          ],
        ),
      ),
    );
  }

  void _viewNote(CampaignNote note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getCategoryColor(note.category).withOpacity(0.2),
                border: Border.all(color: _getCategoryColor(note.category)),
              ),
              child: Text(
                _getCategoryLabel(note.category),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: _getCategoryColor(note.category),
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              note.title.toUpperCase(),
              style: AppTextStyles.uppercase.copyWith(fontSize: 14),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            note.content,
            style: AppTextStyles.body.copyWith(color: AppColors.silver),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNote(note);
            },
            child: Text(
              'EXCLUIR',
              style: TextStyle(color: AppColors.neonRed),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('FECHAR'),
          ),
        ],
      ),
    );
  }

  void _deleteNote(CampaignNote note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        title: const Text('EXCLUIR NOTA?'),
        content: Text('Deseja realmente excluir "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _notes.remove(note);
              });
              _saveNotes();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonRed),
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ENUMS E MODELS
// =============================================================================
enum NoteCategory {
  all,
  geral,
  npcs,
  locais,
  combate,
  historia,
}

class CampaignNote {
  final NoteCategory category;
  final String title;
  final String content;
  final DateTime timestamp;

  CampaignNote({
    required this.category,
    required this.title,
    required this.content,
    required this.timestamp,
  });
}
