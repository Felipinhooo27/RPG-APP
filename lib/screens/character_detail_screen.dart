import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/local_database_service.dart';
import 'character_form_screen.dart';
import 'inventory_screen.dart';

class CharacterDetailScreen extends StatefulWidget {
  final Character character;
  final bool isMasterMode;

  const CharacterDetailScreen({
    super.key,
    required this.character,
    required this.isMasterMode,
  });

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  final LocalDatabaseService _databaseService = LocalDatabaseService();

  late int _pvAtual;
  late int _peAtual;
  late int _psAtual;
  late int _creditos;

  @override
  void initState() {
    super.initState();
    _pvAtual = widget.character.pvAtual;
    _peAtual = widget.character.peAtual;
    _psAtual = widget.character.psAtual;
    _creditos = widget.character.creditos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.character.nome),
        actions: [
          if (widget.isMasterMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CharacterFormScreen(
                      character: widget.character,
                      userId: widget.character.createdBy,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Informações Básicas
          _buildInfoCard(),
          const SizedBox(height: 16),

          // Status (PV, PE, PS)
          _buildStatusCard(),
          const SizedBox(height: 16),

          // Créditos
          _buildCreditsCard(),
          const SizedBox(height: 16),

          // Atributos
          _buildAttributesCard(),
          const SizedBox(height: 16),

          // Inventário
          _buildInventoryButton(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'INFORMAÇÕES',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            _buildInfoRow('Patente', widget.character.patente),
            _buildInfoRow('NEX', '${widget.character.nex}%'),
            _buildInfoRow('Origem', widget.character.origem),
            _buildInfoRow('Classe', widget.character.classe),
            _buildInfoRow('Trilha', widget.character.trilha),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? '-' : value),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'STATUS',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            _buildStatusControl(
              'Pontos de Vida (PV)',
              _pvAtual,
              widget.character.pvMax,
              Colors.red,
              (newValue) {
                setState(() {
                  _pvAtual = newValue.clamp(0, widget.character.pvMax);
                });
                _updateStatus(pvAtual: _pvAtual);
              },
            ),
            const SizedBox(height: 16),
            _buildStatusControl(
              'Pontos de Esforço (PE)',
              _peAtual,
              widget.character.peMax,
              Colors.blue,
              (newValue) {
                setState(() {
                  _peAtual = newValue.clamp(0, widget.character.peMax);
                });
                _updateStatus(peAtual: _peAtual);
              },
            ),
            const SizedBox(height: 16),
            _buildStatusControl(
              'Pontos de Sanidade (PS)',
              _psAtual,
              widget.character.psMax,
              Colors.purple,
              (newValue) {
                setState(() {
                  _psAtual = newValue.clamp(0, widget.character.psMax);
                });
                _updateStatus(psAtual: _psAtual);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusControl(
    String label,
    int current,
    int max,
    Color color,
    Function(int) onChanged,
  ) {
    final percentage = max > 0 ? current / max : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: () => onChanged(current - 5),
              icon: const Icon(Icons.remove_circle),
              color: color,
            ),
            IconButton(
              onPressed: () => onChanged(current - 1),
              icon: const Icon(Icons.remove),
              color: color,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$current / $max',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => onChanged(current + 1),
              icon: const Icon(Icons.add),
              color: color,
            ),
            IconButton(
              onPressed: () => onChanged(current + 5),
              icon: const Icon(Icons.add_circle),
              color: color,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreditsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CRÉDITOS',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _creditos = (_creditos - 10).clamp(0, 999999);
                    });
                    _updateStatus(creditos: _creditos);
                  },
                  icon: const Icon(Icons.remove_circle),
                  color: Colors.amber,
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _creditos = (_creditos - 1).clamp(0, 999999);
                    });
                    _updateStatus(creditos: _creditos);
                  },
                  icon: const Icon(Icons.remove),
                  color: Colors.amber,
                ),
                Expanded(
                  child: Text(
                    'T\$ $_creditos',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _creditos = (_creditos + 1).clamp(0, 999999);
                    });
                    _updateStatus(creditos: _creditos);
                  },
                  icon: const Icon(Icons.add),
                  color: Colors.amber,
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _creditos = (_creditos + 10).clamp(0, 999999);
                    });
                    _updateStatus(creditos: _creditos);
                  },
                  icon: const Icon(Icons.add_circle),
                  color: Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ATRIBUTOS',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttributeBadge('FOR', widget.character.forca),
                _buildAttributeBadge('AGI', widget.character.agilidade),
                _buildAttributeBadge('VIG', widget.character.vigor),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttributeBadge('INT', widget.character.inteligencia),
                _buildAttributeBadge('PRE', widget.character.presenca),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeBadge(String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InventoryScreen(
              character: widget.character,
              isMasterMode: widget.isMasterMode,
            ),
          ),
        );
      },
      icon: const Icon(Icons.backpack),
      label: const Text('Ver Inventário'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _updateStatus({
    int? pvAtual,
    int? peAtual,
    int? psAtual,
    int? creditos,
  }) async {
    try {
      await _databaseService.updateCharacterStatus(
        characterId: widget.character.id,
        pvAtual: pvAtual,
        peAtual: peAtual,
        psAtual: psAtual,
        creditos: creditos,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar status: $e')),
        );
      }
    }
  }
}
