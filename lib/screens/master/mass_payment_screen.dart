import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/database/character_repository.dart';
import '../../models/character.dart';

/// Tela de Pagamentos em Massa (Mestre)
/// Adiciona ou remove créditos de vários personagens ao mesmo tempo
class MassPaymentScreen extends StatefulWidget {
  const MassPaymentScreen({super.key});

  @override
  State<MassPaymentScreen> createState() => _MassPaymentScreenState();
}

class _MassPaymentScreenState extends State<MassPaymentScreen> {
  final CharacterRepository _repo = CharacterRepository();
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
    setState(() => _isLoading = true);
    try {
      final characters = await _repo.getAll();
      if (mounted) {
        setState(() {
          _allCharacters = characters;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _processarPagamentos() async {
    final valor = int.tryParse(_valorController.text);

    if (valor == null || valor <= 0) {
      _showDialog(
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
      _showDialog(
        title: 'Nenhum Personagem',
        message: 'Selecione pelo menos um personagem',
        isError: true,
      );
      return;
    }

    setState(() => _isProcessing = true);

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

        await _repo.updateResources(
          id: id,
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

        await _loadCharacters(); // Recarrega lista

        _showDialog(
          title: 'Sucesso',
          message: '$contador personagem(s) ${_tipoOperacao == "adicionar" ? "receberam" : "tiveram"} '
              '${_tipoOperacao == "adicionar" ? "+" : "-"}$valor créditos!',
          isError: false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showDialog(
          title: 'Erro',
          message: 'Erro ao processar pagamentos: $e',
          isError: true,
        );
      }
    }
  }

  void _showDialog({
    required String title,
    required String message,
    required bool isError,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? AppColors.neonRed : AppColors.conhecimentoGreen,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              title.toUpperCase(),
              style: AppTextStyles.uppercase.copyWith(
                fontSize: 14,
                color: isError ? AppColors.neonRed : AppColors.conhecimentoGreen,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTextStyles.body.copyWith(color: AppColors.silver),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: isError ? AppColors.neonRed : AppColors.conhecimentoGreen,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: AppColors.darkGray,
        title: Text(
          'PAGAMENTOS EM MASSA',
          style: AppTextStyles.uppercase.copyWith(
            fontSize: 14,
            color: AppColors.scarletRed,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.scarletRed),
            )
          : _allCharacters.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 64,
                        color: AppColors.silver.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'NENHUM PERSONAGEM',
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.silver,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Crie personagens para gerenciar pagamentos',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.silver.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Card de Controles
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.darkGray,
                        border: Border.all(
                          color: (_tipoOperacao == 'adicionar'
                                  ? AppColors.conhecimentoGreen
                                  : AppColors.neonRed)
                              .withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.monetization_on,
                                color: _tipoOperacao == 'adicionar'
                                    ? AppColors.conhecimentoGreen
                                    : AppColors.neonRed,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'OPERAÇÃO EM MASSA',
                                style: AppTextStyles.uppercase.copyWith(
                                  fontSize: 12,
                                  color: _tipoOperacao == 'adicionar'
                                      ? AppColors.conhecimentoGreen
                                      : AppColors.neonRed,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Tipo de Operação
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() => _tipoOperacao = 'adicionar');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _tipoOperacao == 'adicionar'
                                          ? AppColors.conhecimentoGreen.withOpacity(0.2)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: _tipoOperacao == 'adicionar'
                                            ? AppColors.conhecimentoGreen
                                            : AppColors.silver.withOpacity(0.3),
                                        width: _tipoOperacao == 'adicionar' ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_circle,
                                          color: _tipoOperacao == 'adicionar'
                                              ? AppColors.conhecimentoGreen
                                              : AppColors.silver,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'ADICIONAR',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                            color: _tipoOperacao == 'adicionar'
                                                ? AppColors.conhecimentoGreen
                                                : AppColors.silver,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() => _tipoOperacao = 'remover');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _tipoOperacao == 'remover'
                                          ? AppColors.neonRed.withOpacity(0.2)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: _tipoOperacao == 'remover'
                                            ? AppColors.neonRed
                                            : AppColors.silver.withOpacity(0.3),
                                        width: _tipoOperacao == 'remover' ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.remove_circle,
                                          color: _tipoOperacao == 'remover'
                                              ? AppColors.neonRed
                                              : AppColors.silver,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'REMOVER',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                            color: _tipoOperacao == 'remover'
                                                ? AppColors.neonRed
                                                : AppColors.silver,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Campo de Valor
                          TextField(
                            controller: _valorController,
                            style: const TextStyle(color: AppColors.lightGray),
                            decoration: InputDecoration(
                              labelText: 'Valor (Créditos)',
                              hintText: 'Ex: 1000',
                              prefixIcon: Icon(
                                _tipoOperacao == 'adicionar'
                                    ? Icons.add
                                    : Icons.remove,
                                color: _tipoOperacao == 'adicionar'
                                    ? AppColors.conhecimentoGreen
                                    : AppColors.neonRed,
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),

                          const SizedBox(height: 16),

                          // Botão Processar
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isProcessing ? null : _processarPagamentos,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _tipoOperacao == 'adicionar'
                                    ? AppColors.conhecimentoGreen
                                    : AppColors.neonRed,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isProcessing)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  else
                                    Icon(
                                      _tipoOperacao == 'adicionar'
                                          ? Icons.add_circle
                                          : Icons.remove_circle,
                                    ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _isProcessing
                                        ? 'PROCESSANDO...'
                                        : _tipoOperacao == 'adicionar'
                                            ? 'ADICIONAR CRÉDITOS'
                                            : 'REMOVER CRÉDITOS',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Header da Lista
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'SELECIONAR PERSONAGENS',
                            style: AppTextStyles.uppercase.copyWith(
                              fontSize: 11,
                              color: AppColors.silver,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.scarletRed.withOpacity(0.2),
                              border: Border.all(color: AppColors.scarletRed),
                            ),
                            child: Text(
                              '${_selectedCharacters.values.where((v) => v).length}/${_allCharacters.length}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.scarletRed,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Selecionar Todos
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkGray,
                          border: Border.all(
                            color: AppColors.silver.withOpacity(0.3),
                          ),
                        ),
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
                          title: Text(
                            'SELECIONAR TODOS',
                            style: AppTextStyles.uppercase.copyWith(
                              fontSize: 10,
                              color: AppColors.silver,
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.scarletRed,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Lista de Personagens
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _allCharacters.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final character = _allCharacters[index];
                          final isSelected =
                              _selectedCharacters[character.id] ?? false;

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.darkGray,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.scarletRed
                                    : AppColors.silver.withOpacity(0.3),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: CheckboxListTile(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCharacters[character.id] =
                                      value ?? false;
                                  _selectAll = _selectedCharacters.values
                                          .where((v) => v)
                                          .length ==
                                      _allCharacters.length;
                                });
                              },
                              secondary: CircleAvatar(
                                backgroundColor: isSelected
                                    ? AppColors.scarletRed
                                    : AppColors.silver.withOpacity(0.3),
                                radius: 20,
                                child: Text(
                                  character.nome.isNotEmpty
                                      ? character.nome[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? AppColors.deepBlack
                                        : AppColors.silver,
                                  ),
                                ),
                              ),
                              title: Text(
                                character.nome.toUpperCase(),
                                style: AppTextStyles.uppercase.copyWith(
                                  fontSize: 12,
                                  color: AppColors.lightGray,
                                ),
                              ),
                              subtitle: Text(
                                '${character.classe.name.toUpperCase()} • NEX ${character.nex}%\n'
                                'Créditos: \$${character.creditos}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.silver.withOpacity(0.7),
                                ),
                              ),
                              isThreeLine: true,
                              contentPadding: EdgeInsets.zero,
                              activeColor: AppColors.scarletRed,
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
