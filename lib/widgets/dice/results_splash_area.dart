import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../models/dice_result.dart';
import '../../models/dice_pool.dart';
import '../hexatombe_ui_components.dart';
import 'dice_pool_display.dart';
import 'dice_result_display.dart';

/// Área de invocação onde os resultados "respingam"
class ResultsSplashArea extends StatefulWidget {
  final DicePool pool;
  final List<DiceResult> results;
  final int? total;
  final bool isRolling;
  final Function(String diceId) onRemoveDice;

  const ResultsSplashArea({
    super.key,
    required this.pool,
    required this.results,
    required this.total,
    required this.isRolling,
    required this.onRemoveDice,
  });

  @override
  State<ResultsSplashArea> createState() => _ResultsSplashAreaState();
}

class _ResultsSplashAreaState extends State<ResultsSplashArea>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(ResultsSplashArea oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Anima quando novos resultados aparecem
    if (widget.results.isNotEmpty && oldWidget.results.isEmpty) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GrungeBackground(
      baseColor: const Color(0xFF1a1a1a),
      opacity: 0.08,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.40,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    // Estado 1: Rolando
    if (widget.isRolling) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '⚡ INVOCANDO... ⚡',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 3.0,
                color: AppColors.scarletRed,
                fontFamily: 'monospace',
                shadows: [
                  Shadow(
                    color: AppColors.scarletRed.withOpacity(0.8),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Estado 2: Resultados visíveis (DEPOIS de rolar)
    if (widget.results.isNotEmpty && widget.total != null) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Dados individuais coloridos com valores
            DiceResultDisplay(results: widget.results),

            // Total centralizado
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 140), // Espaço para os dados acima

                    // Label "TOTAL"
                    Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3.0,
                        color: const Color(0xFFe0e0e0).withOpacity(0.7),
                        fontFamily: 'monospace',
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Número gigante
                    Text(
                      '${widget.total}',
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: AppColors.scarletRed,
                        height: 1.0,
                        shadows: [
                          Shadow(
                            color: AppColors.scarletRed,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Estado 3: Pool pronto (ANTES de rolar) - mostra dadinhos acumulados
    if (widget.pool.dice.isNotEmpty) {
      return SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Label
                Text(
                  'DADOS PREPARADOS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3.0,
                    color: const Color(0xFFe0e0e0).withOpacity(0.7),
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 24),

                // Pool de dados coloridos
                DicePoolDisplay(
                  pool: widget.pool,
                  onRemoveDice: widget.onRemoveDice,
                ),

                const SizedBox(height: 16),

                // Hint
                Text(
                  'Clique em ROLAR para invocar',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.0,
                    color: const Color(0xFF888888).withOpacity(0.5),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Estado 4: Aguardando (vazio)
    return Center(
      child: Text(
        'AGUARDANDO RITUAL',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          color: const Color(0xFF888888).withOpacity(0.5),
          fontFamily: 'monospace',
        ),
      ),
    );
  }

}
