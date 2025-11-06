import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/local_database_service.dart';
import 'character_form_screen.dart';
import 'character_detail_screen.dart';

class CharacterListScreen extends StatefulWidget {
  final bool isMasterMode;

  const CharacterListScreen({
    super.key,
    required this.isMasterMode,
  });

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  final LocalDatabaseService _databaseService = LocalDatabaseService();

  // ID do usuário fictício
  final String _userId = 'player_001';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isMasterMode ? 'Todos os Personagens' : 'Meus Personagens'),
      ),
      body: StreamBuilder<List<Character>>(
        stream: widget.isMasterMode
            ? _databaseService.getAllCharacters()
            : _databaseService.getCharactersByUser(_userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro: ${snapshot.error}'),
            );
          }

          final characters = snapshot.data ?? [];

          if (characters.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off,
                    size: 80,
                    color: Colors.white38,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum personagem encontrado',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crie seu primeiro personagem!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white54,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
              return _CharacterCard(
                character: character,
                isMasterMode: widget.isMasterMode,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CharacterDetailScreen(
                        character: character,
                        isMasterMode: widget.isMasterMode,
                      ),
                    ),
                  );
                },
                onDelete: () => _deleteCharacter(character.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CharacterFormScreen(userId: _userId),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Personagem'),
      ),
    );
  }

  Future<void> _deleteCharacter(String characterId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir este personagem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _databaseService.deleteCharacter(characterId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Personagem excluído com sucesso')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir personagem: $e')),
          );
        }
      }
    }
  }
}

class _CharacterCard extends StatelessWidget {
  final Character character;
  final bool isMasterMode;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CharacterCard({
    required this.character,
    required this.isMasterMode,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          character.nome,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${character.classe} - ${character.origem}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatusBadge(
                    label: 'PV',
                    current: character.pvAtual,
                    max: character.pvMax,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 12),
                  _StatusBadge(
                    label: 'PE',
                    current: character.peAtual,
                    max: character.peMax,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _StatusBadge(
                    label: 'PS',
                    current: character.psAtual,
                    max: character.psMax,
                    color: Colors.purple,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.current,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        '$label: $current/$max',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
