import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/dice_roll_history.dart';
import '../../core/database/dice_repository.dart';
import '../../widgets/dice/hexagon_result_badge.dart';
import '../../widgets/hexatombe_ui_components.dart';

/// Tela de histórico completo de rolagens de dados
/// Mostra TODOS os rolls com opção de limpar histórico
class DiceHistoryScreen extends StatefulWidget {
  final List<DiceRollHistory> initialHistory;

  const DiceHistoryScreen({
    super.key,
    required this.initialHistory,
  });

  @override
  State<DiceHistoryScreen> createState() => _DiceHistoryScreenState();
}

class _DiceHistoryScreenState extends State<DiceHistoryScreen> {
  final _repository = DiceRepository();
  late List<DiceRollHistory> _history;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _history = widget.initialHistory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: AppColors.darkGray,
        elevation: 0,
        title: Text('HISTÓRICO COMPLETO', style: AppTextStyles.title),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.neonRed),
              onPressed: _confirmClearHistory,
              tooltip: 'Limpar histórico',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.magenta),
            )
          : _history.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.casino, size: 64, color: AppColors.silver.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'NENHUMA ROLAGEM',
            style: AppTextStyles.uppercase.copyWith(
              color: AppColors.silver.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Seu histórico está vazio',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.silver.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final entry = _history[index];
        return _buildHistoryItem(entry, index);
      },
    );
  }

  Widget _buildHistoryItem(DiceRollHistory entry, int index) {
    final time = '${entry.timestamp.hour.toString().padLeft(2, '0')}:'
        '${entry.timestamp.minute.toString().padLeft(2, '0')}:'
        '${entry.timestamp.second.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              // Timestamp
              Text(
                time,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF888888),
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 16),

              // Fórmula
              Expanded(
                child: Text(
                  entry.formula,
                  style: const TextStyle(
                    color: Color(0xFFe0e0e0),
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Total em hexágono vermelho
              HexagonResultBadge(
                value: entry.total,
                isSmall: true,
              ),
            ],
          ),
        ),
        // Divisor arranhado
        const GrungeDivider(heavy: false),
      ],
    );
  }

  Future<void> _confirmClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text(
          'LIMPAR HISTÓRICO?',
          style: TextStyle(color: AppColors.lightGray),
        ),
        content: const Text(
          'Esta ação irá excluir todas as rolagens do histórico. Esta ação não pode ser desfeita.',
          style: TextStyle(color: AppColors.silver),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonRed,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('LIMPAR TUDO'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        await _repository.clearHistory();
        setState(() {
          _history.clear();
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Histórico limpo com sucesso!'),
              backgroundColor: AppColors.conhecimentoGreen,
            ),
          );
          // Retorna true para indicar que o histórico foi limpo
          Navigator.pop(context, true);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao limpar histórico: $e'),
              backgroundColor: AppColors.neonRed,
            ),
          );
        }
      }
    }
  }
}
