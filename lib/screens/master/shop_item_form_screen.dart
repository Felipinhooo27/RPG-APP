import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/shop.dart';
import '../../models/item.dart';

/// Formulário de item de loja
class ShopItemFormScreen extends StatefulWidget {
  final ShopItem? itemToEdit;

  const ShopItemFormScreen({super.key, this.itemToEdit});

  @override
  State<ShopItemFormScreen> createState() => _ShopItemFormScreenState();
}

class _ShopItemFormScreenState extends State<ShopItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  // Controllers básicos
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController(text: '10');
  final _pesoController = TextEditingController(text: '1');
  final _patenteController = TextEditingController(text: '0');

  // Controllers de Arma
  final _formulaDanoController = TextEditingController();
  final _multiplicadorCriticoController = TextEditingController();
  final _efeitoCriticoController = TextEditingController();
  final _efeitoMaldicaoController = TextEditingController();

  // Controllers de Cura
  final _formulaCuraController = TextEditingController();
  final _efeitoAdicionalController = TextEditingController();

  ItemType _selectedTipo = ItemType.equipamento;
  bool _isAmaldicoado = false;

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
    _precoController.text = item.preco.toString();
    _pesoController.text = item.espacoUnitario.toString();
    _patenteController.text = item.patenteMinima.toString();
    _selectedTipo = item.tipo;

    _formulaDanoController.text = item.formulaDano ?? '';
    _multiplicadorCriticoController.text = item.multiplicadorCritico?.toString() ?? '';
    _efeitoCriticoController.text = item.efeitoCritico ?? '';
    _efeitoMaldicaoController.text = item.efeitoMaldicao ?? '';
    _isAmaldicoado = item.isAmaldicoado;

    _formulaCuraController.text = item.formulaCura ?? '';
    _efeitoAdicionalController.text = item.efeitoAdicional ?? '';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _pesoController.dispose();
    _patenteController.dispose();
    _formulaDanoController.dispose();
    _multiplicadorCriticoController.dispose();
    _efeitoCriticoController.dispose();
    _efeitoMaldicaoController.dispose();
    _formulaCuraController.dispose();
    _efeitoAdicionalController.dispose();
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

            _buildLabel('TIPO', required: true),
            const SizedBox(height: 8),
            _buildTipoDropdown(),

            const SizedBox(height: 24),

            // Preço, Peso e Patente
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('PREÇO (\$)', required: true),
                      const SizedBox(height: 8),
                      _buildNumberField(controller: _precoController, hint: '10'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('PESO (kg)', required: true),
                      const SizedBox(height: 8),
                      _buildNumberField(controller: _pesoController, hint: '1'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('PATENTE', required: true),
                      const SizedBox(height: 8),
                      _buildNumberField(controller: _patenteController, hint: '0'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

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

  Widget _buildNumberField({required TextEditingController controller, String? hint}) {
    return TextFormField(
      controller: controller,
      style: AppTextStyles.body.copyWith(color: AppColors.lightGray),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Obrigatório';
        }
        if (int.tryParse(value) == null) {
          return 'Inválido';
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

            _buildLabel('FÓRMULA DE DANO'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _formulaDanoController,
              hint: 'Ex: 2d6+8, 1d8+2',
            ),

            const SizedBox(height: 16),

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

            _buildLabel('FÓRMULA DE CURA'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _formulaCuraController,
              hint: 'Ex: 1d4+2, 2d6',
            ),

            const SizedBox(height: 16),

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
          onTap: _saveItem,
          child: Center(
            child: Text(
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

  void _saveItem() {
    if (!_formKey.currentState!.validate()) return;

    final item = ShopItem(
      id: widget.itemToEdit?.id ?? _uuid.v4(),
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim(),
      tipo: _selectedTipo,
      preco: int.parse(_precoController.text),
      espacoUnitario: int.parse(_pesoController.text),
      patenteMinima: int.parse(_patenteController.text),
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
      formulaCura: _formulaCuraController.text.trim().isEmpty
          ? null
          : _formulaCuraController.text.trim(),
      efeitoAdicional: _efeitoAdicionalController.text.trim().isEmpty
          ? null
          : _efeitoAdicionalController.text.trim(),
    );

    Navigator.pop(context, item);
  }
}
