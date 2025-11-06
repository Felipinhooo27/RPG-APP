import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/local_database_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final LocalDatabaseService _databaseService = LocalDatabaseService();
  String _filtroCategoria = 'Todas';

  final List<String> _categorias = [
    'Todas',
    'Sessão',
    'NPC',
    'Local',
    'Plot',
    'Outro',
  ];

  final Map<String, IconData> _categoriasIcons = {
    'Sessão': Icons.event,
    'NPC': Icons.person,
    'Local': Icons.place,
    'Plot': Icons.auto_stories,
    'Outro': Icons.note,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas do Mestre'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar por Categoria',
            onSelected: (value) {
              setState(() {
                _filtroCategoria = value;
              });
            },
            itemBuilder: (context) {
              return _categorias.map((categoria) {
                return PopupMenuItem<String>(
                  value: categoria,
                  child: Row(
                    children: [
                      Icon(_categoriasIcons[categoria] ?? Icons.category),
                      const SizedBox(width: 8),
                      Text(categoria),
                      if (_filtroCategoria == categoria)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.check, size: 16),
                        ),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Note>>(
        stream: _databaseService.getAllNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          var notes = snapshot.data ?? [];

          // Filtrar por categoria
          if (_filtroCategoria != 'Todas') {
            notes = notes.where((n) => n.categoria == _filtroCategoria).toList();
          }

          // Ordenar por data de modificação (mais recente primeiro)
          notes.sort((a, b) => b.dataModificacao.compareTo(a.dataModificacao));

          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _filtroCategoria == 'Todas'
                        ? 'Nenhuma nota ainda'
                        : 'Nenhuma nota na categoria "$_filtroCategoria"',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Toque no botão + para criar',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return _buildNoteCard(note);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nova Nota'),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    final icon = _categoriasIcons[note.categoria] ?? Icons.note;
    final dataFormatada = _formatarData(note.dataModificacao);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showNoteDialog(note: note),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.titulo,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                note.categoria,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dataFormatada,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(note),
                    color: Colors.red[300],
                  ),
                ],
              ),
              if (note.conteudo.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  note.conteudo,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatarData(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);

    if (diferenca.inMinutes < 1) {
      return 'Agora';
    } else if (diferenca.inHours < 1) {
      return '${diferenca.inMinutes}m atrás';
    } else if (diferenca.inDays < 1) {
      return '${diferenca.inHours}h atrás';
    } else if (diferenca.inDays < 7) {
      return '${diferenca.inDays}d atrás';
    } else {
      return '${data.day}/${data.month}/${data.year}';
    }
  }

  Future<void> _showNoteDialog({Note? note}) async {
    final isEditing = note != null;
    final tituloController = TextEditingController(text: note?.titulo ?? '');
    final conteudoController = TextEditingController(text: note?.conteudo ?? '');
    String categoriaSelecionada = note?.categoria ?? 'Outro';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEditing ? 'Editar Nota' : 'Nova Nota'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tituloController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        hintText: 'Ex: Sessão 1 - Encontro com o Culto',
                      ),
                      autofocus: !isEditing,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: categoriaSelecionada,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                      ),
                      items: _categorias
                          .where((c) => c != 'Todas')
                          .map((categoria) {
                        return DropdownMenuItem(
                          value: categoria,
                          child: Row(
                            children: [
                              Icon(_categoriasIcons[categoria], size: 20),
                              const SizedBox(width: 8),
                              Text(categoria),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          categoriaSelecionada = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: conteudoController,
                      decoration: const InputDecoration(
                        labelText: 'Conteúdo',
                        hintText: 'Escreva sua nota aqui...',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 10,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (tituloController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('O título não pode estar vazio'),
                      ),
                    );
                    return;
                  }

                  try {
                    if (isEditing) {
                      final updatedNote = note.copyWith(
                        titulo: tituloController.text.trim(),
                        conteudo: conteudoController.text.trim(),
                        categoria: categoriaSelecionada,
                      );
                      await _databaseService.updateNote(updatedNote);
                    } else {
                      final newNote = Note(
                        id: const Uuid().v4(),
                        titulo: tituloController.text.trim(),
                        conteudo: conteudoController.text.trim(),
                        dataCriacao: DateTime.now(),
                        dataModificacao: DateTime.now(),
                        categoria: categoriaSelecionada,
                      );
                      await _databaseService.createNote(newNote);
                    }

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Nota atualizada!'
                                : 'Nota criada!',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(isEditing ? 'Salvar' : 'Criar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Nota'),
        content: Text('Deseja realmente excluir a nota "${note.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _databaseService.deleteNote(note.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nota excluída'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
