import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../models/character.dart';
import '../services/local_database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class PlayerOptionsScreen extends StatefulWidget {
  const PlayerOptionsScreen({super.key});

  @override
  State<PlayerOptionsScreen> createState() => _PlayerOptionsScreenState();
}

class _PlayerOptionsScreenState extends State<PlayerOptionsScreen>
    with SingleTickerProviderStateMixin {
  final LocalDatabaseService _databaseService = LocalDatabaseService();
  final String _userId = 'player_001';
  List<Character> _characters = [];
  bool _isLoading = true;
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
    _loadCharacters();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCharacters() async {
    try {
      final allCharacters = await _databaseService.getAllCharactersList();
      final userCharacters =
          allCharacters.where((c) => c.createdBy == _userId).toList();

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
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 2 : 1;

    return HexatombeBackground(
      showParticles: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppTheme.abyssalBlack.withOpacity(0.95),
          elevation: 0,
          centerTitle: true,
          title: Column(
            children: [
              const Text(
                'OPÇÕES',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 2.5,
                  color: AppTheme.ritualRed,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Gerenciar Personagens',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Inter',
                  letterSpacing: 0.5,
                  color: AppTheme.coldGray.withOpacity(0.8),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.obscureGray.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.industrialGray,
                  width: 1.5,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.ritualRed.withOpacity(0.3),
                      AppTheme.chaoticMagenta.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _selectedTab == 0
                        ? AppTheme.ritualRed
                        : AppTheme.chaoticMagenta,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedTab == 0
                          ? AppTheme.ritualRed.withOpacity(0.4)
                          : AppTheme.chaoticMagenta.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Montserrat',
                  letterSpacing: 1.2,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                  letterSpacing: 1.0,
                ),
                labelColor: AppTheme.paleWhite,
                unselectedLabelColor: AppTheme.coldGray,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.upload_rounded, size: 20),
                    text: 'EXPORTAR',
                  ),
                  Tab(
                    icon: Icon(Icons.download_rounded, size: 20),
                    text: 'IMPORTAR',
                  ),
                ],
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: HexLoading.large())
            : TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: EXPORTAR
                  _buildExportTab(crossAxisCount),
                  // TAB 2: IMPORTAR
                  _buildImportTab(),
                ],
              ),
        floatingActionButton: _selectedTab == 0 && _characters.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: _exportAllCharacters,
                backgroundColor: AppTheme.ritualRed,
                elevation: 8,
                icon: const Icon(Icons.backup_rounded, color: AppTheme.paleWhite),
                label: const Text(
                  'EXPORTAR TODOS',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    fontSize: 13,
                    color: AppTheme.paleWhite,
                  ),
                ),
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .shimmer(
                    duration: 2000.ms,
                    color: AppTheme.paleWhite.withOpacity(0.3),
                  )
            : null,
      ),
    );
  }

  // ==================== TAB EXPORTAR ====================
  Widget _buildExportTab(int crossAxisCount) {
    if (_characters.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.person_off_outlined,
          title: 'Nenhum Personagem',
          message: 'Crie seu primeiro personagem\npara poder exportá-lo',
        ).animate().fadeIn(duration: 400.ms).scale(),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.8,
      ),
      itemCount: _characters.length,
      itemBuilder: (context, index) {
        return CharacterExportCard(
          character: _characters[index],
          index: index,
          onExport: () => _showExportBottomSheet(_characters[index]),
          onShare: () => _shareCharacter(_characters[index]),
        );
      },
    );
  }

  // ==================== TAB IMPORTAR ====================
  Widget _buildImportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Ícone principal
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.chaoticMagenta.withOpacity(0.3),
                  AppTheme.etherealPurple.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppTheme.chaoticMagenta,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.chaoticMagenta.withOpacity(0.4),
                  blurRadius: 24,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.download_rounded,
              size: 50,
              color: AppTheme.chaoticMagenta,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 2000.ms, color: AppTheme.chaoticMagenta)
              .shake(duration: 3000.ms, hz: 0.5, curve: Curves.easeInOut),
          const SizedBox(height: 24),
          const Text(
            'IMPORTAR PERSONAGENS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'BebasNeue',
              letterSpacing: 2.5,
              color: AppTheme.chaoticMagenta,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Cole o código JSON gerado na exportação\npara adicionar personagens ao seu acervo',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Inter',
              letterSpacing: 0.3,
              color: AppTheme.coldGray.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Botões de ação
          RitualCard(
            padding: const EdgeInsets.all(20),
            glowEffect: true,
            glowColor: AppTheme.chaoticMagenta.withOpacity(0.3),
            child: Column(
              children: [
                GlowingButton(
                  label: 'Importar da Área de Transferência',
                  icon: Icons.paste_rounded,
                  onPressed: _importFromClipboard,
                  style: GlowingButtonStyle.occult,
                  fullWidth: true,
                ),
                const SizedBox(height: 12),
                GlowingButton(
                  label: 'Digitar Manualmente',
                  icon: Icons.edit_rounded,
                  onPressed: _showImportBottomSheet,
                  style: GlowingButtonStyle.secondary,
                  fullWidth: true,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          // Info adicional
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.obscureGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.industrialGray,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.etherealPurple,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Aceita personagens individuais ou múltiplos (array JSON)',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Inter',
                      color: AppTheme.coldGray.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  // ==================== BOTTOM SHEET: EXPORTAR PERSONAGEM ====================
  void _showExportBottomSheet(Character character) {
    final characterData = character.toJson();
    final jsonString =
        const JsonEncoder.withIndent('  ').convert(characterData);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.obscureGray,
                AppTheme.abyssalBlack,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: AppTheme.ritualRed.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.ritualRed.withOpacity(0.3),
                blurRadius: 32,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.coldGray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.ritualRed, AppTheme.chaoticMagenta],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.ritualRed.withOpacity(0.4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.upload_rounded,
                        color: AppTheme.paleWhite,
                        size: 24,
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
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Montserrat',
                              letterSpacing: 1.5,
                              color: AppTheme.paleWhite,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${character.classe} • NEX ${character.nex}%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'Inter',
                              color: AppTheme.coldGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppTheme.industrialGray, height: 1),
              // JSON Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CÓDIGO JSON',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'BebasNeue',
                          letterSpacing: 1.5,
                          color: AppTheme.ritualRed,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.abyssalBlack,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.ritualRed.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: SelectableText(
                          jsonString,
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'SpaceMono',
                            color: AppTheme.paleWhite,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.abyssalBlack.withOpacity(0.9),
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.industrialGray,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GlowingButton(
                        label: 'Fechar',
                        onPressed: () => Navigator.pop(context),
                        style: GlowingButtonStyle.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlowingButton(
                        label: 'Copiar',
                        icon: Icons.copy_rounded,
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: jsonString));
                          if (context.mounted) {
                            Navigator.pop(context);
                            _showSuccessSnackBar('JSON copiado!');
                          }
                        },
                        style: GlowingButtonStyle.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 200.ms)
            .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
      ),
    );
  }

  // ==================== EXPORTAR TODOS ====================
  Future<void> _exportAllCharacters() async {
    if (_characters.isEmpty) return;

    final allCharactersJson = _characters.map((c) => c.toJson()).toList();
    final jsonString =
        const JsonEncoder.withIndent('  ').convert(allCharactersJson);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.obscureGray,
                AppTheme.abyssalBlack,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: AppTheme.ritualRed.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.ritualRed.withOpacity(0.3),
                blurRadius: 32,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.coldGray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.ritualRed, AppTheme.chaoticMagenta],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.ritualRed.withOpacity(0.4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.backup_rounded,
                        color: AppTheme.paleWhite,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EXPORTAR TODOS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Montserrat',
                              letterSpacing: 1.5,
                              color: AppTheme.paleWhite,
                            ),
                          ),
                          Text(
                            '${_characters.length} personagens',
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'Inter',
                              color: AppTheme.coldGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppTheme.industrialGray, height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CÓDIGO JSON (ARRAY)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'BebasNeue',
                          letterSpacing: 1.5,
                          color: AppTheme.ritualRed,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.abyssalBlack,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.ritualRed.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: SelectableText(
                          jsonString,
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'SpaceMono',
                            color: AppTheme.paleWhite,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.abyssalBlack.withOpacity(0.9),
                  border: Border(
                    top: BorderSide(color: AppTheme.industrialGray),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GlowingButton(
                        label: 'Fechar',
                        onPressed: () => Navigator.pop(context),
                        style: GlowingButtonStyle.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlowingButton(
                        label: 'Copiar',
                        icon: Icons.copy_rounded,
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: jsonString));
                          if (context.mounted) {
                            Navigator.pop(context);
                            _showSuccessSnackBar(
                                '${_characters.length} personagens copiados!');
                          }
                        },
                        style: GlowingButtonStyle.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0),
      ),
    );
  }

  // ==================== COMPARTILHAR PERSONAGEM ====================
  Future<void> _shareCharacter(Character character) async {
    try {
      final characterData = character.toJson();
      final jsonString =
          const JsonEncoder.withIndent('  ').convert(characterData);

      await Share.share(
        jsonString,
        subject: 'Personagem: ${character.nome}',
      );
    } catch (e) {
      _showErrorSnackBar('Erro ao compartilhar: $e');
    }
  }

  // ==================== BOTTOM SHEET: IMPORTAR ====================
  void _showImportBottomSheet() {
    final controller = TextEditingController();
    bool isValidating = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.obscureGray,
                    AppTheme.abyssalBlack,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(
                  color: AppTheme.chaoticMagenta.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.chaoticMagenta.withOpacity(0.3),
                    blurRadius: 32,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.coldGray.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header fixo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.chaoticMagenta,
                                AppTheme.etherealPurple
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.chaoticMagenta.withOpacity(0.4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.download_rounded,
                            color: AppTheme.paleWhite,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'IMPORTAR PERSONAGEM',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Montserrat',
                                  letterSpacing: 1.5,
                                  color: AppTheme.paleWhite,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Cole o JSON gerado',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'Inter',
                                  color: AppTheme.coldGray,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppTheme.industrialGray, height: 1),
                  // Body scrollável
                  Flexible(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // TextField com altura máxima
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 220,
                            ),
                            child: TextField(
                              controller: controller,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'SpaceMono',
                                color: AppTheme.paleWhite,
                                height: 1.6,
                              ),
                              decoration: InputDecoration(
                                hintText: '{\n  "nome": "...",\n  "classe": "...",\n  ...\n}',
                                hintStyle: TextStyle(
                                  color: AppTheme.coldGray.withOpacity(0.5),
                                  fontSize: 10,
                                ),
                                filled: true,
                                fillColor: AppTheme.abyssalBlack,
                                contentPadding: const EdgeInsets.all(14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: errorMessage != null
                                        ? AppTheme.alertYellow
                                        : AppTheme.chaoticMagenta.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: errorMessage != null
                                        ? AppTheme.alertYellow
                                        : AppTheme.coldGray.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppTheme.chaoticMagenta,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppTheme.alertYellow,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                if (errorMessage != null) {
                                  setModalState(() {
                                    errorMessage = null;
                                  });
                                }
                              },
                            ),
                          ),
                          // Container de erro com altura máxima
                          if (errorMessage != null) ...[
                            const SizedBox(height: 12),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 80),
                              child: SingleChildScrollView(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.alertYellow.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppTheme.alertYellow.withOpacity(0.5),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.warning_rounded,
                                        color: AppTheme.alertYellow,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          errorMessage!,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontFamily: 'Inter',
                                            color: AppTheme.alertYellow,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          GlowingButton(
                            label: 'Colar Área Transf.',
                            icon: Icons.paste_rounded,
                            onPressed: () async {
                              final data =
                                  await Clipboard.getData(Clipboard.kTextPlain);
                              if (data?.text != null) {
                                controller.text = data!.text!;
                                setModalState(() {
                                  errorMessage = null;
                                });
                              }
                            },
                            style: GlowingButtonStyle.secondary,
                            fullWidth: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Footer fixo com botões protegidos
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.abyssalBlack.withOpacity(0.9),
                      border: Border(
                        top: BorderSide(color: AppTheme.industrialGray),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: GlowingButton(
                                label: 'Cancelar',
                                onPressed: () => Navigator.pop(context),
                                style: GlowingButtonStyle.secondary,
                                width: 140,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: GlowingButton(
                                label: isValidating ? 'Validando...' : 'Importar',
                                icon: isValidating ? null : Icons.download_rounded,
                                onPressed: isValidating
                                    ? null
                                    : () async {
                                        final json = controller.text.trim();
                                        if (json.isEmpty) {
                                          setModalState(() {
                                            errorMessage = 'Cole o JSON primeiro';
                                          });
                                          return;
                                        }

                                        setModalState(() {
                                          isValidating = true;
                                          errorMessage = null;
                                        });

                                        try {
                                          jsonDecode(json);
                                          Navigator.pop(context);
                                          await _importFromJson(json);
                                        } catch (e) {
                                          setModalState(() {
                                            isValidating = false;
                                            errorMessage =
                                                'JSON inválido: ${e.toString()}';
                                          });
                                        }
                                      },
                                style: GlowingButtonStyle.primary,
                                width: 140,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0),
          ),
        ),
      ),
    );
  }

  // ==================== IMPORTAR DA CLIPBOARD ====================
  Future<void> _importFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text == null || data!.text!.trim().isEmpty) {
        _showErrorSnackBar('Área de transferência vazia');
        return;
      }

      await _importFromJson(data.text!);
    } catch (e) {
      _showErrorSnackBar('Erro ao ler área de transferência: $e');
    }
  }

  // ==================== PROCESSAR IMPORT JSON ====================
  Future<void> _importFromJson(String jsonString) async {
    try {
      final jsonData = jsonDecode(jsonString);

      if (jsonData is List) {
        // Múltiplos personagens
        int imported = 0;
        for (var charJson in jsonData) {
          final character = Character.fromJson(charJson);
          final updatedChar = character.copyWith(createdBy: _userId);
          await _databaseService.createCharacter(updatedChar);
          imported++;
        }
        if (mounted) {
          _showSuccessSnackBar('$imported personagens importados!');
          _loadCharacters();
        }
      } else {
        // Personagem único
        final character = Character.fromJson(jsonData);
        final updatedChar = character.copyWith(createdBy: _userId);
        await _databaseService.createCharacter(updatedChar);
        if (mounted) {
          _showSuccessSnackBar('${character.nome} importado!');
          _loadCharacters();
        }
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao importar: $e');
    }
  }

  // ==================== SNACKBARS ====================
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppTheme.paleWhite, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.mutagenGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded,
                color: AppTheme.paleWhite, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.ritualRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ==================== WIDGET: CHARACTER EXPORT CARD ====================
class CharacterExportCard extends StatelessWidget {
  final Character character;
  final int index;
  final VoidCallback onExport;
  final VoidCallback onShare;

  const CharacterExportCard({
    super.key,
    required this.character,
    required this.index,
    required this.onExport,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.obscureGray,
            AppTheme.abyssalBlack,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.industrialGray,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.ritualRed.withOpacity(0.0),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onExport,
          borderRadius: BorderRadius.circular(12),
          splashColor: AppTheme.ritualRed.withOpacity(0.2),
          highlightColor: AppTheme.ritualRed.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.ritualRed, AppTheme.chaoticMagenta],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.ritualRed.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      character.nome.isNotEmpty
                          ? character.nome[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.paleWhite,
                        fontFamily: 'BebasNeue',
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        character.nome.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Montserrat',
                          letterSpacing: 1.2,
                          color: AppTheme.paleWhite,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.etherealPurple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppTheme.etherealPurple.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              character.classe.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Montserrat',
                                letterSpacing: 0.5,
                                color: AppTheme.etherealPurple,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'NEX ${character.nex}%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: AppTheme.coldGray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                IconButton(
                  icon: const Icon(Icons.share_rounded, size: 20),
                  color: AppTheme.etherealPurple,
                  onPressed: onShare,
                  tooltip: 'Compartilhar',
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.coldGray.withOpacity(0.5),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 60 + 200).ms, duration: 300.ms)
        .slideX(begin: -0.2, end: 0, curve: Curves.easeOutCubic);
  }
}
