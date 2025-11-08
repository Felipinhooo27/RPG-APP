import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/character.dart';
import '../services/local_database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'character_wizard_screen.dart';
import 'character_grimoire_screen.dart';

/// Tela de listagem de personagens com design moderno estilo iOS
class CharacterListScreen extends StatefulWidget {
  final bool isMasterMode;

  const CharacterListScreen({
    super.key,
    required this.isMasterMode,
  });

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  final LocalDatabaseService _databaseService = LocalDatabaseService();
  final String _userId = 'player_001';

  @override
  Widget build(BuildContext context) {
    return HexatombeBackground(
      showParticles: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppTheme.abyssalBlack.withOpacity(0.9),
          elevation: 0,
          centerTitle: true,
          title: Column(
            children: [
              Text(
                widget.isMasterMode ? 'TODOS OS PERSONAGENS' : 'MEUS PERSONAGENS',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 1.5,
                  color: AppTheme.paleWhite,
                ),
              ),
            ],
          ),
          actions: widget.isMasterMode
              ? null
              : [
                  IconButton(
                    icon: const Icon(Icons.download_outlined, size: 22),
                    onPressed: _importCharacter,
                  ),
                ],
        ),
      body: StreamBuilder<List<Character>>(
        stream: widget.isMasterMode
            ? _databaseService.getAllCharacters()
            : _databaseService.getCharactersByUser(_userId),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          // Error state
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final characters = snapshot.data ?? [];

          // Empty state
          if (characters.isEmpty) {
            return _buildEmptyState();
          }

          // Grid de personagens
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.80,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
              final delay = min(index * 50, 400);
              return _ModernCharacterCard(
                character: character,
                isMasterMode: widget.isMasterMode,
                onTap: () => _navigateToDetail(character),
                onDelete: () => _deleteCharacter(character.id),
                onExport: widget.isMasterMode ? () => _exportCharacter(character) : null,
              )
                  .animate()
                  .fadeIn(delay: delay.ms, duration: 400.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    delay: delay.ms,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  );
            },
          );
        },
      ),
        floatingActionButton: _buildModernFAB(),
      ),
    );
  }

  // Loading state com HexLoading
  Widget _buildLoadingState() {
    return const Center(
      child: HexLoading.large(
        message: 'Carregando personagens...',
      ),
    );
  }

  // Error state usando EmptyState
  Widget _buildErrorState(String error) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Erro ao carregar',
      message: error,
    );
  }

  // Empty state melhorado
  Widget _buildEmptyState() {
    return EmptyState.noCharacters(
      onAction: _navigateToCreateCharacter,
    );
  }

  // FAB moderno
  Widget _buildModernFAB() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.ritualRed,
            AppTheme.chaoticMagenta,
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.ritualRed.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          onTap: _navigateToCreateCharacter,
          borderRadius: BorderRadius.circular(32),
          child: const Icon(
            Icons.add,
            size: 32,
            color: AppTheme.paleWhite,
          ),
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
          duration: 2000.ms,
        );
  }

  // Navegação
  void _navigateToCreateCharacter() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterWizardScreen(userId: _userId),
      ),
    );
  }

  void _navigateToDetail(Character character) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterGrimoireScreen(
          character: character,
          isMasterMode: widget.isMasterMode,
        ),
      ),
    );
  }

  // Delete com confirmação usando RitualCard
  Future<void> _deleteCharacter(String characterId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: RitualCard(
          glowEffect: true,
          glowColor: AppTheme.alertYellow,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.alertYellow,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'CONFIRMAR EXCLUSÃO',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  color: AppTheme.alertYellow,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tem certeza que deseja excluir este personagem? Esta ação não pode ser desfeita.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.coldGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlowingButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.pop(context, false),
                      style: GlowingButtonStyle.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlowingButton(
                      label: 'Excluir',
                      icon: Icons.delete,
                      onPressed: () => Navigator.pop(context, true),
                      style: GlowingButtonStyle.danger,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      try {
        await _databaseService.deleteCharacter(characterId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Personagem excluído', style: GoogleFonts.inter()),
              backgroundColor: AppTheme.mutagenGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: $e', style: GoogleFonts.inter()),
              backgroundColor: AppTheme.alertYellow,
            ),
          );
        }
      }
    }
  }

  // Import de personagem
  Future<void> _importCharacter() async {
    final controller = TextEditingController();

    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        controller.text = clipboardData!.text!;
      }
    } catch (e) {
      // Ignore clipboard errors
    }

    if (!mounted) return;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: RitualCard(
          glowEffect: true,
          glowColor: AppTheme.etherealPurple,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.download, color: AppTheme.etherealPurple, size: 48),
              const SizedBox(height: 16),
              Text(
                'IMPORTAR PERSONAGEM',
                style: GoogleFonts.bebasNeue(
                  fontSize: 24,
                  color: AppTheme.etherealPurple,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 8,
                style: GoogleFonts.spaceMono(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Cole o JSON aqui...',
                  hintStyle: GoogleFonts.spaceMono(color: AppTheme.coldGray),
                  filled: true,
                  fillColor: AppTheme.industrialGray,
                ),
              ),
              const SizedBox(height: 16),
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
                      icon: Icons.check,
                      onPressed: () => Navigator.pop(context, controller.text),
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

    if (result != null && result.isNotEmpty) {
      try {
        await _databaseService.importCharacter(result, _userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Personagem importado!', style: GoogleFonts.inter()),
              backgroundColor: AppTheme.mutagenGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao importar: $e', style: GoogleFonts.inter()),
              backgroundColor: AppTheme.alertYellow,
            ),
          );
        }
      }
    }
  }

  // Export de personagem
  Future<void> _exportCharacter(Character character) async {
    try {
      final jsonString = await _databaseService.exportCharacter(character.id);

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: RitualCard(
            glowEffect: true,
            glowColor: AppTheme.mutagenGreen,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person, color: AppTheme.mutagenGreen, size: 48),
                const SizedBox(height: 16),
                Text(
                  'EXPORTAR PERSONAGEM',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 20,
                    color: AppTheme.mutagenGreen,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  character.nome,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.paleWhite,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GlowingButton(
                        label: 'Copiar',
                        icon: Icons.copy,
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: jsonString));
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Copiado!', style: GoogleFonts.inter()),
                                backgroundColor: AppTheme.mutagenGreen,
                              ),
                            );
                          }
                        },
                        style: GlowingButtonStyle.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlowingButton(
                        label: 'Compartilhar',
                        icon: Icons.share,
                        onPressed: () async {
                          Navigator.pop(context);
                          await Share.share(jsonString);
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
            content: Text('Erro: $e', style: GoogleFonts.inter()),
            backgroundColor: AppTheme.alertYellow,
          ),
        );
      }
    }
  }
}

