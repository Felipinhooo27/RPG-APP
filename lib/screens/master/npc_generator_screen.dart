import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/npc_personality_generator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Tela de Geração de NPCs com Personalidade
/// Sistema procedural que cria personagens únicos para o Mestre
class NPCGeneratorScreen extends StatefulWidget {
  const NPCGeneratorScreen({super.key});

  @override
  State<NPCGeneratorScreen> createState() => _NPCGeneratorScreenState();
}

class _NPCGeneratorScreenState extends State<NPCGeneratorScreen> {
  final NPCPersonalityGenerator _generator = NPCPersonalityGenerator();
  NPCPersonality? _currentNPC;
  bool _isGenerating = false;

  final TextEditingController _nameController = TextEditingController();
  String? _selectedOrigem;

  final List<String> _origens = [
    'academico',
    'agente',
    'artista',
    'criminoso',
    'investigador',
    'policial',
    'militar',
    'medico',
    'jornalista',
  ];

  @override
  void initState() {
    super.initState();
    _generateNPC(); // Gera um NPC inicial
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _generateNPC() {
    setState(() {
      _isGenerating = true;
    });

    // Delay para efeito dramático
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _currentNPC = _generator.generate(
          nome: _nameController.text.isEmpty ? null : _nameController.text,
          origem: _selectedOrigem,
        );
        _isGenerating = false;
      });
    });
  }

  void _copyToClipboard() {
    if (_currentNPC == null) return;

    Clipboard.setData(ClipboardData(text: _currentNPC!.toFormattedText()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.conhecimentoGreen),
            const SizedBox(width: 12),
            Text(
              'NPC COPIADO PARA ÁREA DE TRANSFERÊNCIA',
              style: AppTextStyles.uppercase.copyWith(fontSize: 11),
            ),
          ],
        ),
        backgroundColor: AppColors.darkGray,
        behavior: SnackBarBehavior.floating,
        shape: Border.all(color: AppColors.conhecimentoGreen),
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
          'GERADOR DE NPCs',
          style: AppTextStyles.uppercase.copyWith(fontSize: 14),
        ),
        iconTheme: const IconThemeData(color: AppColors.lightGray),
        actions: [
          if (_currentNPC != null)
            IconButton(
              icon: const Icon(Icons.copy, color: AppColors.conhecimentoGreen),
              onPressed: _copyToClipboard,
              tooltip: 'Copiar NPC',
            ),
        ],
      ),
      body: Column(
        children: [
          // Controles de Geração
          _buildGenerationControls(),

          // NPC Gerado
          Expanded(
            child: _isGenerating
                ? _buildLoadingState()
                : _currentNPC != null
                    ? _buildNPCDisplay()
                    : const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isGenerating ? null : _generateNPC,
        backgroundColor: AppColors.scarletRed,
        icon: const Icon(Icons.casino, color: AppColors.lightGray),
        label: Text(
          'GERAR NPC',
          style: AppTextStyles.uppercase.copyWith(
            fontSize: 12,
            color: AppColors.lightGray,
          ),
        ),
      ),
    );
  }

  Widget _buildGenerationControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border(
          bottom: BorderSide(color: AppColors.scarletRed.withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERSONALIZAR GERAÇÃO',
            style: AppTextStyles.uppercase.copyWith(
              fontSize: 11,
              color: AppColors.lightGray,
            ),
          ),
          const SizedBox(height: 12),

          // Campo de Nome (opcional)
          TextField(
            controller: _nameController,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              labelText: 'Nome (opcional)',
              labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.silver),
              hintText: 'Deixe vazio para gerar automaticamente',
              hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.silver.withOpacity(0.5)),
              filled: true,
              fillColor: AppColors.deepBlack,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.silver.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.silver.withOpacity(0.3)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.scarletRed, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Dropdown de Origem (opcional)
          DropdownButtonFormField<String>(
            value: _selectedOrigem,
            dropdownColor: AppColors.darkGray,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              labelText: 'Origem (opcional)',
              labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.silver),
              filled: true,
              fillColor: AppColors.deepBlack,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.silver.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.silver.withOpacity(0.3)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.scarletRed, width: 2),
              ),
            ),
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(
                  'Aleatória',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.silver.withOpacity(0.5)),
                ),
              ),
              ..._origens.map((origem) {
                return DropdownMenuItem<String>(
                  value: origem,
                  child: Text(
                    origem.toUpperCase(),
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightGray),
                  ),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedOrigem = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: const AlwaysStoppedAnimation(AppColors.scarletRed),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1500.ms, color: AppColors.neonRed.withOpacity(0.3)),
          const SizedBox(height: 24),
          Text(
            'GERANDO NPC...',
            style: AppTextStyles.uppercase.copyWith(
              fontSize: 14,
              color: AppColors.scarletRed,
              letterSpacing: 2.0,
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .fadeIn(duration: 800.ms)
              .then()
              .fadeOut(duration: 800.ms),
        ],
      ),
    );
  }

  Widget _buildNPCDisplay() {
    if (_currentNPC == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com Nome
          _buildHeaderCard(),
          const SizedBox(height: 16),

          // Personalidade
          _buildInfoCard(
            'PERSONALIDADE',
            _currentNPC!.personalidade,
            Icons.psychology,
            AppColors.magenta,
            0,
          ),
          const SizedBox(height: 12),

          // Motivação
          _buildInfoCard(
            'MOTIVAÇÃO',
            _currentNPC!.motivacao,
            Icons.bolt,
            AppColors.energiaYellow,
            1,
          ),
          const SizedBox(height: 12),

          // Segredo
          _buildInfoCard(
            'SEGREDO',
            _currentNPC!.segredo,
            Icons.lock,
            AppColors.neonRed,
            2,
          ),
          const SizedBox(height: 12),

          // Medo
          _buildInfoCard(
            'MEDO',
            _currentNPC!.medo,
            Icons.warning,
            AppColors.medoPurple,
            3,
          ),
          const SizedBox(height: 12),

          // Objetivo
          _buildInfoCard(
            'OBJETIVO',
            _currentNPC!.objetivo,
            Icons.flag,
            AppColors.conhecimentoGreen,
            4,
          ),
          const SizedBox(height: 12),

          // Background
          _buildInfoCard(
            'BACKGROUND',
            _currentNPC!.background,
            Icons.book,
            AppColors.pvRed,
            5,
          ),
          const SizedBox(height: 12),

          // Peculiaridade
          _buildInfoCard(
            'PECULIARIDADE',
            _currentNPC!.quirk,
            Icons.star,
            AppColors.pePurple,
            6,
          ),
          const SizedBox(height: 12),

          // Relacionamento
          _buildInfoCard(
            'RELACIONAMENTO CHAVE',
            _currentNPC!.relacionamento,
            Icons.people,
            AppColors.sanYellow,
            7,
          ),

          const SizedBox(height: 80), // Espaço para o FAB
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border.all(color: AppColors.scarletRed, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.scarletRed.withOpacity(0.3),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.person,
            size: 48,
            color: AppColors.scarletRed,
          ).animate().scale(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 12),
          Text(
            _currentNPC!.nome.toUpperCase(),
            style: AppTextStyles.uppercase.copyWith(
              fontSize: 20,
              color: AppColors.scarletRed,
              letterSpacing: 2.0,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.scarletRed.withOpacity(0.2),
              border: Border.all(color: AppColors.scarletRed),
            ),
            child: Text(
              'NPC GERADO PROCEDURALMENTE',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.scarletRed,
                letterSpacing: 1.5,
              ),
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildInfoCard(
    String label,
    String content,
    IconData icon,
    Color color,
    int index,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTextStyles.body.copyWith(
              color: AppColors.lightGray,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 80).ms).fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0);
  }
}
