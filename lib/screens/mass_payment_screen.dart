import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/local_database_service.dart';

class MassPaymentScreen extends StatefulWidget {
  const MassPaymentScreen({super.key});

  @override
  State<MassPaymentScreen> createState() => _MassPaymentScreenState();
}

class _MassPaymentScreenState extends State<MassPaymentScreen> {
  final LocalDatabaseService _databaseService = LocalDatabaseService();
  final TextEditingController _valorController = TextEditingController();
  final Map<String, bool> _selectedCharacters = {};
  bool _isLoading = true;
  bool _isProcessing = false;
  List<Character> _allCharacters = [];
  bool _selectAll = false;
  String _tipoOperacao = 'adicionar'; // 'adicionar' ou 'remover'

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _loadCharacters() async {
    try {
      final stream = _databaseService.getAllCharacters();
      await for (final characters in stream) {
        if (mounted) {
          setState(() {
            _allCharacters = characters;
            _isLoading = false;
          });
        }
        break;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _processarPagamentos() async {
    final valor = int.tryParse(_valorController.text);

    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um valor válido maior que zero'),
        ),
      );
      return;
    }

    final selectedIds = _selectedCharacters.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos um personagem'),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      int contador = 0;

      for (final id in selectedIds) {
        final character = _allCharacters.firstWhere((c) => c.id == id);
        int novoCredito;

        if (_tipoOperacao == 'adicionar') {
          novoCredito = character.creditos + valor;
        } else {
          novoCredito = (character.creditos - valor).clamp(0, 999999999);
        }

        await _databaseService.updateCharacterStatus(
          characterId: id,
          creditos: novoCredito,
        );

        contador++;
      }

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _selectedCharacters.clear();
          _selectAll = false;
          _valorController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$contador personagem(s) ${_tipoOperacao == "adicionar" ? "receberam" : "tiveram"} '
              '${_tipoOperacao == "adicionar" ? "+" : "-"}$valor créditos!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao processar pagamentos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamentos em Massa'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allCharacters.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum personagem disponível.\nCrie personagens primeiro.',
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: [
                    // Card de Controles
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.monetization_on,
                                    color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'OPERAÇÃO EM MASSA',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Tipo de Operação
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    value: 'adicionar',
                                    groupValue: _tipoOperacao,
                                    onChanged: (value) {
                                      setState(() {
                                        _tipoOperacao = value!;
                                      });
                                    },
                                    title: const Row(
                                      children: [
                                        Icon(Icons.add_circle, color: Colors.green),
                                        SizedBox(width: 8),
                                        Text('Adicionar'),
                                      ],
                                    ),
                                    dense: true,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    value: 'remover',
                                    groupValue: _tipoOperacao,
                                    onChanged: (value) {
                                      setState(() {
                                        _tipoOperacao = value!;
                                      });
                                    },
                                    title: const Row(
                                      children: [
                                        Icon(Icons.remove_circle, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Remover'),
                                      ],
                                    ),
                                    dense: true,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Campo de Valor
                            TextField(
                              controller: _valorController,
                              decoration: InputDecoration(
                                labelText: 'Valor (Créditos)',
                                hintText: 'Ex: 1000',
                                prefixIcon: Icon(
                                  _tipoOperacao == 'adicionar'
                                      ? Icons.add
                                      : Icons.remove,
                                  color: _tipoOperacao == 'adicionar'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),

                            const SizedBox(height: 16),

                            // Botão Processar
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isProcessing ? null : _processarPagamentos,
                                icon: _isProcessing
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(_tipoOperacao == 'adicionar'
                                        ? Icons.add_circle
                                        : Icons.remove_circle),
                                label: Text(
                                  _isProcessing
                                      ? 'Processando...'
                                      : _tipoOperacao == 'adicionar'
                                          ? 'Adicionar Créditos'
                                          : 'Remover Créditos',
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Lista de Personagens
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'SELECIONAR PERSONAGENS',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            '${_selectedCharacters.values.where((v) => v).length}/${_allCharacters.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Selecionar Todos
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CheckboxListTile(
                        value: _selectAll,
                        onChanged: (value) {
                          setState(() {
                            _selectAll = value ?? false;
                            for (var character in _allCharacters) {
                              _selectedCharacters[character.id] = _selectAll;
                            }
                          });
                        },
                        title: const Text(
                          'Selecionar Todos',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        tileColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Lista de Personagens
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _allCharacters.length,
                        itemBuilder: (context, index) {
                          final character = _allCharacters[index];
                          final isSelected =
                              _selectedCharacters[character.id] ?? false;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: CheckboxListTile(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCharacters[character.id] = value ?? false;
                                  _selectAll = _selectedCharacters.values
                                      .where((v) => v)
                                      .length ==
                                      _allCharacters.length;
                                });
                              },
                              secondary: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                child: Text(
                                  character.nome.isNotEmpty
                                      ? character.nome[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                character.nome,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${character.classe} • NEX ${character.nex}%\n'
                                'Créditos Atuais: ${character.creditos}',
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
