import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/local_database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

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

  final Map<String, Color> _categoriasColors = {
    'Sessão': AppTheme.ritualRed,
    'NPC': AppTheme.mutagenGreen,
    'Local': AppTheme.etherealPurple,
    'Plot': AppTheme.chaoticMagenta,
    'Outro': AppTheme.alertYellow,
  };

  @override
  Widget build(BuildContext context) {
    return HexatombeBackground(
      showParticles: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppTheme.abyssalBlack.withOpacity(0.9),
          elevation: 0,
          title: const Text(
            'NOTAS DO MESTRE',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'BebasNeue',
              letterSpacing: 2,
              color: AppTheme.etherealPurple,
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list, color: AppTheme.etherealPurple),
              tooltip: 'Filtrar por Categoria',
              onSelected: (value) {
                setState(() {
                  _filtroCategoria = value;
                });
              },
              color: AppTheme.obscureGray,
              itemBuilder: (context) {
                return _categorias.map((categoria) {
                  final color = _categoriasColors[categoria] ?? AppTheme.coldGray;
                  return PopupMenuItem<String>(
                    value: categoria,
                    child: Row(
                      children: [
                        Icon(
                          _categoriasIcons[categoria] ?? Icons.category,
                          color: color,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          categoria,
                          style: TextStyle(
                            color: _filtroCategoria == categoria
                                ? color
                                : AppTheme.paleWhite,
                            fontFamily: 'Montserrat',
                            fontWeight: _filtroCategoria == categoria
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                        if (_filtroCategoria == categoria) ...[
                          const Spacer(),
                          Icon(Icons.check, size: 16, color: color),
                        ],
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
              return const Center(child: HexLoading.large());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.ritualRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar notas',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.coldGray,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              );
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
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.obscureGray,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.etherealPurple.withOpacity(0.35),
                            blurRadius: 6,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.note_add,
                        size: 60,
                        color: AppTheme.etherealPurple,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _filtroCategoria == 'Todas'
                          ? 'NENHUMA NOTA AINDA'
                          : 'NENHUMA NOTA EM "$_filtroCategoria"',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.coldGray,
                        fontFamily: 'BebasNeue',
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toque no botão abaixo para criar',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.coldGray,
                        fontFamily: 'Montserrat',
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
                return _buildNoteCard(note, index);
              },
            );
          },
        ),
        floatingActionButton: GlowingButton(
          label: 'Nova Nota',
          icon: Icons.add,
          onPressed: () => _showNoteDialog(),
          style: GlowingButtonStyle.primary,
          pulsateGlow: true,
        ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
      ),
    );
  }

  Widget _buildNoteCard(Note note, int index) {
    final icon = _categoriasIcons[note.categoria] ?? Icons.note;
    final color = _categoriasColors[note.categoria] ?? AppTheme.coldGray;
    final dataFormatada = _formatarData(note.dataModificacao);

    return RitualCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      glowEffect: false,
      child: InkWell(
        onTap: () => _showNoteDialog(note: note),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.35),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.titulo.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.paleWhite,
                          fontFamily: 'Montserrat',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Text(
                              note.categoria,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: color,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dataFormatada,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.coldGray,
                              fontFamily: 'SpaceMono',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => _confirmDelete(note),
                  color: AppTheme.ritualRed,
                  tooltip: 'Excluir',
                ),
              ],
            ),
            if (note.conteudo.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(color: AppTheme.coldGray, height: 1),
              const SizedBox(height: 12),
              Text(
                note.conteudo,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.coldGray,
                  fontFamily: 'Montserrat',
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 50).ms, duration: 300.ms)
        .slideX(begin: -0.1, end: 0);
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
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
    }
  }

  Future<void> _showNoteDialog({Note? note}) async {
    final isEditing = note != null;
    final tituloController = TextEditingController(text: note?.titulo ?? '');
    final conteudoController = TextEditingController(text: note?.conteudo ?? '');
    String categoriaSelecionada = note?.categoria ?? 'Outro';

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: RitualCard(
          glowEffect: true,
          glowColor: _categoriasColors[categoriaSelecionada] ?? AppTheme.etherealPurple,
          padding: const EdgeInsets.all(20),
          ritualCorners: true,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _categoriasIcons[categoriaSelecionada] ?? Icons.note,
                      size: 40,
                      color: _categoriasColors[categoriaSelecionada] ?? AppTheme.etherealPurple,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isEditing ? 'EDITAR NOTA' : 'NOVA NOTA',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _categoriasColors[categoriaSelecionada] ?? AppTheme.etherealPurple,
                        fontFamily: 'BebasNeue',
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: tituloController,
                      style: const TextStyle(
                        color: AppTheme.paleWhite,
                        fontFamily: 'Montserrat',
                      ),
                      decoration: InputDecoration(
                        labelText: 'Título',
                        hintText: 'Ex: Sessão 1 - Encontro',
                        labelStyle: const TextStyle(color: AppTheme.coldGray),
                        hintStyle: const TextStyle(color: AppTheme.coldGray),
                        filled: true,
                        fillColor: AppTheme.obscureGray,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _categoriasColors[categoriaSelecionada] ?? AppTheme.etherealPurple,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.coldGray, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _categoriasColors[categoriaSelecionada] ?? AppTheme.etherealPurple,
                            width: 2,
                          ),
                        ),
                      ),
                      autofocus: !isEditing,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: categoriaSelecionada,
                      dropdownColor: AppTheme.obscureGray,
                      style: const TextStyle(
                        color: AppTheme.paleWhite,
                        fontFamily: 'Montserrat',
                      ),
                      decoration: InputDecoration(
                        labelText: 'Categoria',
                        labelStyle: const TextStyle(color: AppTheme.coldGray),
                        filled: true,
                        fillColor: AppTheme.obscureGray,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _categoriasColors[categoriaSelecionada] ?? AppTheme.etherealPurple,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.coldGray, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _categoriasColors[categoriaSelecionada] ?? AppTheme.etherealPurple,
                            width: 2,
                          ),
                        ),
                      ),
                      items: _categorias
                          .where((c) => c != 'Todas')
                          .map((categoria) {
                        final color = _categoriasColors[categoria] ?? AppTheme.coldGray;
                        return DropdownMenuItem(
                          value: categoria,
                          child: Row(
                            children: [
                              Icon(_categoriasIcons[categoria], size: 20, color: color),
                              const SizedBox(width: 12),
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
                      style: const TextStyle(
                        color: AppTheme.paleWhite,
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Conteúdo',
                        hintText: 'Escreva sua nota aqui...',
                        labelStyle: const TextStyle(color: AppTheme.coldGray),
                        hintStyle: const TextStyle(color: AppTheme.coldGray),
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: AppTheme.obscureGray,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _categoriasColors[categoriaSelecionada] ?? AppTheme.etherealPurple,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.coldGray, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _categoriasColors[categoriaSelecionada] ?? AppTheme.etherealPurple,
                            width: 2,
                          ),
                        ),
                      ),
                      maxLines: 8,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GlowingButton(
                            label: 'Cancelar',
                            onPressed: () => Navigator.pop(context),
                            style: GlowingButtonStyle.secondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GlowingButton(
                            label: isEditing ? 'Salvar' : 'Criar',
                            icon: isEditing ? Icons.save : Icons.add,
                            onPressed: () async {
                              if (tituloController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('O título não pode estar vazio'),
                                    backgroundColor: AppTheme.alertYellow,
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
                                        isEditing ? 'Nota atualizada!' : 'Nota criada!',
                                      ),
                                      backgroundColor: AppTheme.mutagenGreen,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erro: $e'),
                                      backgroundColor: AppTheme.ritualRed,
                                    ),
                                  );
                                }
                              }
                            },
                            style: GlowingButtonStyle.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9)),
      ),
    );
  }

  Future<void> _confirmDelete(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: RitualCard(
          glowEffect: true,
          glowColor: AppTheme.ritualRed,
          padding: const EdgeInsets.all(24),
          ritualCorners: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: AppTheme.ritualRed,
              ),
              const SizedBox(height: 16),
              const Text(
                'EXCLUIR NOTA',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ritualRed,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Deseja realmente excluir a nota "${note.titulo}"?',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.paleWhite,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlowingButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.pop(context, false),
                      style: GlowingButtonStyle.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlowingButton(
                      label: 'Excluir',
                      icon: Icons.delete,
                      onPressed: () => Navigator.pop(context, true),
                      style: GlowingButtonStyle.danger,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9)),
      ),
    );

    if (confirm == true) {
      try {
        await _databaseService.deleteNote(note.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nota excluída'),
              backgroundColor: AppTheme.mutagenGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
              backgroundColor: AppTheme.ritualRed,
            ),
          );
        }
      }
    }
  }
}
