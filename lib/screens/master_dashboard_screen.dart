import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/character.dart';
import '../services/local_database_service.dart';
import 'character_list_screen.dart';
import 'dice_roller_screen.dart';
import 'iniciativa_screen.dart';
import 'notes_screen.dart';
import 'advanced_character_generator_screen.dart';
import 'mass_payment_screen.dart';

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
  final Set<String> _selectedCharacters = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard do Mestre'),
      ),
      body: StreamBuilder<List<Character>>(
        stream: _databaseService.getAllCharacters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final characters = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Card de Estatísticas
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESTATÍSTICAS',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatCard(
                            icon: Icons.people,
                            label: 'Total',
                            value: characters.length.toString(),
                            color: Colors.blue,
                          ),
                          _StatCard(
                            icon: Icons.favorite,
                            label: 'PV Médio',
                            value: _calculateAveragePV(characters),
                            color: Colors.red,
                          ),
                          _StatCard(
                            icon: Icons.stars,
                            label: 'NEX Médio',
                            value: _calculateAverageNEX(characters),
                            color: Colors.amber,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Ações do Mestre
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AÇÕES DO MESTRE',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.share),
                        title: const Text('Exportar Personagens'),
                        subtitle: const Text('Compartilhar via WhatsApp'),
                        onTap: () => _showExportDialog(characters),
                      ),
                      ListTile(
                        leading: const Icon(Icons.download),
                        title: const Text('Importar Personagens'),
                        subtitle: const Text('Importar do JSON'),
                        onTap: _showImportDialog,
                      ),
                      ListTile(
                        leading: const Icon(Icons.auto_awesome),
                        title: const Text('Gerador Avançado'),
                        subtitle: const Text('Civil, Soldado, Líder, Deus...'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdvancedCharacterGeneratorScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.monetization_on),
                        title: const Text('Pagamentos em Massa'),
                        subtitle: const Text('Adicionar/remover créditos'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MassPaymentScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Lista de Personagens
              if (characters.isNotEmpty) ...[
                Text(
                  'PERSONAGENS NA CAMPANHA',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...characters.map((character) => Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            character.nome.isNotEmpty ? character.nome[0].toUpperCase() : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(character.nome),
                        subtitle: Text('${character.classe} - NEX ${character.nex}%'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'PV: ${character.pvAtual}/${character.pvMax}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }

  String _calculateAveragePV(List<Character> characters) {
    if (characters.isEmpty) return '0';
    final total = characters.fold<int>(0, (sum, char) => sum + char.pvMax);
    return (total / characters.length).toStringAsFixed(0);
  }

  String _calculateAverageNEX(List<Character> characters) {
    if (characters.isEmpty) return '0';
    final total = characters.fold<int>(0, (sum, char) => sum + char.nex);
    return (total / characters.length).toStringAsFixed(0);
  }

  Future<void> _showExportDialog(List<Character> characters) async {
    if (characters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum personagem para exportar')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => _ExportDialog(
        characters: characters,
        databaseService: _databaseService,
      ),
    );
  }

  Future<void> _showImportDialog() async {
    await showDialog(
      context: context,
      builder: (context) => _ImportDialog(
        databaseService: _databaseService,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}

class _ExportDialog extends StatefulWidget {
  final List<Character> characters;
  final LocalDatabaseService databaseService;

  const _ExportDialog({
    required this.characters,
    required this.databaseService,
  });

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  final Set<String> _selectedIds = {};
  bool _selectAll = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Exportar Personagens'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Selecionar Todos'),
              value: _selectAll,
              onChanged: (value) {
                setState(() {
                  _selectAll = value ?? false;
                  if (_selectAll) {
                    _selectedIds.addAll(widget.characters.map((c) => c.id));
                  } else {
                    _selectedIds.clear();
                  }
                });
              },
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.characters.length,
                itemBuilder: (context, index) {
                  final character = widget.characters[index];
                  return CheckboxListTile(
                    title: Text(character.nome),
                    subtitle: Text(character.classe),
                    value: _selectedIds.contains(character.id),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedIds.add(character.id);
                        } else {
                          _selectedIds.remove(character.id);
                        }
                        _selectAll = _selectedIds.length == widget.characters.length;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _selectedIds.isEmpty ? null : _exportCharacters,
          icon: const Icon(Icons.share),
          label: const Text('Compartilhar'),
        ),
      ],
    );
  }

  Future<void> _exportCharacters() async {
    final selectedCharacters = widget.characters
        .where((c) => _selectedIds.contains(c.id))
        .toList();

    // Converter para JSON formatado
    final jsonData = selectedCharacters.map((c) => c.toMap()).toList();
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

    // Compartilhar via WhatsApp ou outros apps
    await Share.share(
      jsonString,
      subject: 'Personagens de Ordem Paranormal RPG',
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${selectedCharacters.length} personagem(s) exportado(s)!'),
        ),
      );
    }
  }
}

class _ImportDialog extends StatefulWidget {
  final LocalDatabaseService databaseService;

  const _ImportDialog({required this.databaseService});

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  final TextEditingController _jsonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Importar Personagens'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Cole o JSON dos personagens abaixo:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _jsonController,
              decoration: const InputDecoration(
                hintText: 'Cole o JSON aqui...',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _importCharacters,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: const Text('Importar'),
        ),
      ],
    );
  }

  Future<void> _importCharacters() async {
    final jsonText = _jsonController.text.trim();

    if (jsonText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cole o JSON primeiro')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Decodificar JSON
      final decoded = jsonDecode(jsonText);

      List<Character> characters = [];

      if (decoded is List) {
        // Array de personagens
        for (var item in decoded) {
          characters.add(Character.fromMap(item as Map<String, dynamic>));
        }
      } else if (decoded is Map) {
        // Um único personagem
        characters.add(Character.fromMap(decoded as Map<String, dynamic>));
      } else {
        throw Exception('Formato de JSON inválido');
      }

      // Importar para o banco local
      await widget.databaseService.importCharacters(
        characters,
        'master_001', // ID do mestre
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${characters.length} personagem(s) importado(s) com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao importar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
