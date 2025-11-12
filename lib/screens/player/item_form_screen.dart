import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/item.dart';
import '../../core/database/item_repository.dart';

/// Formulário de criação/edição de item com campos dinâmicos
/// Design flat seguindo padrão Hexatombe (sem border radius)
class ItemFormScreen extends StatefulWidget {
  final String characterId;
  final Item? itemToEdit;

  const ItemFormScreen({
    super.key,
    required this.characterId,
    this.itemToEdit,
  });

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemRepo = ItemRepository();
  final _uuid = const Uuid();

  // Controllers
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _quantidadeController = TextEditingController(text: '1');
  final _pesoController = TextEditingController(text: '1');

  // Campos de Arma
  final _formulaDanoController = TextEditingController();
  final _multiplicadorCriticoController = TextEditingController();
  final _efeitoCriticoController = TextEditingController();
  final _efeitoMaldicaoController = TextEditingController();

  // Campos de Cura
  final _formulaCuraController = TextEditingController();
  final _efeitoAdicionalController = TextEditingController();

  // Campos de Equipamento
  final _defesaBonusController = TextEditingController();

  // Estado
  ItemType _selectedTipo = ItemType.equipamento;
  bool _isAmaldicoado = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      _loadExistingItem();
    }
  }

  void _loadExistingItem() {
    final item = widget.itemToEdit!;
    _nomeController.text = item.nome;
    _descricaoController.text = item.descricao;
    _categoriaController.text = item.categoria ?? '';
    _quantidadeController.text = item.quantidade.toString();
    _pesoController.text = item.espaco.toString();
    _selectedTipo = item.tipo;

    // Arma
    _formulaDanoController.text = item.formulaDano ?? '';
    _multiplicadorCriticoController.text = item.multiplicadorCritico?.toString() ?? '';
    _efeitoCriticoController.text = item.efeitoCritico ?? '';
    _efeitoMaldicaoController.text = item.efeitoMaldicao ?? '';
    _isAmaldicoado = item.isAmaldicoado;

    // Cura
    _formulaCuraController.text = item.formulaCura ?? '';
    _efeitoAdicionalController.text = item.efeitoAdicional ?? '';

    // Equipamento
    _defesaBonusController.text = item.defesaBonus?.toString() ?? '';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _categoriaController.dispose();
    _quantidadeController.dispose();
    _pesoController.dispose();
    _formulaDanoController.dispose();
    _multiplicadorCriticoController.dispose();
    _efeitoCriticoController.dispose();
    _efeitoMaldicaoController.dispose();
    _formulaCuraController.dispose();
    _efeitoAdicionalController.dispose();
    _defesaBonusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: AppColors.darkGray,
        elevation: 0,
        title: Text(
          widget.itemToEdit != null ? 'EDITAR ITEM' : 'NOVO ITEM',
          style: AppTextStyles.title,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Nome
            _buildLabel('NOME DO ITEM', required: true),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nomeController,
              hint: 'Ex: Espada Longa, Poção de Cura',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome é obrigatório';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Tipo
            _buildLabel('TIPO', required: true),
            const SizedBox(height: 8),
            _buildTipoDropdown(),

            const SizedBox(height: 24),

            // Categoria (opcional)
            _buildLabel('CATEGORIA (Opcional)'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _categoriaController,
              hint: 'Ex: Armadura Pesada, Espada de Duas Mãos',
            ),

            const SizedBox(height: 24),

            // Quantidade e Peso
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('QUANTIDADE', required: true),
                      const SizedBox(height: 8),
                      _buildNumberField(
                        controller: _quantidadeController,
                        hint: '1',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('PESO (kg)', required: true),
                      const SizedBox(height: 8),
                      _buildNumberField(
                        controller: _pesoController,
                        hint: '1',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Descrição
            _buildLabel('DESCRIÇÃO'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _descricaoController,
              hint: 'Descreva o item...',
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            // Campos dinâmicos por tipo
            if (_selectedTipo == ItemType.arma) ..._buildArmaFields(),
            if (_selectedTipo == ItemType.cura) ..._buildCuraFields(),
            if (_selectedTipo == ItemType.equipamento) ..._buildEquipamentoFields(),

            const SizedBox(height: 32),

            // Botões
            Row(
              children: [
                Expanded(
                  child: _buildCancelButton(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _buildSaveButton(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Text(
      required ? '$text *' : text,
      style: AppTextStyles.uppercase.copyWith(
        fontSize: 11,
        color: AppColors.silver.withOpacity(0.7),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: AppTextStyles.body.copyWith(color: AppColors.lightGray),
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(
          color: AppColors.silver.withOpacity(0.3),
        ),
        filled: true,
        fillColor: AppColors.darkGray,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.silver),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.silver.withOpacity(0.3)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.magenta, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      style: AppTextStyles.body.copyWith(color: AppColors.lightGray),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Obrigatório';
        }
        if (int.tryParse(value) == null) {
          return 'Número inválido';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(
          color: AppColors.silver.withOpacity(0.3),
        ),
        filled: true,
        fillColor: AppColors.darkGray,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.silver),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.silver.withOpacity(0.3)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.magenta, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildTipoDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border.all(color: AppColors.silver.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ItemType>(
          value: _selectedTipo,
          isExpanded: true,
          dropdownColor: AppColors.darkGray,
          style: AppTextStyles.body.copyWith(color: AppColors.lightGray),
          onChanged: (ItemType? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedTipo = newValue;
              });
            }
          },
          items: ItemType.values.map((ItemType tipo) {
            return DropdownMenuItem<ItemType>(
              value: tipo,
              child: Text(_getTipoNome(tipo)),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getTipoNome(ItemType tipo) {
    switch (tipo) {
      case ItemType.arma:
        return 'Arma';
      case ItemType.cura:
        return 'Cura / Consumível de Cura';
      case ItemType.municao:
        return 'Munição';
      case ItemType.equipamento:
        return 'Equipamento / Armadura';
      case ItemType.consumivel:
        return 'Consumível';
    }
  }

  List<Widget> _buildArmaFields() {
    return [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          border: Border.all(color: AppColors.neonRed.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PROPRIEDADES DE ARMA',
              style: AppTextStyles.uppercase.copyWith(
                fontSize: 12,
                color: AppColors.neonRed,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Fórmula de Dano
            _buildLabel('FÓRMULA DE DANO'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _formulaDanoController,
              hint: 'Ex: 2d6+8, 1d8+2',
            ),

            const SizedBox(height: 16),

            // Multiplicador Crítico
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('CRÍTICO (x)'),
                      const SizedBox(height: 8),
                      _buildNumberField(
                        controller: _multiplicadorCriticoController,
                        hint: '2',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('EFEITO CRÍTICO'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _efeitoCriticoController,
                        hint: 'Ex: Sangramento',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Amaldiçoado
            InkWell(
              onTap: () {
                setState(() {
                  _isAmaldicoado = !_isAmaldicoado;
                });
              },
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _isAmaldicoado ? AppColors.neonRed : Colors.transparent,
                      border: Border.all(
                        color: _isAmaldicoado ? AppColors.neonRed : AppColors.silver,
                        width: 2,
                      ),
                    ),
                    child: _isAmaldicoado
                        ? const Icon(Icons.check, color: AppColors.deepBlack, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'ARMA AMALDIÇOADA',
                    style: AppTextStyles.uppercase.copyWith(
                      fontSize: 11,
                      color: _isAmaldicoado ? AppColors.neonRed : AppColors.silver,
                    ),
                  ),
                ],
              ),
            ),

            if (_isAmaldicoado) ...[
              const SizedBox(height: 16),
              _buildLabel('EFEITO DA MALDIÇÃO'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _efeitoMaldicaoController,
                hint: 'Descreva a maldição...',
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _buildCuraFields() {
    return [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          border: Border.all(color: AppColors.conhecimentoGreen.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PROPRIEDADES DE CURA',
              style: AppTextStyles.uppercase.copyWith(
                fontSize: 12,
                color: AppColors.conhecimentoGreen,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Fórmula de Cura
            _buildLabel('FÓRMULA DE CURA'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _formulaCuraController,
              hint: 'Ex: 1d4+2, 2d6',
            ),

            const SizedBox(height: 16),

            // Efeito Adicional
            _buildLabel('EFEITO ADICIONAL'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _efeitoAdicionalController,
              hint: 'Ex: Remove 1 condição negativa',
              maxLines: 2,
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _buildEquipamentoFields() {
    return [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          border: Border.all(color: AppColors.vigBlue.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PROPRIEDADES DE EQUIPAMENTO',
              style: AppTextStyles.uppercase.copyWith(
                fontSize: 12,
                color: AppColors.vigBlue,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Bônus de Defesa
            _buildLabel('BÔNUS DE DEFESA (para armaduras)'),
            const SizedBox(height: 8),
            _buildNumberField(
              controller: _defesaBonusController,
              hint: '0',
            ),
            const SizedBox(height: 8),
            Text(
              'Deixe em branco ou 0 se não for armadura',
              style: TextStyle(
                fontSize: 9,
                color: AppColors.silver.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ];
  }

  Widget _buildCancelButton() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.silver.withOpacity(0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: Text(
              'CANCELAR',
              style: AppTextStyles.uppercase.copyWith(
                fontSize: 12,
                color: AppColors.silver,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.magenta,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _saveItem,
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.deepBlack,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.itemToEdit != null ? 'SALVAR' : 'CRIAR ITEM',
                    style: AppTextStyles.uppercase.copyWith(
                      fontSize: 12,
                      color: AppColors.deepBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final item = Item(
        id: widget.itemToEdit?.id ?? _uuid.v4(),
        characterId: widget.characterId,
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim(),
        tipo: _selectedTipo,
        categoria: _categoriaController.text.trim().isEmpty
            ? null
            : _categoriaController.text.trim(),
        quantidade: int.parse(_quantidadeController.text),
        espaco: int.parse(_pesoController.text),
        // Arma
        formulaDano: _formulaDanoController.text.trim().isEmpty
            ? null
            : _formulaDanoController.text.trim(),
        multiplicadorCritico: _multiplicadorCriticoController.text.trim().isEmpty
            ? null
            : int.tryParse(_multiplicadorCriticoController.text),
        efeitoCritico: _efeitoCriticoController.text.trim().isEmpty
            ? null
            : _efeitoCriticoController.text.trim(),
        isAmaldicoado: _isAmaldicoado,
        efeitoMaldicao: _efeitoMaldicaoController.text.trim().isEmpty
            ? null
            : _efeitoMaldicaoController.text.trim(),
        // Cura
        formulaCura: _formulaCuraController.text.trim().isEmpty
            ? null
            : _formulaCuraController.text.trim(),
        efeitoAdicional: _efeitoAdicionalController.text.trim().isEmpty
            ? null
            : _efeitoAdicionalController.text.trim(),
        // Equipamento
        defesaBonus: _defesaBonusController.text.trim().isEmpty
            ? null
            : int.tryParse(_defesaBonusController.text),
      );

      if (widget.itemToEdit == null) {
        await _itemRepo.create(item);
      } else {
        await _itemRepo.update(item);
      }

      if (mounted) {
        Navigator.pop(context, true); // Retorna true para indicar sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.itemToEdit != null
                  ? '${item.nome} atualizado!'
                  : '${item.nome} criado!',
            ),
            backgroundColor: AppColors.conhecimentoGreen,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar item: $e'),
            backgroundColor: AppColors.neonRed,
          ),
        );
      }
    }
  }
}
