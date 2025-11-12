import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/power.dart';
import '../../core/database/power_repository.dart';

/// Formulário de criação/edição de poder/ritual
/// Design flat seguindo padrão Hexatombe (sem border radius)
class PowerFormScreen extends StatefulWidget {
  final String characterId;
  final Power? powerToEdit;

  const PowerFormScreen({
    super.key,
    required this.characterId,
    this.powerToEdit,
  });

  @override
  State<PowerFormScreen> createState() => _PowerFormScreenState();
}

class _PowerFormScreenState extends State<PowerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _powerRepo = PowerRepository();
  final _uuid = const Uuid();

  // Controllers
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _efeitosController = TextEditingController();
  final _duracaoController = TextEditingController();
  final _alcanceController = TextEditingController();
  final _custoPEController = TextEditingController(text: '1');
  final _nivelMinimoController = TextEditingController(text: '5');
  final _circuloController = TextEditingController();

  // Estado
  ElementoOutroLado _selectedElemento = ElementoOutroLado.conhecimento;
  bool _isRitual = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.powerToEdit != null) {
      _loadExistingPower();
    }
  }

  void _loadExistingPower() {
    final power = widget.powerToEdit!;
    _nomeController.text = power.nome;
    _descricaoController.text = power.descricao;
    _efeitosController.text = power.efeitos ?? '';
    _duracaoController.text = power.duracao ?? '';
    _alcanceController.text = power.alcance ?? '';
    _custoPEController.text = power.custoPE.toString();
    _nivelMinimoController.text = power.nivelMinimo.toString();
    _circuloController.text = power.circulo?.toString() ?? '';
    _selectedElemento = power.elemento;
    _isRitual = power.isRitual;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _efeitosController.dispose();
    _duracaoController.dispose();
    _alcanceController.dispose();
    _custoPEController.dispose();
    _nivelMinimoController.dispose();
    _circuloController.dispose();
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
          widget.powerToEdit != null ? 'EDITAR PODER' : 'NOVO PODER',
          style: AppTextStyles.title,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Nome
            _buildLabel('NOME DO PODER', required: true),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nomeController,
              hint: 'Ex: Rajada Mental, Abjurar Espírito',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome é obrigatório';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Elemento
            _buildLabel('ELEMENTO', required: true),
            const SizedBox(height: 8),
            _buildElementoDropdown(),

            const SizedBox(height: 24),

            // É Ritual?
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkGray,
                border: Border.all(color: AppColors.medoPurple.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isRitual = !_isRitual;
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _isRitual ? AppColors.medoPurple : Colors.transparent,
                        border: Border.all(
                          color: _isRitual ? AppColors.medoPurple : AppColors.silver,
                          width: 2,
                        ),
                      ),
                      child: _isRitual
                          ? const Icon(Icons.check, color: AppColors.deepBlack, size: 16)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'É UM RITUAL',
                      style: AppTextStyles.uppercase.copyWith(
                        fontSize: 11,
                        color: _isRitual ? AppColors.medoPurple : AppColors.silver,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Círculo (se ritual)
            if (_isRitual) ...[
              _buildLabel('CÍRCULO DO RITUAL'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _circuloController,
                hint: 'Ex: 1, 2, 3, 4',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
            ],

            // Custo PE
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('CUSTO PE', required: true),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _custoPEController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Custo PE é obrigatório';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Valor inválido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('NEX MÍNIMO'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nivelMinimoController,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Descrição
            _buildLabel('DESCRIÇÃO', required: true),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _descricaoController,
              hint: 'Descreva o poder ou ritual...',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Descrição é obrigatória';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Efeitos
            _buildLabel('EFEITOS'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _efeitosController,
              hint: 'Efeitos mecânicos do poder...',
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Duração
            _buildLabel('DURAÇÃO'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _duracaoController,
              hint: 'Ex: Instantâneo, 1 rodada, Sustentado',
            ),

            const SizedBox(height: 24),

            // Alcance
            _buildLabel('ALCANCE'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _alcanceController,
              hint: 'Ex: Pessoal, Toque, 9m, Ilimitado',
            ),

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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: AppTextStyles.body.copyWith(color: AppColors.lightGray),
      maxLines: maxLines,
      keyboardType: keyboardType,
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
          borderSide: BorderSide(color: AppColors.medoPurple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildElementoDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border.all(color: AppColors.silver.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ElementoOutroLado>(
          value: _selectedElemento,
          isExpanded: true,
          dropdownColor: AppColors.darkGray,
          style: AppTextStyles.body.copyWith(color: AppColors.lightGray),
          onChanged: (ElementoOutroLado? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedElemento = newValue;
              });
            }
          },
          items: ElementoOutroLado.values.map((ElementoOutroLado elemento) {
            return DropdownMenuItem<ElementoOutroLado>(
              value: elemento,
              child: Text(_getElementoNome(elemento)),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getElementoNome(ElementoOutroLado elemento) {
    switch (elemento) {
      case ElementoOutroLado.conhecimento:
        return 'Conhecimento';
      case ElementoOutroLado.energia:
        return 'Energia';
      case ElementoOutroLado.morte:
        return 'Morte';
      case ElementoOutroLado.sangue:
        return 'Sangue';
      case ElementoOutroLado.medo:
        return 'Medo';
    }
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
        color: AppColors.medoPurple,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _savePower,
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
                    widget.powerToEdit != null ? 'SALVAR' : 'CRIAR PODER',
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

  Future<void> _savePower() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final power = Power(
        id: widget.powerToEdit?.id ?? _uuid.v4(),
        characterId: widget.characterId,
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim(),
        elemento: _selectedElemento,
        custoPE: int.tryParse(_custoPEController.text) ?? 1,
        nivelMinimo: int.tryParse(_nivelMinimoController.text) ?? 5,
        efeitos: _efeitosController.text.trim().isEmpty ? null : _efeitosController.text.trim(),
        duracao: _duracaoController.text.trim().isEmpty ? null : _duracaoController.text.trim(),
        alcance: _alcanceController.text.trim().isEmpty ? null : _alcanceController.text.trim(),
        circulo: _isRitual && _circuloController.text.isNotEmpty
            ? int.tryParse(_circuloController.text)
            : null,
      );

      if (widget.powerToEdit == null) {
        await _powerRepo.create(power);
      } else {
        await _powerRepo.update(power);
      }

      if (mounted) {
        Navigator.pop(context, power);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.powerToEdit != null
                  ? '${power.nome} atualizado!'
                  : '${power.nome} criado!',
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
            content: Text('Erro ao salvar poder: $e'),
            backgroundColor: AppColors.neonRed,
          ),
        );
      }
    }
  }
}