/// Card moderno de personagem - Design iOS-style
class _ModernCharacterCard extends StatefulWidget {
  final Character character;
  final bool isMasterMode;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onExport;

  const _ModernCharacterCard({
    required this.character,
    required this.isMasterMode,
    required this.onTap,
    required this.onDelete,
    this.onExport,
  });

  @override
  State<_ModernCharacterCard> createState() => _ModernCharacterCardState();
}

class _ModernCharacterCardState extends State<_ModernCharacterCard> {
  bool _isPressed = false;

  bool get isDanger {
    final hpPercent = widget.character.pvAtual / widget.character.pvMax;
    final psPercent = widget.character.psAtual / widget.character.psMax;
    return hpPercent <= 0.25 || psPercent <= 0.25;
  }

  IconData get classIcon {
    final classe = widget.character.classe.toLowerCase();
    if (classe.contains('combat')) return Icons.gps_fixed;
    if (classe.contains('ocult')) return Icons.auto_fix_high;
    if (classe.contains('especial')) return Icons.construction;
    return Icons.person;
  }

  Color get classColor {
    final classe = widget.character.classe.toLowerCase();
    if (classe.contains('combat')) return AppTheme.ritualRed;
    if (classe.contains('ocult')) return AppTheme.chaoticMagenta;
    if (classe.contains('especial')) return AppTheme.mutagenGreen;
    return AppTheme.etherealPurple;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      onLongPress: _showContextMenu,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _isPressed ? 0.96 : 1.0,
        child: RitualCard(
          glowEffect: isDanger,
          glowColor: isDanger ? AppTheme.alertYellow : classColor,
          padding: const EdgeInsets.all(12),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ícone grande centralizado
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        classColor,
                        classColor.withOpacity(0.6),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: classColor.withOpacity(0.5),
                        blurRadius: 16,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    classIcon,
                    size: 28,
                    color: AppTheme.paleWhite,
                  ),
                ).animate(
                  onPlay: isDanger ? (c) => c.repeat(reverse: true) : null,
                ).scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.1, 1.1),
                  duration: isDanger ? 1500.ms : 0.ms,
                ),

                const SizedBox(height: 8),

                // Nome
                Text(
                  widget.character.nome.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.paleWhite,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 3),

                // Classe
                Text(
                  widget.character.classe.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: classColor,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // NEX
                if (widget.character.nex > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    'NEX ${widget.character.nex}%',
                    style: GoogleFonts.spaceMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.limestoneGray,
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Barras modernas
                _ModernStatBar(
                  label: 'PV',
                  current: widget.character.pvAtual,
                  maximum: widget.character.pvMax,
                  color: AppTheme.ritualRed,
                ),
                const SizedBox(height: 4),
                _ModernStatBar(
                  label: 'PE',
                  current: widget.character.peAtual,
                  maximum: widget.character.peMax,
                  color: AppTheme.etherealPurple,
                ),
                const SizedBox(height: 4),
                _ModernStatBar(
                  label: 'PS',
                  current: widget.character.psAtual,
                  maximum: widget.character.psMax,
                  color: AppTheme.alertYellow,
                ),
              ],
            ),
          ),
        ),
    );
  }

  void _showContextMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: RitualCard(
          glowEffect: true,
          glowColor: classColor,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle visual
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.industrialGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (widget.isMasterMode && widget.onExport != null) ...[
                GlowingButton(
                  label: 'Exportar Personagem',
                  icon: Icons.share,
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onExport!();
                  },
                  style: GlowingButtonStyle.secondary,
                ),
                const SizedBox(height: 12),
              ],
              GlowingButton(
                label: 'Deletar Personagem',
                icon: Icons.delete,
                onPressed: () {
                  Navigator.pop(context);
                  widget.onDelete();
                },
                style: GlowingButtonStyle.danger,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra de stat moderna e minimalista
class _ModernStatBar extends StatelessWidget {
  final String label;
  final int current;
  final int maximum;
  final Color color;

  const _ModernStatBar({
    required this.label,
    required this.current,
    required this.maximum,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = current / maximum;

    return Row(
      children: [
        // Label
        SizedBox(
          width: 24,
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.coldGray,
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Barra
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.industrialGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Valor
        Text(
          '$current',
          style: GoogleFonts.spaceMono(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

