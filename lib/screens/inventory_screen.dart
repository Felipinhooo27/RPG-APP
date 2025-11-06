import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/character.dart';
import '../models/item.dart';
import '../services/local_database_service.dart';
import '../utils/dice_roller.dart';

class InventoryScreen extends StatefulWidget {
  final Character character;
  final bool isMasterMode;

  const InventoryScreen({
    super.key,
    required this.character,
    required this.isMasterMode,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final LocalDatabaseService _databaseService = LocalDatabaseService();
  final DiceRoller _diceRoller = DiceRoller();
  final _uuid = const Uuid();

  late List<Item> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.character.inventario);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventário'),
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.backpack_outlined,
                    size: 80,
                    color: Colors.white38,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Inventário vazio',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return _ItemCard(
                  item: item,
                  diceRoller: _diceRoller,
                  onEdit: () => _editItem(item),
                  onDelete: () => _deleteItem(item.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Item'),
      ),
    );
  }

  Future<void> _addItem() async {
    final newItem = await showDialog<Item>(
      context: context,
      builder: (context) => _ItemFormDialog(item: null),
    );

    if (newItem != null) {
      setState(() {
        _items.add(newItem.copyWith(id: _uuid.v4()));
      });
      await _saveInventory();
    }
  }

  Future<void> _editItem(Item item) async {
    final updatedItem = await showDialog<Item>(
      context: context,
      builder: (context) => _ItemFormDialog(item: item),
    );

    if (updatedItem != null) {
      setState(() {
        final index = _items.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          _items[index] = updatedItem;
        }
      });
      await _saveInventory();
    }
  }

  Future<void> _deleteItem(String itemId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir este item?'),
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
      setState(() {
        _items.removeWhere((item) => item.id == itemId);
      });
      await _saveInventory();
    }
  }

  Future<void> _saveInventory() async {
    try {
      final updatedCharacter = widget.character.copyWith(inventario: _items);
      await _databaseService.updateCharacter(updatedCharacter);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inventário atualizado!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar inventário: $e')),
        );
      }
    }
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;
  final DiceRoller diceRoller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ItemCard({
    required this.item,
    required this.diceRoller,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                        item.nome,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildBadge(item.tipo, Colors.blue),
                          const SizedBox(width: 8),
                          _buildBadge('Qtd: ${item.quantidade}', Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Excluir'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                ),
              ],
            ),
            if (item.descricao.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.descricao,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (item.isWeapon) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Fórmula de Dano: ${item.formulaDano}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (item.multiplicadorCritico != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Crítico: x${item.multiplicadorCritico}',
                  style: const TextStyle(color: Colors.amber),
                ),
              ],
              if (item.efeitoCritico != null && item.efeitoCritico!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Efeito Crítico: ${item.efeitoCritico}',
                  style: const TextStyle(color: Colors.amber),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rollDamage(context, false),
                      icon: const Icon(Icons.casino),
                      label: const Text('Rolar Dano'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rollDamage(context, true),
                      icon: const Icon(Icons.star),
                      label: const Text('Crítico'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _rollDamage(BuildContext context, bool isCritical) {
    try {
      final result = isCritical && item.multiplicadorCritico != null
          ? diceRoller.rollCritical(item.formulaDano!, item.multiplicadorCritico!)
          : diceRoller.roll(item.formulaDano!);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(isCritical ? 'ACERTO CRÍTICO!' : 'Dano Rolado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Item: ${item.nome}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Fórmula: ${item.formulaDano}'),
              if (isCritical && item.multiplicadorCritico != null)
                Text('Multiplicador: x${item.multiplicadorCritico}'),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                result.detailedResult,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCritical ? Colors.amber.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCritical ? Colors.amber : Colors.red,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      isCritical ? 'DANO CRÍTICO' : 'DANO TOTAL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isCritical ? Colors.amber : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.total.toString(),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isCritical ? Colors.amber : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCritical && item.efeitoCritico != null && item.efeitoCritico!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.efeitoCritico!,
                          style: const TextStyle(color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao rolar dados: $e')),
      );
    }
  }
}

class _ItemFormDialog extends StatefulWidget {
  final Item? item;

  const _ItemFormDialog({this.item});

  @override
  State<_ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<_ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _quantidadeController;
  late TextEditingController _formulaDanoController;
  late TextEditingController _multiplicadorCriticoController;
  late TextEditingController _efeitoCriticoController;

  String _selectedTipo = 'Equipamento';
  final List<String> _tipos = ['Arma', 'Equipamento', 'Consumível'];

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    _nomeController = TextEditingController(text: item?.nome ?? '');
    _descricaoController = TextEditingController(text: item?.descricao ?? '');
    _quantidadeController = TextEditingController(text: item?.quantidade.toString() ?? '1');
    _formulaDanoController = TextEditingController(text: item?.formulaDano ?? '');
    _multiplicadorCriticoController =
        TextEditingController(text: item?.multiplicadorCritico?.toString() ?? '');
    _efeitoCriticoController = TextEditingController(text: item?.efeitoCritico ?? '');

    if (item != null) {
      _selectedTipo = item.tipo;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _quantidadeController.dispose();
    _formulaDanoController.dispose();
    _multiplicadorCriticoController.dispose();
    _efeitoCriticoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Adicionar Item' : 'Editar Item'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedTipo,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: _tipos
                    .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTipo = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantidadeController,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true || int.tryParse(value!) == null) {
                    return 'Número inválido';
                  }
                  return null;
                },
              ),
              if (_selectedTipo == 'Arma') ...[
                const SizedBox(height: 12),
                const Divider(),
                const Text(
                  'PROPRIEDADES DE ARMA',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _formulaDanoController,
                  decoration: const InputDecoration(
                    labelText: 'Fórmula de Dano',
                    hintText: 'ex: 1d8+2',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _multiplicadorCriticoController,
                  decoration: const InputDecoration(
                    labelText: 'Multiplicador Crítico',
                    hintText: 'ex: 2 para x2',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _efeitoCriticoController,
                  decoration: const InputDecoration(
                    labelText: 'Efeito Crítico',
                    hintText: 'Descrição do efeito',
                  ),
                  maxLines: 2,
                ),
              ],
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
          onPressed: _saveItem,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  void _saveItem() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final item = Item(
      id: widget.item?.id ?? '',
      nome: _nomeController.text,
      descricao: _descricaoController.text,
      quantidade: int.parse(_quantidadeController.text),
      tipo: _selectedTipo,
      formulaDano: _selectedTipo == 'Arma' && _formulaDanoController.text.isNotEmpty
          ? _formulaDanoController.text
          : null,
      multiplicadorCritico:
          _multiplicadorCriticoController.text.isNotEmpty
              ? int.tryParse(_multiplicadorCriticoController.text)
              : null,
      efeitoCritico:
          _efeitoCriticoController.text.isNotEmpty ? _efeitoCriticoController.text : null,
    );

    Navigator.pop(context, item);
  }
}
