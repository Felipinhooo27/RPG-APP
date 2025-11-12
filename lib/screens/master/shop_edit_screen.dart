import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/shop.dart';
import '../../core/database/shop_repository.dart';
import 'shop_item_form_screen.dart';

/// Editor de loja - Criar/Editar lojas completas
class ShopEditScreen extends StatefulWidget {
  final Shop? shopToEdit;

  const ShopEditScreen({super.key, this.shopToEdit});

  @override
  State<ShopEditScreen> createState() => _ShopEditScreenState();
}

class _ShopEditScreenState extends State<ShopEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopRepo = ShopRepository();
  final _uuid = const Uuid();

  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();

  ShopType _selectedTipo = ShopType.mercador;
  List<ShopItem> _itens = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.shopToEdit != null) {
      _loadExistingShop();
    }
  }

  void _loadExistingShop() {
    final shop = widget.shopToEdit!;
    _nomeController.text = shop.nome;
    _descricaoController.text = shop.descricao;
    _selectedTipo = shop.tipo;
    _itens = List.from(shop.itens);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
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
          widget.shopToEdit != null ? 'EDITAR LOJA' : 'NOVA LOJA',
          style: AppTextStyles.title,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Nome
            _buildLabel('NOME DA LOJA', required: true),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nomeController,
              hint: 'Ex: Armaria do João, Taverna da Rosa',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome é obrigatório';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Tipo
            _buildLabel('TIPO DE LOJA', required: true),
            const SizedBox(height: 8),
            _buildTipoDropdown(),

            const SizedBox(height: 24),

            // Descrição
            _buildLabel('DESCRIÇÃO'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _descricaoController,
              hint: 'Descreva a loja...',
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            // Seção de Itens
            _buildItensSection(),

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
    // Text area para descrição - com fundo cinza
    if (maxLines > 1) {
      return Container(
        padding: const EdgeInsets.all(12),
        color: AppColors.darkGray,
        child: TextFormField(
          controller: controller,
          style: AppTextStyles.body.copyWith(color: AppColors.lightGray),
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.silver.withOpacity(0.3),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      );
    }

    // Input normal - apenas linha inferior vermelha
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
        filled: false,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.scarletRed),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.scarletRed.withOpacity(0.5)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.scarletRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildTipoDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.scarletRed.withOpacity(0.5)),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ShopType>(
          value: _selectedTipo,
          isExpanded: true,
          dropdownColor: AppColors.darkGray,
          style: AppTextStyles.body.copyWith(color: AppColors.lightGray),
          icon: Icon(Icons.arrow_drop_down, color: AppColors.scarletRed),
          onChanged: (ShopType? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedTipo = newValue;
              });
            }
          },
          items: ShopType.values.map((ShopType tipo) {
            return DropdownMenuItem<ShopType>(
              value: tipo,
              child: Text(_getTipoNome(tipo)),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getTipoNome(ShopType tipo) {
    switch (tipo) {
      case ShopType.taberna:
        return 'Taberna (Tudo)';
      case ShopType.armaria:
        return 'Armaria (Armas e Munição)';
      case ShopType.farmacia:
        return 'Farmácia (Poções e Cura)';
      case ShopType.mercador:
        return 'Mercador (Variados)';
      case ShopType.forjaria:
        return 'Forjaria (Equipamentos)';
    }
  }

  Widget _buildItensSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ITENS DA LOJA',
              style: AppTextStyles.uppercase.copyWith(
                fontSize: 12,
                color: AppColors.scarletRed,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '(${_itens.length} itens)',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.silver.withOpacity(0.6),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        if (_itens.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Nenhum item adicionado',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.silver.withOpacity(0.5),
                ),
              ),
            ),
          )
        else
          ..._itens.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildItemCard(item, index);
          }).toList(),

        const SizedBox(height: 16),

        // Link para adicionar item
        InkWell(
          onTap: _addItem,
          child: Text(
            '[ + ADICIONAR ITEM ]',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.scarletRed,
              letterSpacing: 1.0,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(ShopItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.deepBlack,
        border: Border.all(color: AppColors.silver.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nome,
                  style: AppTextStyles.uppercase.copyWith(
                    fontSize: 12,
                    color: AppColors.lightGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.preco} • ${item.espacoUnitario}kg',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.silver.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _editItem(index),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.edit, color: AppColors.lightGray, size: 18),
            ),
          ),
          InkWell(
            onTap: () => _removeItem(index),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.delete, color: AppColors.scarletRed, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return InkWell(
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
    );
  }

  Widget _buildSaveButton() {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.scarletRed,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _saveShop,
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.lightGray,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.shopToEdit != null ? 'SALVAR' : 'CRIAR LOJA',
                    style: AppTextStyles.uppercase.copyWith(
                      fontSize: 12,
                      color: AppColors.lightGray,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _addItem() async {
    final newItem = await Navigator.push<ShopItem>(
      context,
      MaterialPageRoute(
        builder: (context) => const ShopItemFormScreen(),
      ),
    );

    if (newItem != null) {
      setState(() {
        _itens.add(newItem);
      });
    }
  }

  Future<void> _editItem(int index) async {
    final editedItem = await Navigator.push<ShopItem>(
      context,
      MaterialPageRoute(
        builder: (context) => ShopItemFormScreen(itemToEdit: _itens[index]),
      ),
    );

    if (editedItem != null) {
      setState(() {
        _itens[index] = editedItem;
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _itens.removeAt(index);
    });
  }

  Future<void> _saveShop() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final shop = Shop(
        id: widget.shopToEdit?.id ?? _uuid.v4(),
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim(),
        tipo: _selectedTipo,
        itens: _itens,
      );

      if (widget.shopToEdit == null) {
        await _shopRepo.create(shop);
      } else {
        await _shopRepo.update(shop);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.shopToEdit != null
                  ? '${shop.nome} atualizada!'
                  : '${shop.nome} criada!',
            ),
            backgroundColor: AppColors.scarletRed,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar loja: $e'),
            backgroundColor: AppColors.neonRed,
          ),
        );
      }
    }
  }
}
