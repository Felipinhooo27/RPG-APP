import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/local_database_service.dart';
import '../widgets/hex_loading.dart';
import '../widgets/empty_state.dart';
import '../widgets/ritual_card.dart';
import '../widgets/glowing_button.dart';

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
      _showModernDialog(
        title: 'Valor Inválido',
        message: 'Digite um valor válido maior que zero',
        isError: true,
      );
      return;
    }

    final selectedIds = _selectedCharacters.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedIds.isEmpty) {
      _showModernDialog(
        title: 'Nenhum Personagem',
        message: 'Selecione pelo menos um personagem',
        isError: true,
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

        _showModernDialog(
          title: 'Sucesso',
          message: '$contador personagem(s) ${_tipoOperacao == "adicionar" ? "receberam" : "tiveram"} '
              '${_tipoOperacao == "adicionar" ? "+" : "-"}$valor créditos!',
          isError: false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        _showModernDialog(
          title: 'Erro',
          message: 'Erro ao processar pagamentos: $e',
          isError: true,
        );
      }
    }
  }

  void _showModernDialog({
    required String title,
    required String message,
    required bool isError,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: RitualCard(
          glowEffect: true,
          glowColor: isError ? Colors.red : Colors.green,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                size: 48,
                color: isError ? Colors.red : Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              GlowingButton.primary(
                label: 'OK',
                fullWidth: true,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamentos em Massa'),
      ),
      body: _isLoading
          ? const Center(child: HexLoading.large(message: 'Carregando personagens...'))
          : _allCharacters.isEmpty
              ? const EmptyState.noCharacters()
              : Column(
                  children: [
                    // Card de Controles - RitualCard
                    RitualCard(
                      glowEffect: true,
                      glowColor: _tipoOperacao == 'adicionar' ? Colors.green : Colors.red,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.monetization_on,
                                  color: _tipoOperacao == 'adicionar' ? Colors.green : Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                'OPERAÇÃO EM MASSA',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: _tipoOperacao == 'adicionar' ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Tipo de Operação com RadioListTile
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),

                          const SizedBox(height: 16),

                          // Botão Processar - GlowingButton
                          GlowingButton(
                            label: _isProcessing
                                ? 'Processando...'
                                : _tipoOperacao == 'adicionar'
                                    ? 'Adicionar Créditos'
                                    : 'Remover Créditos',
                            onPressed: _isProcessing ? null : _processarPagamentos,
                            style: _tipoOperacao == 'adicionar'
                                ? GlowingButtonStyle.primary
                                : GlowingButtonStyle.danger,
                            icon: _tipoOperacao == 'adicionar'
                                ? Icons.add_circle
                                : Icons.remove_circle,
                            isLoading: _isProcessing,
                            fullWidth: true,
                          ),
                        ],
                      ),
                    ),

                    // Lista de Personagens Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'SELECIONAR PERSONAGENS',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${_selectedCharacters.values.where((v) => v).length}/${_allCharacters.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Selecionar Todos - RitualCard
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: RitualCard(
                        glowEffect: false,
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Lista de Personagens - RitualCard para cada character
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _allCharacters.length,
                        itemBuilder: (context, index) {
                          final character = _allCharacters[index];
                          final isSelected =
                              _selectedCharacters[character.id] ?? false;

                          return RitualCard(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            glowEffect: isSelected,
                            glowColor: Colors.cyan,
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
                                backgroundColor: isSelected ? Colors.cyan : Colors.white24,
                                radius: 20,
                                child: Text(
                                  character.nome.isNotEmpty
                                      ? character.nome[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              title: Text(
                                character.nome,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                '${character.classe} • NEX ${character.nex}%\n'
                                'Créditos: ${character.creditos}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              isThreeLine: true,
                              contentPadding: EdgeInsets.zero,
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
