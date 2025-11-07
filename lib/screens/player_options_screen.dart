import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/character.dart';
import '../services/local_database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class PlayerOptionsScreen extends StatefulWidget {
  const PlayerOptionsScreen({super.key});

  @override
  State<PlayerOptionsScreen> createState() => _PlayerOptionsScreenState();
}

class _PlayerOptionsScreenState extends State<PlayerOptionsScreen> {
  final LocalDatabaseService _databaseService = LocalDatabaseService();
  final String _userId = 'player_001';
  List<Character> _characters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    try {
      // Use Future version for initial load to avoid stream hanging
      final allCharacters = await _databaseService.getAllCharactersList();
      final userCharacters = allCharacters.where((c) => c.createdBy == _userId).toList();

      if (mounted) {
        setState(() {
          _characters = userCharacters;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return HexatombeBackground(
      showParticles: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppTheme.abyssalBlack.withOpacity(0.9),
          elevation: 0,
          title: const Text(
            'OPÇÕES',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'BebasNeue',
              letterSpacing: 2,
              color: AppTheme.etherealPurple,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: HexLoading.large())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RitualCard(
                      glowEffect: true,
                      glowColor: AppTheme.etherealPurple,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppTheme.etherealPurple,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'GERENCIAR PERSONAGENS',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.etherealPurple,
                                    fontFamily: 'BebasNeue',
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Exporte suas fichas para compartilhar ou fazer backup.\n'
                            'Importe fichas colando o código JSON gerado.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.coldGray,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 24),

                    // Exportar personagens
                    if (_characters.isNotEmpty) ...[
                      const Text(
                        'EXPORTAR PERSONAGENS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.paleWhite,
                          fontFamily: 'BebasNeue',
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._characters.asMap().entries.map((entry) {
                        final index = entry.key;
                        final character = entry.value;
                        return _buildCharacterExportCard(character, index);
                      }),
                      const SizedBox(height: 16),
                      GlowingButton(
                        label: 'Exportar Todos',
                        icon: Icons.upload,
                        onPressed: _exportAllCharacters,
                        style: GlowingButtonStyle.primary,
                      ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
                      const SizedBox(height: 32),
                    ],

                    // Importar personagens
                    const Text(
                      'IMPORTAR PERSONAGENS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.paleWhite,
                        fontFamily: 'BebasNeue',
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RitualCard(
                      padding: const EdgeInsets.all(16),
                      glowEffect: false,
                      child: Column(
                        children: [
                          const Icon(
                            Icons.download,
                            color: AppTheme.mutagenGreen,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Cole o código JSON do personagem',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.coldGray,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(height: 16),
                          GlowingButton(
                            label: 'Importar Personagem',
                            icon: Icons.download,
                            onPressed: _showImportDialog,
                            style: GlowingButtonStyle.occult,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms, duration: 300.ms),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCharacterExportCard(Character character, int index) {
    return RitualCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      glowEffect: false,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.ritualRed, AppTheme.chaoticMagenta],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.ritualRed.withOpacity(0.35),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                character.nome.isNotEmpty ? character.nome[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.paleWhite,
                  fontFamily: 'BebasNeue',
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  character.nome.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.paleWhite,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${character.classe} • NEX ${character.nex}%',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.coldGray,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: AppTheme.mutagenGreen),
            onPressed: () => _exportSingleCharacter(character),
            tooltip: 'Exportar',
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (index * 50 + 300).ms, duration: 300.ms)
        .slideX(begin: -0.1, end: 0);
  }

  Future<void> _exportSingleCharacter(Character character) async {
    try {
      final characterData = character.toJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(characterData);

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: RitualCard(
            glowEffect: true,
            glowColor: AppTheme.mutagenGreen,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.download, color: AppTheme.mutagenGreen, size: 40),
                const SizedBox(height: 12),
                Text(
                  'EXPORTAR ${character.nome.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.mutagenGreen,
                    fontFamily: 'BebasNeue',
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Copie o JSON abaixo:',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.paleWhite,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: TextField(
                    controller: TextEditingController(text: jsonString),
                    maxLines: null,
                    readOnly: true,
                    style: const TextStyle(
                      color: AppTheme.paleWhite,
                      fontFamily: 'SpaceMono',
                      fontSize: 11,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.obscureGray,
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.mutagenGreen, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GlowingButton(
                        label: 'Fechar',
                        onPressed: () => Navigator.pop(context),
                        style: GlowingButtonStyle.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GlowingButton(
                        label: 'Copiar',
                        icon: Icons.copy,
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: jsonString));
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('JSON copiado para área de transferência!'),
                                backgroundColor: AppTheme.mutagenGreen,
                              ),
                            );
                          }
                        },
                        style: GlowingButtonStyle.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar: $e'),
            backgroundColor: AppTheme.ritualRed,
          ),
        );
      }
    }
  }

  Future<void> _exportAllCharacters() async {
    try {
      final allCharactersJson = _characters.map((c) => c.toJson()).toList();
      final jsonString = const JsonEncoder.withIndent('  ').convert(allCharactersJson);

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: RitualCard(
            glowEffect: true,
            glowColor: AppTheme.mutagenGreen,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.download, color: AppTheme.mutagenGreen, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'EXPORTAR TODOS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.mutagenGreen,
                    fontFamily: 'BebasNeue',
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_characters.length} personagens - Copie o JSON:',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.paleWhite,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: TextField(
                    controller: TextEditingController(text: jsonString),
                    maxLines: null,
                    readOnly: true,
                    style: const TextStyle(
                      color: AppTheme.paleWhite,
                      fontFamily: 'SpaceMono',
                      fontSize: 11,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.obscureGray,
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.mutagenGreen, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GlowingButton(
                        label: 'Fechar',
                        onPressed: () => Navigator.pop(context),
                        style: GlowingButtonStyle.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GlowingButton(
                        label: 'Copiar',
                        icon: Icons.copy,
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: jsonString));
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('JSON copiado para área de transferência!'),
                                backgroundColor: AppTheme.mutagenGreen,
                              ),
                            );
                          }
                        },
                        style: GlowingButtonStyle.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar: $e'),
            backgroundColor: AppTheme.ritualRed,
          ),
        );
      }
    }
  }

  Future<void> _showImportDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: RitualCard(
          glowEffect: true,
          glowColor: AppTheme.mutagenGreen,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.download,
                  color: AppTheme.mutagenGreen,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'IMPORTAR PERSONAGEM',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.mutagenGreen,
                    fontFamily: 'BebasNeue',
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller,
                  maxLines: 8,
                  style: const TextStyle(
                    color: AppTheme.paleWhite,
                    fontFamily: 'Courier',
                    fontSize: 11,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cole o código JSON aqui...',
                    hintStyle: const TextStyle(color: AppTheme.coldGray),
                    filled: true,
                    fillColor: AppTheme.obscureGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.mutagenGreen, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.coldGray, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.mutagenGreen, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GlowingButton(
                        label: 'Colar da Área de Transferência',
                        icon: Icons.paste,
                        onPressed: () async {
                          final data = await Clipboard.getData(Clipboard.kTextPlain);
                          if (data?.text != null) {
                            controller.text = data!.text!;
                          }
                        },
                        style: GlowingButtonStyle.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GlowingButton(
                        label: 'Cancelar',
                        onPressed: () => Navigator.pop(context),
                        style: GlowingButtonStyle.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlowingButton(
                        label: 'Importar',
                        icon: Icons.download,
                        onPressed: () {
                          final json = controller.text.trim();
                          if (json.isNotEmpty) {
                            Navigator.pop(context);
                            _importFromJson(json);
                          }
                        },
                        style: GlowingButtonStyle.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9)),
      ),
    );
  }

  Future<void> _importFromJson(String jsonString) async {
    try {
      final jsonData = jsonDecode(jsonString);

      if (jsonData is List) {
        // Importar múltiplos personagens
        int imported = 0;
        for (var charJson in jsonData) {
          final character = Character.fromJson(charJson);
          // Atualizar createdBy para o jogador atual
          final updatedChar = character.copyWith(createdBy: _userId);
          await _databaseService.createCharacter(updatedChar);
          imported++;
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$imported personagens importados com sucesso!'),
              backgroundColor: AppTheme.mutagenGreen,
            ),
          );
          _loadCharacters();
        }
      } else {
        // Importar personagem único
        final character = Character.fromJson(jsonData);
        final updatedChar = character.copyWith(createdBy: _userId);
        await _databaseService.createCharacter(updatedChar);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${character.nome} importado com sucesso!'),
              backgroundColor: AppTheme.mutagenGreen,
            ),
          );
          _loadCharacters();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao importar: $e'),
            backgroundColor: AppTheme.ritualRed,
          ),
        );
      }
    }
  }
}
