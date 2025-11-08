import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/local_database_service.dart';
import '../widgets/hex_loading.dart';
import '../widgets/ritual_card.dart';
import '../widgets/glowing_button.dart';
import '../theme/app_theme.dart';

class CharacterFormScreen extends StatefulWidget {
  final Character? character;
  final String userId;

  const CharacterFormScreen({
    super.key,
    this.character,
    required this.userId,
  });

  @override
  State<CharacterFormScreen> createState() => _CharacterFormScreenState();
}

class _CharacterFormScreenState extends State<CharacterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _databaseService = LocalDatabaseService();

  late TextEditingController _nomeController;
  late TextEditingController _patenteController;
  late TextEditingController _nexController;
  late TextEditingController _origemController;
  late TextEditingController _classeController;
  late TextEditingController _trilhaController;
  late TextEditingController _pvMaxController;
  late TextEditingController _peMaxController;
  late TextEditingController _psMaxController;
  late TextEditingController _creditosController;
  late TextEditingController _forcaController;
  late TextEditingController _agilidadeController;
  late TextEditingController _vigorController;
  late TextEditingController _inteligenciaController;
  late TextEditingController _presencaController;
  late TextEditingController _iniciativaBaseController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final char = widget.character;

    _nomeController = TextEditingController(text: char?.nome ?? '');
    _patenteController = TextEditingController(text: char?.patente ?? '');
    _nexController = TextEditingController(text: char?.nex.toString() ?? '0');
    _origemController = TextEditingController(text: char?.origem ?? '');
    _classeController = TextEditingController(text: char?.classe ?? '');
    _trilhaController = TextEditingController(text: char?.trilha ?? '');
    _pvMaxController = TextEditingController(text: char?.pvMax.toString() ?? '0');
    _peMaxController = TextEditingController(text: char?.peMax.toString() ?? '0');
    _psMaxController = TextEditingController(text: char?.psMax.toString() ?? '0');
    _creditosController = TextEditingController(text: char?.creditos.toString() ?? '0');
    _forcaController = TextEditingController(text: char?.forca.toString() ?? '0');
    _agilidadeController = TextEditingController(text: char?.agilidade.toString() ?? '0');
    _vigorController = TextEditingController(text: char?.vigor.toString() ?? '0');
    _inteligenciaController = TextEditingController(text: char?.inteligencia.toString() ?? '0');
    _presencaController = TextEditingController(text: char?.presenca.toString() ?? '0');
    _iniciativaBaseController = TextEditingController(text: char?.iniciativaBase.toString() ?? '0');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _patenteController.dispose();
    _nexController.dispose();
    _origemController.dispose();
    _classeController.dispose();
    _trilhaController.dispose();
    _pvMaxController.dispose();
    _peMaxController.dispose();
    _psMaxController.dispose();
    _creditosController.dispose();
    _forcaController.dispose();
    _agilidadeController.dispose();
    _vigorController.dispose();
    _inteligenciaController.dispose();
    _presencaController.dispose();
    _iniciativaBaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              widget.character == null ? 'Novo Personagem' : 'Editar Personagem',
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Informações Básicas
                _buildSectionCard(
                  title: 'INFORMAÇÕES BÁSICAS',
                  children: [
                    _buildTextField('Nome', _nomeController, required: true),
                    _buildTextField('Patente', _patenteController),
                    _buildNumberField('NEX', _nexController),
                    _buildTextField('Origem', _origemController),
                    _buildTextField('Classe', _classeController),
                    _buildTextField('Trilha', _trilhaController),
                  ],
                ),

                const SizedBox(height: 24),

                // Status
                _buildSectionCard(
                  title: 'STATUS MÁXIMO',
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildNumberField('PV Máx', _pvMaxController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildNumberField('PE Máx', _peMaxController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildNumberField('PS Máx', _psMaxController)),
                      ],
                    ),
                    _buildNumberField('Créditos', _creditosController),
                  ],
                ),

                const SizedBox(height: 24),

                // Atributos
                _buildSectionCard(
                  title: 'ATRIBUTOS',
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildNumberField('FOR', _forcaController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildNumberField('AGI', _agilidadeController)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildNumberField('VIG', _vigorController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildNumberField('INT', _inteligenciaController)),
                      ],
                    ),
                    _buildNumberField('PRE', _presencaController),
                  ],
                ),

                const SizedBox(height: 24),

                // Combate
                _buildSectionCard(
                  title: 'COMBATE',
                  children: [
                    _buildNumberField('Iniciativa Base', _iniciativaBaseController),
                  ],
                ),

                const SizedBox(height: 32),

                // Botões
                Row(
                  children: [
                    Expanded(
                      child: GlowingButton(
                        label: 'Cancelar',
                        style: GlowingButtonStyle.secondary,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlowingButton(
                        label: 'Salvar',
                        style: GlowingButtonStyle.primary,
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _saveCharacter,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Loading overlay
        if (_isLoading)
          Container(
            color: AppTheme.abyssalBlack.withValues(alpha: 0.7),
            child: const Center(
              child: HexLoading.large(
                message: 'Salvando personagem...',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return RitualCard(
      glowEffect: false,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.ritualRed,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(
              color: AppTheme.industrialGray,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(
              color: AppTheme.ritualRed,
              width: 2,
            ),
          ),
        ),
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(
              color: AppTheme.industrialGray,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(
              color: AppTheme.ritualRed,
              width: 2,
            ),
          ),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Campo obrigatório';
          }
          if (int.tryParse(value) == null) {
            return 'Número inválido';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _saveCharacter() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final pvMax = int.parse(_pvMaxController.text);
      final peMax = int.parse(_peMaxController.text);
      final psMax = int.parse(_psMaxController.text);

      final character = Character(
        id: widget.character?.id ?? '',
        nome: _nomeController.text,
        patente: _patenteController.text,
        nex: int.parse(_nexController.text),
        origem: _origemController.text,
        classe: _classeController.text,
        trilha: _trilhaController.text,
        createdBy: widget.userId,
        pvAtual: widget.character?.pvAtual ?? pvMax,
        pvMax: pvMax,
        peAtual: widget.character?.peAtual ?? peMax,
        peMax: peMax,
        psAtual: widget.character?.psAtual ?? psMax,
        psMax: psMax,
        creditos: int.parse(_creditosController.text),
        forca: int.parse(_forcaController.text),
        agilidade: int.parse(_agilidadeController.text),
        vigor: int.parse(_vigorController.text),
        inteligencia: int.parse(_inteligenciaController.text),
        presenca: int.parse(_presencaController.text),
        iniciativaBase: int.parse(_iniciativaBaseController.text),
        pericias: widget.character?.pericias ?? {},
        poderes: widget.character?.poderes ?? [],
        inventario: widget.character?.inventario ?? [],
      );

      if (widget.character == null) {
        await _databaseService.createCharacter(character);
      } else {
        await _databaseService.updateCharacter(character);
      }

      if (mounted) {
        _showSuccessDialog(
          isCreation: widget.character == null,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(error: e.toString());
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog({required bool isCreation}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RitualCard(
        glowEffect: true,
        glowColor: AppTheme.mutagenGreen,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppTheme.mutagenGreen,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              isCreation ? 'Personagem Criado!' : 'Personagem Atualizado!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.mutagenGreen,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isCreation
                  ? 'Seu novo personagem foi criado com sucesso!'
                  : 'As alterações foram salvas com sucesso!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.coldGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GlowingButton(
              label: 'Continuar',
              style: GlowingButtonStyle.primary,
              fullWidth: true,
              onPressed: () {
                Navigator.pop(context); // Fechar diálogo
                Navigator.pop(context); // Voltar para lista
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog({required String error}) {
    showDialog(
      context: context,
      builder: (context) => RitualCard(
        glowEffect: true,
        glowColor: AppTheme.alertYellow,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: AppTheme.alertYellow,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao Salvar',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.alertYellow,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.coldGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GlowingButton(
              label: 'Tentar Novamente',
              style: GlowingButtonStyle.primary,
              fullWidth: true,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
