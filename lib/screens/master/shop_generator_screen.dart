import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/shop.dart';
import '../../models/shop_generator_config.dart';
import '../../models/item_rarity.dart';
import '../../core/utils/shop_generator.dart';
import '../../core/database/shop_repository.dart';

/// Tela de geração randômica de lojas
class ShopGeneratorScreen extends StatefulWidget {
  const ShopGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<ShopGeneratorScreen> createState() => _ShopGeneratorScreenState();
}

class _ShopGeneratorScreenState extends State<ShopGeneratorScreen> {
  final ShopRepository _repository = ShopRepository();
  final RandomShopGenerator _generator = RandomShopGenerator();

  // Controllers para campos de texto
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _donoController = TextEditingController();

  // Tipo de loja
  ShopType _tipoLoja = ShopType.mercador;

  // Quantidades
  double _armasComuns = 0;
  double _armasAmaldicoadas = 0;
  double _curas = 0;
  double _curasAmaldicoadas = 0;
  double _comidas = 0;
  double _utilidades = 0;
  double _municoes = 0;
  double _equipamentos = 0;

  // Filtros
  ItemRarity _raridadeMinima = ItemRarity.comum;
  ItemRarity _raridadeMaxima = ItemRarity.lendario;
  int _patenteMinima = 0;
  int _patenteMaxima = 5;

  // Loja gerada (preview)
  Shop? _lojaGerada;

