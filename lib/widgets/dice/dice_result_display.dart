import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../models/dice_result.dart';
import '../../models/dice_pool.dart';
import 'dice_shape_painters.dart';

/// Widget que mostra os resultados individuais DEPOIS de rolar
class DiceResultDisplay extends StatelessWidget {
  final List<DiceResult> results;

  const DiceResultDisplay({
    super.key,
    required this.results,
  });

  /// Retorna cor vibrante do Google Dice Roller para cada tipo de dado (mesma lógica do pool)
  Color _getDiceColor(DiceType type) {
    switch (type) {
      case DiceType.d4:
        return const Color(0xFF00BCD4); // Azul-piscina (Cyan)
      case DiceType.d6:
        return const Color(0xFF9C27B0); // Roxo
      case DiceType.d8:
        return const Color(0xFF673AB7); // Roxo/Violeta
      case DiceType.d10:
        return const Color(0xFFE91E63); // Rosa/Magenta
      case DiceType.d12:
        return const Color(0xFFF44336); // Vermelho
      case DiceType.d20:
        return const Color(0xFFFF9800); // Laranja
      case DiceType.d100:
        return const Color(0xFFFFEB3B); // Amarelo
    }
  }

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final random = math.Random(DateTime.now().millisecondsSinceEpoch); // Seed variável para posições diferentes
    final widgets = <Widget>[];
    final centerPositions = <Offset>[]; // Guarda centros dos dados para evitar colisão

    const diceSize = 64.0;
    const minSpacing = 12.0; // Espaçamento mínimo seguro (dados bem próximos)
    const minDistanceBetweenCenters = diceSize + minSpacing; // 76px

    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      final color = _getDiceColor(result.type);

      double left = 0;
      double top = 0;
      bool foundPosition = false;
      int attempts = 0;
      const maxAttempts = 150; // Tentativas para posição aleatória

      // Tenta encontrar posição aleatória sem colisão
      while (!foundPosition && attempts < maxAttempts) {
        attempts++;

        // Gera posição aleatória com margens seguras
        const margin = 40.0;
        left = margin + random.nextDouble() * (screenWidth - diceSize - margin * 2);
        top = 20.0 + random.nextDouble() * 150; // Área controlada (150px de altura)

        // Calcula centro do dado
        final centerX = left + diceSize / 2;
        final centerY = top + diceSize / 2;

        // Verifica distância entre centros (mais preciso que overlap)
        bool collides = false;
        for (final center in centerPositions) {
          final distance = math.sqrt(
            math.pow(centerX - center.dx, 2) +
            math.pow(centerY - center.dy, 2)
          );

          if (distance < minDistanceBetweenCenters) {
            collides = true;
            break;
          }
        }

        if (!collides) {
          foundPosition = true;
          centerPositions.add(Offset(centerX, centerY));
        }
      }

      // Fallback: grid automático COM verificação de colisão
      if (!foundPosition) {
        final cols = math.max(4, math.min(6, (screenWidth / (diceSize + 16)).floor()));

        // Tenta até 30 posições no grid
        for (int gridAttempt = 0; gridAttempt < 30; gridAttempt++) {
          final gridIndex = i + gridAttempt;
          final col = gridIndex % cols;
          final row = gridIndex ~/ cols;

          left = 40.0 + col * (diceSize + 16); // Margem de 40px
          top = 20.0 + row * (diceSize + 16);

          final centerX = left + diceSize / 2;
          final centerY = top + diceSize / 2;

          // Verifica se esta posição do grid colide
          bool gridCollides = false;
          for (final center in centerPositions) {
            final distance = math.sqrt(
              math.pow(centerX - center.dx, 2) +
              math.pow(centerY - center.dy, 2)
            );

            if (distance < minDistanceBetweenCenters) {
              gridCollides = true;
              break;
            }
          }

          // Se não colide, usa esta posição
          if (!gridCollides) {
            centerPositions.add(Offset(centerX, centerY));
            foundPosition = true;
            break;
          }
        }
      }

      // Último recurso: força uma posição bem afastada
      if (!foundPosition) {
        final gridIndex = i + 100; // Bem longe
        final cols = 6;
        final col = gridIndex % cols;
        final row = gridIndex ~/ cols;

        left = 40.0 + col * (diceSize + 16); // Margem de 40px
        top = 20.0 + row * (diceSize + 16);

        centerPositions.add(Offset(left + diceSize / 2, top + diceSize / 2));
      }

      // Rotação aleatória leve (reduzida para evitar aparência de colisão)
      final rotation = (random.nextDouble() - 0.5) * 0.15; // ±4° (era ±8°)

      widgets.add(
        Positioned(
          left: left,
          top: top,
          child: Transform.rotate(
            angle: rotation,
            child: _buildResultDice(result, color),
          ),
        ),
      );
    }

    return Stack(
      children: widgets,
    );
  }

  Widget _buildResultDice(DiceResult result, Color color) {
    return DiceShapeWidget(
      faces: result.type.sides,
      color: color,
      size: 64,
      hasGlow: true,
      strokeWidth: 2,
      child: Text(
        '${result.value}',
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              offset: Offset(2, 2),
              blurRadius: 4,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