  // Loading
  bool _isGenerating = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _donoController.dispose();
    super.dispose();
  }

  /// Gera a loja
  Future<void> _generateShop() async {
    setState(() {
      _isGenerating = true;
    });

    // Aguarda um pouco para mostrar loading
    await Future.delayed(const Duration(milliseconds: 500));

    final config = ShopGeneratorConfig(
      nomePersonalizado: _nomeController.text.trim().isEmpty ? null : _nomeController.text.trim(),
      descricaoPersonalizada: _descricaoController.text.trim().isEmpty ? null : _descricaoController.text.trim(),
      donoPersonalizado: _donoController.text.trim().isEmpty ? null : _donoController.text.trim(),
      tipoLoja: _tipoLoja,
      armasComuns: _armasComuns.toInt(),
      armasAmaldicoadas: _armasAmaldicoadas.toInt(),
      curas: _curas.toInt(),
      curasAmaldicoadas: _curasAmaldicoadas.toInt(),
      comidas: _comidas.toInt(),
      utilidades: _utilidades.toInt(),
      municoes: _municoes.toInt(),
      equipamentos: _equipamentos.toInt(),
      raridadeMinima: _raridadeMinima,
      raridadeMaxima: _raridadeMaxima,
      patenteMinima: _patenteMinima,
      patenteMaxima: _patenteMaxima,
    );

    if (!config.isValid) {
      setState(() {
        _isGenerating = false;
      });
      _showError('Configure pelo menos um tipo de item para gerar!');
      return;
    }

    try {
      final loja = _generator.generateShop(config);
      setState(() {
        _lojaGerada = loja;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      _showError('Erro ao gerar loja: $e');
    }
  }

  /// Salva a loja gerada
  Future<void> _saveShop() async {
    if (_lojaGerada == null) return;

    try {
      await _repository.create(_lojaGerada!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loja "${_lojaGerada!.nome}" salva com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        // Volta para a tela anterior
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError('Erro ao salvar loja: $e');
    }
  }

  /// Limpa o formulário
  void _clearForm() {
    setState(() {
      _nomeController.clear();
      _descricaoController.clear();
      _donoController.clear();
      _tipoLoja = ShopType.mercador;
      _armasComuns = 0;
      _armasAmaldicoadas = 0;
      _curas = 0;
      _curasAmaldicoadas = 0;
      _comidas = 0;
      _utilidades = 0;
      _municoes = 0;
      _equipamentos = 0;
      _raridadeMinima = ItemRarity.comum;
      _raridadeMaxima = ItemRarity.lendario;
      _patenteMinima = 0;
      _patenteMaxima = 5;
      _lojaGerada = null;
    });
  }

  /// Aplica um preset
  void _applyPreset(ShopGeneratorConfig preset) {
    setState(() {
      _tipoLoja = preset.tipoLoja;
      _armasComuns = preset.armasComuns.toDouble();
      _armasAmaldicoadas = preset.armasAmaldicoadas.toDouble();
      _curas = preset.curas.toDouble();
      _curasAmaldicoadas = preset.curasAmaldicoadas.toDouble();
      _comidas = preset.comidas.toDouble();
      _utilidades = preset.utilidades.toDouble();
      _municoes = preset.municoes.toDouble();
      _equipamentos = preset.equipamentos.toDouble();
      _raridadeMinima = preset.raridadeMinima;
      _raridadeMaxima = preset.raridadeMaxima;
      _patenteMinima = preset.patenteMinima;
      _patenteMaxima = preset.patenteMaxima;
      _lojaGerada = null;
    });
  }

  /// Mostra erro
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.neonRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepBlack,
        title: Text(
          'GERADOR DE LOJAS',
          style: AppTextStyles.title.copyWith(color: AppColors.magenta),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.magenta),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _lojaGerada == null
          ? _buildGeneratorForm()
          : _buildPreviewScreen(),
    );
  }

  /// Formulário de geração
  Widget _buildGeneratorForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Presets rápidos
          _buildPresetsSection(),
          const SizedBox(height: 24),

          // Informações básicas
          _buildBasicInfoSection(),
          const SizedBox(height: 24),

          // Quantidades
          _buildQuantitiesSection(),
          const SizedBox(height: 24),

          // Filtros avançados
          _buildFiltersSection(),
          const SizedBox(height: 32),

          // Botões de ação
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// Seção de presets
  Widget _buildPresetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRESETS RÁPIDOS',
          style: AppTextStyles.body.copyWith(
            color: AppColors.magenta,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPresetButton('Loja de Bairro', ShopGeneratorConfig.presetLojaDeBairro()),
            _buildPresetButton('Armaria Básica', ShopGeneratorConfig.presetArmariaBasica()),
            _buildPresetButton('Quartel da Ordem', ShopGeneratorConfig.presetQuartelDaOrdem()),
            _buildPresetButton('Farmácia', ShopGeneratorConfig.presetFarmacia()),
            _buildPresetButton('Enfermaria da Ordem', ShopGeneratorConfig.presetEnfermariaDaOrdem()),
            _buildPresetButton('Mercado Completo', ShopGeneratorConfig.presetMercadoCompleto()),
            _buildPresetButton('Armaria Tática', ShopGeneratorConfig.presetArmariaTatica()),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetButton(String label, ShopGeneratorConfig preset) {
    return ElevatedButton(
      onPressed: () => _applyPreset(preset),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.magenta.withOpacity(0.2),
        foregroundColor: AppColors.magenta,
        side: BorderSide(color: AppColors.magenta, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  /// Seção de informações básicas
  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INFORMAÇÕES BÁSICAS',
          style: AppTextStyles.body.copyWith(
            color: AppColors.magenta,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Deixe em branco para gerar automaticamente',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.silver),
        ),
        const SizedBox(height: 12),

        // Nome
        TextField(
          controller: _nomeController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Nome da Loja (opcional)',
            labelStyle: const TextStyle(color: AppColors.silver),
            hintText: 'Ex: Armaria do João',
            hintStyle: TextStyle(color: AppColors.silver.withOpacity(0.5)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.magenta.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.magenta, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Descrição
        TextField(
          controller: _descricaoController,
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Descrição (opcional)',
            labelStyle: const TextStyle(color: AppColors.silver),
            hintText: 'Descreva a loja...',
            hintStyle: TextStyle(color: AppColors.silver.withOpacity(0.5)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.magenta.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.magenta, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Dono
        TextField(
          controller: _donoController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Nome do Dono (opcional)',
            labelStyle: const TextStyle(color: AppColors.silver),
            hintText: 'Ex: João Silva',
            hintStyle: TextStyle(color: AppColors.silver.withOpacity(0.5)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.magenta.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.magenta, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Tipo de loja
        DropdownButtonFormField<ShopType>(
          value: _tipoLoja,
          dropdownColor: AppColors.deepBlack,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Tipo de Loja',
            labelStyle: const TextStyle(color: AppColors.silver),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.magenta.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.magenta, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: ShopType.values.map((tipo) {
            return DropdownMenuItem(
              value: tipo,
              child: Text(_getShopTypeDisplayName(tipo)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _tipoLoja = value;
              });
            }
          },
        ),
      ],
    );
  }

  /// Seção de quantidades
  Widget _buildQuantitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUANTIDADE DE ITENS',
          style: AppTextStyles.body.copyWith(
            color: AppColors.magenta,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildQuantitySlider('Armas Comuns', _armasComuns, (value) {
          setState(() => _armasComuns = value);
        }, Colors.blue),
        _buildQuantitySlider('Armas Amaldiçoadas', _armasAmaldicoadas, (value) {
          setState(() => _armasAmaldicoadas = value);
        }, AppColors.neonRed),
        _buildQuantitySlider('Curas', _curas, (value) {
          setState(() => _curas = value);
        }, Colors.green),
        _buildQuantitySlider('Curas Amaldiçoadas', _curasAmaldicoadas, (value) {
          setState(() => _curasAmaldicoadas = value);
        }, AppColors.neonRed),
        _buildQuantitySlider('Comidas', _comidas, (value) {
          setState(() => _comidas = value);
        }, Colors.orange),
        _buildQuantitySlider('Utilidades', _utilidades, (value) {
          setState(() => _utilidades = value);
        }, Colors.cyan),
        _buildQuantitySlider('Munições', _municoes, (value) {
          setState(() => _municoes = value);
        }, Colors.yellow),
        _buildQuantitySlider('Equipamentos', _equipamentos, (value) {
          setState(() => _equipamentos = value);
        }, Colors.purple),
      ],
    );
  }

  Widget _buildQuantitySlider(String label, double value, ValueChanged<double> onChanged, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(color: color),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value.toInt().toString(),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 20,
            divisions: 20,
            activeColor: color,
            inactiveColor: color.withOpacity(0.3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  /// Seção de filtros
  Widget _buildFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FILTROS AVANÇADOS',
          style: AppTextStyles.body.copyWith(
            color: AppColors.magenta,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Raridade
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<ItemRarity>(
                value: _raridadeMinima,
                dropdownColor: AppColors.deepBlack,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Raridade Mínima',
                  labelStyle: const TextStyle(color: AppColors.silver, fontSize: 12),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.magenta.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.magenta, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ItemRarity.values.map((r) {
                  return DropdownMenuItem(
                    value: r,
                    child: Text(r.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _raridadeMinima = value);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<ItemRarity>(
                value: _raridadeMaxima,
                dropdownColor: AppColors.deepBlack,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Raridade Máxima',
                  labelStyle: const TextStyle(color: AppColors.silver, fontSize: 12),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.magenta.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.magenta, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ItemRarity.values.map((r) {
                  return DropdownMenuItem(
                    value: r,
                    child: Text(r.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _raridadeMaxima = value);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Patente
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _patenteMinima,
                dropdownColor: AppColors.deepBlack,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Patente Mínima',
                  labelStyle: const TextStyle(color: AppColors.silver, fontSize: 12),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.magenta.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.magenta, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: List.generate(6, (i) => i).map((patente) {
                  return DropdownMenuItem(
                    value: patente,
                    child: Text('Patente $patente'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _patenteMinima = value);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _patenteMaxima,
                dropdownColor: AppColors.deepBlack,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Patente Máxima',
                  labelStyle: const TextStyle(color: AppColors.silver, fontSize: 12),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.magenta.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.magenta, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: List.generate(6, (i) => i).map((patente) {
                  return DropdownMenuItem(
                    value: patente,
                    child: Text('Patente $patente'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _patenteMaxima = value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Botões de ação
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botão Gerar
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isGenerating ? null : _generateShop,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: _isGenerating
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'GERAR LOJA',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // Botão Limpar
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: _clearForm,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.magenta,
              side: const BorderSide(color: AppColors.magenta),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('LIMPAR FORMULÁRIO'),
          ),
        ),
      ],
    );
  }

  /// Tela de preview
  Widget _buildPreviewScreen() {
    if (_lojaGerada == null) return const SizedBox();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.magenta.withOpacity(0.1),
                    border: Border.all(color: AppColors.magenta),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getShopTypeIcon(_lojaGerada!.tipo),
                            color: AppColors.magenta,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _lojaGerada!.nome,
                                  style: AppTextStyles.title.copyWith(
                                    color: AppColors.magenta,
                                  ),
                                ),
                                if (_lojaGerada!.nomeDono != null)
                                  Text(
                                    'Dono: ${_lojaGerada!.nomeDono}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.silver,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _lojaGerada!.descricao,
                        style: AppTextStyles.body.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_lojaGerada!.itens.length} itens',
                              style: const TextStyle(color: Colors.orange),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.magenta.withOpacity(0.2),
                              border: Border.all(color: AppColors.magenta),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getShopTypeDisplayName(_lojaGerada!.tipo),
                              style: const TextStyle(color: AppColors.magenta),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Lista de itens
                Text(
                  'ITENS GERADOS',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.magenta,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...(_lojaGerada!.itens.map((item) => _buildItemPreview(item))),
              ],
            ),
          ),
        ),

        // Botões de ação
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.deepBlack,
            border: Border(
              top: BorderSide(color: AppColors.magenta.withOpacity(0.3)),
            ),
          ),
          child: Column(
            children: [
              // Botão Salvar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveShop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'SALVAR LOJA',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Botão Gerar Nova
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _lojaGerada = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.magenta,
                    side: const BorderSide(color: AppColors.magenta),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('GERAR NOVA LOJA'),
                ),
              ),
              const SizedBox(height: 8),

              // Botão Cancelar
              TextButton(
                onPressed: () {
                  setState(() {
                    _lojaGerada = null;
                  });
                },
                child: const Text(
                  'CANCELAR',
                  style: TextStyle(color: AppColors.neonRed),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemPreview(ShopItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.deepBlack,
        border: Border.all(
          color: item.raridade.cor.withOpacity(0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Ícone de raridade
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: item.raridade.cor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.nome,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${item.preco} ₵',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.descricao,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.silver,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [
                    _buildItemBadge(item.raridade.displayName, item.raridade.cor),
                    if (item.patenteMinima > 0)
                      _buildItemBadge('Patente ${item.patenteMinima}', AppColors.magenta),
                    if (item.isAmaldicoado)
                      _buildItemBadge('AMALDIÇOADO', AppColors.neonRed),
                    if (item.buffTipo != null)
                      _buildItemBadge(item.buffTipo!.icone, Colors.cyan),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getShopTypeDisplayName(ShopType tipo) {
    switch (tipo) {
      case ShopType.taberna:
        return 'Taberna';
      case ShopType.armaria:
        return 'Armaria';
      case ShopType.farmacia:
        return 'Farmácia';
      case ShopType.mercador:
        return 'Mercador';
      case ShopType.forjaria:
        return 'Forjaria';
    }
  }

  IconData _getShopTypeIcon(ShopType tipo) {
    switch (tipo) {
      case ShopType.taberna:
        return Icons.local_bar;
      case ShopType.armaria:
        return Icons.security;
      case ShopType.farmacia:
        return Icons.local_hospital;
      case ShopType.mercador:
        return Icons.shopping_cart;
      case ShopType.forjaria:
        return Icons.build;
    }
  }
}
