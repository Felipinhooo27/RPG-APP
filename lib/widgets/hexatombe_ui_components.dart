import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/theme/app_colors.dart';

/// Componentes UI temáticos do Hexatombe
/// Design "Cultista/Grimório Assombrado" - SEM caixas genéricas

// =============================================================================
// BARRA DE STATUS - Design minimalista SEM bordas
// =============================================================================

class HexatombeStatusBar extends StatelessWidget {
  final String title; // "PONTOS DE VIDA"
  final int current;
  final int max;
  final Color fillColor; // Cor da barra de preenchimento
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const HexatombeStatusBar({
    super.key,
    required this.title,
    required this.current,
    required this.max,
    required this.fillColor,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título (sem caixa)
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: fillColor, // Usa a cor da barra
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 8),

        // Barra de status (SEM BORDAS)
        Stack(
          children: [
            // Contêiner da barra (fundo escuro sólido)
            Container(
              height: 40,
              color: const Color(0xFF1a1a1a),
            ),

            // Preenchimento
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 40,
                color: fillColor,
              ),
            ),

            // Texto sobre a barra
            Container(
              height: 40,
              alignment: Alignment.center,
              child: Text(
                '$current / $max',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFe0e0e0),
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Botões +/- (apenas texto, sem bordas)
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _buildControlButton('-', onDecrement),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildControlButton('+', onIncrement),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton(String symbol, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        color: const Color(0xFF0d0d0d),
        child: Text(
          symbol,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// STAT SIMPLES DE COMBATE - SEM hexágono, apenas texto limpo
// =============================================================================

class HexagonStat extends StatelessWidget {
  final String label; // "DEFESA"
  final String value; // "11"
  final Color color;

  const HexagonStat({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Valor grande
        Text(
          value,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFFe0e0e0),
            height: 1.0,
          ),
        ),

        const SizedBox(height: 4),

        // Label abaixo (pequeno)
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: color,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// DIVISOR GRUNGE - Linha "arranhada" temática APRIMORADO
// =============================================================================

class GrungeDivider extends StatelessWidget {
  final Color color;
  final double height;
  final bool heavy; // Linha mais pesada/distorcida

  const GrungeDivider({
    super.key,
    this.color = AppColors.scarletRed,
    this.height = 1,
    this.heavy = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _GrungeDividerPainter(color: color, heavy: heavy),
    );
  }
}

class _GrungeDividerPainter extends CustomPainter {
  final Color color;
  final bool heavy;

  _GrungeDividerPainter({required this.color, required this.heavy});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Seed fixo para consistência

    // Linha principal arranhada
    final mainPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = heavy ? 2 : 1
      ..style = PaintingStyle.stroke;

    final mainPath = Path();
    mainPath.moveTo(0, size.height / 2);

    double x = 0;
    while (x < size.width) {
      final variance = heavy ? 4.0 : 2.0;
      final y = size.height / 2 + (random.nextDouble() - 0.5) * variance;
      mainPath.lineTo(x, y);
      x += 8 + random.nextDouble() * 15;
    }
    canvas.drawPath(mainPath, mainPaint);

    // Linhas secundárias "rachadas" para efeito grunge
    if (heavy) {
      final crackPaint = Paint()
        ..color = color.withOpacity(0.2)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      // 3-5 rachaduras aleatórias
      final crackCount = 3 + random.nextInt(3);
      for (int i = 0; i < crackCount; i++) {
        final startX = random.nextDouble() * size.width;
        final length = 15 + random.nextDouble() * 25;
        final offsetY = (random.nextDouble() - 0.5) * 8;

        final crackPath = Path();
        crackPath.moveTo(startX, size.height / 2 + offsetY);
        crackPath.lineTo(startX + length, size.height / 2 + offsetY + (random.nextDouble() - 0.5) * 6);
        canvas.drawPath(crackPath, crackPaint);
      }
    }

    // Pequenos pontos de "sangue" ou "respingos"
    final dotPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final dotCount = heavy ? 8 : 4;
    for (int i = 0; i < dotCount; i++) {
      final dotX = random.nextDouble() * size.width;
      final dotY = size.height / 2 + (random.nextDouble() - 0.5) * 3;
      final dotSize = 0.5 + random.nextDouble() * 1.5;
      canvas.drawCircle(Offset(dotX, dotY), dotSize, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// CABEÇALHO DE LÂMINA - Para seções de detalhamento
// =============================================================================

class BladeHeader extends StatelessWidget {
  final String title;
  final Color color;

  const BladeHeader({
    super.key,
    required this.title,
    this.color = AppColors.scarletRed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          color: color,
        ),
      ),
    );
  }
}

// =============================================================================
// FUNDO GRUNGE - Textura de fundo para atmosfera
// =============================================================================

class GrungeBackground extends StatelessWidget {
  final Widget child;
  final Color baseColor;
  final double opacity;

  const GrungeBackground({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFF0d0d0d),
    this.opacity = 0.05,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Cor base
        Container(color: baseColor),

        // Textura grunge
        Positioned.fill(
          child: CustomPaint(
            painter: _GrungeTexturePainter(opacity: opacity),
          ),
        ),

        // Conteúdo sobre a textura
        child,
      ],
    );
  }
}

class _GrungeTexturePainter extends CustomPainter {
  final double opacity;

  _GrungeTexturePainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(123); // Seed fixo para consistência

    // Ruído de fundo (noise)
    final noisePaint = Paint()..style = PaintingStyle.fill;

    // Desenha pixels aleatórios para criar textura de ruído
    for (int i = 0; i < 800; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final alpha = random.nextDouble() * opacity;

      noisePaint.color = Color.fromRGBO(255, 255, 255, alpha);
      canvas.drawCircle(Offset(x, y), 0.5, noisePaint);
    }

    // Arranhões verticais aleatórios
    final scratchPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < 12; i++) {
      final x = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height * 0.3;
      final length = 40 + random.nextDouble() * 100;
      final alpha = random.nextDouble() * (opacity * 0.8);

      scratchPaint.color = Color.fromRGBO(0, 0, 0, alpha);

      final path = Path();
      path.moveTo(x, startY);

      double currentY = startY;
      while (currentY < startY + length) {
        currentY += 5 + random.nextDouble() * 10;
        final offsetX = x + (random.nextDouble() - 0.5) * 2;
        path.lineTo(offsetX, currentY);
      }

      canvas.drawPath(path, scratchPaint);
    }

    // Manchas escuras (bloodstains style)
    final stainPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 3 + random.nextDouble() * 12;
      final alpha = random.nextDouble() * (opacity * 0.4);

      stainPaint.color = Color.fromRGBO(0, 0, 0, alpha);

      // Mancha principal
      canvas.drawCircle(Offset(x, y), radius, stainPaint);

      // "Respingos" ao redor
      for (int j = 0; j < 3; j++) {
        final splatterX = x + (random.nextDouble() - 0.5) * radius * 3;
        final splatterY = y + (random.nextDouble() - 0.5) * radius * 3;
        final splatterRadius = radius * (0.2 + random.nextDouble() * 0.3);

        canvas.drawCircle(Offset(splatterX, splatterY), splatterRadius, stainPaint);
      }
    }

    // Vinheta sutil nas bordas
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(opacity * 2),
        ],
        stops: const [0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignettePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// STAT SIMPLES - Para NEX e Patente (apenas tipografia, zero caixas)
// =============================================================================

class SimpleStat extends StatelessWidget {
  final String label; // "NEX"
  final String value; // "10%"
  final Color labelColor;
  final Color valueColor;

  const SimpleStat({
    super.key,
    required this.label,
    required this.value,
    this.labelColor = AppColors.scarletRed,
    this.valueColor = const Color(0xFFe0e0e0),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.5,
            color: labelColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFFe0e0e0),
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// TÍTULO DE SEÇÃO - Substitui caixas de título
// =============================================================================

class SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const SectionTitle({
    super.key,
    required this.title,
    this.color = AppColors.scarletRed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.5,
          color: color,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

// =============================================================================
// ARCHIVE LIST ITEM - Item de navegação estilo "índice de arquivo"
// =============================================================================

class ArchiveListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int count;
  final VoidCallback onTap;

  const ArchiveListItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            // Ícone (sem colorir, branco-osso)
            Icon(
              icon,
              color: const Color(0xFFe0e0e0),
              size: 28,
            ),

            const SizedBox(width: 16),

            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Color(0xFFe0e0e0),
                      fontFamily: 'monospace',
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Descrição
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888888),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Badge de contagem (minimalista)
            Text(
              '$count ITENS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: AppColors.scarletRed.withOpacity(0.7),
              ),
            ),

            const SizedBox(width: 12),

            // Seta chevron
            Icon(
              Icons.chevron_right,
              color: AppColors.scarletRed,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// DOSSIER ENTRY - Entrada de dossiê para texto informativo
// =============================================================================

class DossierEntry extends StatelessWidget {
  final String title;
  final String description;
  final Color titleColor;

  const DossierEntry({
    super.key,
    required this.title,
    required this.description,
    this.titleColor = AppColors.scarletRed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da entrada
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: titleColor,
            fontFamily: 'monospace',
          ),
        ),

        const SizedBox(height: 8),

        // Descrição
        Text(
          description,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFFe0e0e0),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// RUNA DE ATRIBUTO - Pentágono assimétrico paranormal
// =============================================================================

class RunaAtributo extends StatelessWidget {
  final int forca;
  final int agilidade;
  final int vigor;
  final int intelecto;
  final int presenca;

  const RunaAtributo({
    super.key,
    required this.forca,
    required this.agilidade,
    required this.vigor,
    required this.intelecto,
    required this.presenca,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 320,
      child: CustomPaint(
        painter: _RunaAtributoPainter(
          forca: forca,
          agilidade: agilidade,
          vigor: vigor,
          intelecto: intelecto,
          presenca: presenca,
        ),
      ),
    );
  }
}

class _RunaAtributoPainter extends CustomPainter {
  final int forca;
  final int agilidade;
  final int vigor;
  final int intelecto;
  final int presenca;

  _RunaAtributoPainter({
    required this.forca,
    required this.agilidade,
    required this.vigor,
    required this.intelecto,
    required this.presenca,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.40;
    final maxAttribute = 5; // Atributos vão de 0-5

    // Define posições assimétricas dos atributos (pentágono distorcido)
    final positions = [
      _getAttributePosition(center, maxRadius, 0, -0.95), // FORÇA (topo)
      _getAttributePosition(center, maxRadius, 0.85, -0.35), // AGILIDADE (direita-cima)
      _getAttributePosition(center, maxRadius, 0.6, 0.8), // VIGOR (direita-baixo)
      _getAttributePosition(center, maxRadius, -0.6, 0.8), // INTELECTO (esquerda-baixo)
      _getAttributePosition(center, maxRadius, -0.85, -0.35), // PRESENÇA (esquerda-cima)
    ];

    final attributes = [forca, agilidade, vigor, intelecto, presenca];
    final colors = [
      AppColors.forRed,
      AppColors.agiGreen,
      AppColors.vigBlue,
      AppColors.intMagenta,
      AppColors.preGold,
    ];
    final labels = ['FOR', 'AGI', 'VIG', 'INT', 'PRE'];

    // Desenha linhas de grade (círculos concêntricos)
    final gridPaint = Paint()
      ..color = AppColors.scarletRed.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(center, maxRadius * (i / 5), gridPaint);
    }

    // Desenha linhas conectando os pontos (pentágono base)
    final linePaint = Paint()
      ..color = AppColors.scarletRed.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 5; i++) {
      canvas.drawLine(positions[i], positions[(i + 1) % 5], linePaint);
    }

    // Desenha linhas do centro para cada ponto
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(center, positions[i], linePaint);
    }

    // Desenha a runa de valores atuais
    final valuePath = Path();
    final valuePositions = <Offset>[];

    for (int i = 0; i < 5; i++) {
      final ratio = (attributes[i] / maxAttribute).clamp(0.0, 1.0);
      final valuePos = Offset(
        center.dx + (positions[i].dx - center.dx) * ratio,
        center.dy + (positions[i].dy - center.dy) * ratio,
      );
      valuePositions.add(valuePos);

      if (i == 0) {
        valuePath.moveTo(valuePos.dx, valuePos.dy);
      } else {
        valuePath.lineTo(valuePos.dx, valuePos.dy);
      }
    }
    valuePath.close();

    // Preenche a área da runa
    final fillPaint = Paint()
      ..color = AppColors.scarletRed.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawPath(valuePath, fillPaint);

    // Contorno da runa
    final strokePaint = Paint()
      ..color = AppColors.scarletRed.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(valuePath, strokePaint);

    // Desenha pontos e textos nos vértices
    for (int i = 0; i < 5; i++) {
      // Ponto no vértice
      final pointPaint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;
      canvas.drawCircle(valuePositions[i], 4, pointPaint);

      // Label do atributo
      final labelPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: colors[i],
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();

      // Posiciona o label além do ponto externo
      final labelOffset = Offset(
        positions[i].dx - labelPainter.width / 2,
        positions[i].dy + (positions[i].dy > center.dy ? 8 : -labelPainter.height - 8),
      );
      labelPainter.paint(canvas, labelOffset);

      // Valor do atributo
      final valuePainter = TextPainter(
        text: TextSpan(
          text: attributes[i].toString(),
          style: const TextStyle(
            color: Color(0xFFe0e0e0),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      valuePainter.layout();

      // Posiciona o valor próximo ao ponto
      final valueOffset = Offset(
        valuePositions[i].dx - valuePainter.width / 2,
        valuePositions[i].dy - valuePainter.height / 2,
      );
      valuePainter.paint(canvas, valueOffset);
    }

    // Símbolo central (círculo com cruz)
    final centerPaint = Paint()
      ..color = AppColors.scarletRed.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 8, centerPaint);
    canvas.drawLine(
      Offset(center.dx - 5, center.dy),
      Offset(center.dx + 5, center.dy),
      centerPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 5),
      Offset(center.dx, center.dy + 5),
      centerPaint,
    );
  }

  Offset _getAttributePosition(Offset center, double radius, double x, double y) {
    return Offset(
      center.dx + radius * x,
      center.dy + radius * y,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =============================================================================
// HEXATOMBE TEXT FIELD - Input padrão "Dossiê" (label + linha vermelha)
// =============================================================================

class HexatombeTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final int? maxLines;

  const HexatombeTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label em Branco-Osso
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Color(0xFFe0e0e0),
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 8),

        // TextField sem bordas, apenas linha inferior vermelha
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFFe0e0e0),
            letterSpacing: 0.5,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: const Color(0xFF666666),
              fontSize: 16,
            ),
            border: InputBorder.none,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.scarletRed.withOpacity(0.3),
                width: 1,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.scarletRed,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// HEXATOMBE DROPDOWN - Dropdown temático (label + valor + seta vermelha)
// =============================================================================

class HexatombeDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hintText;

  const HexatombeDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label em Branco-Osso
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Color(0xFFe0e0e0),
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 8),

        // Dropdown sem caixa, apenas linha inferior vermelha
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.scarletRed.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.darkGray,
              icon: Icon(
                Icons.arrow_drop_down,
                color: AppColors.scarletRed,
                size: 28,
              ),
              hint: hintText != null
                  ? Text(
                      hintText!,
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 16,
                      ),
                    )
                  : null,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFFe0e0e0),
                letterSpacing: 0.5,
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// HEXATOMBE SLIDER - Slider com visual aprimorado (trilha escura, polegar colorido)
// =============================================================================

class HexatombeSlider extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final Color color;
  final ValueChanged<int> onChanged;

  const HexatombeSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label com cor do atributo
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: color,
                fontFamily: 'monospace',
              ),
            ),
            // Valor atual
            Text(
              value >= 0 ? '+$value' : '$value',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFe0e0e0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Slider customizado
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            activeTrackColor: color,
            inactiveTrackColor: const Color(0xFF2a2a2a),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: (val) => onChanged(val.toInt()),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// HEXAGON CHECKBOX - Checkbox hexagonal temático
// =============================================================================

class HexagonCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;

  const HexagonCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: CustomPaint(
        size: Size(size, size),
        painter: _HexagonCheckboxPainter(
          isChecked: value,
          color: AppColors.scarletRed,
        ),
      ),
    );
  }
}

class _HexagonCheckboxPainter extends CustomPainter {
  final bool isChecked;
  final Color color;

  _HexagonCheckboxPainter({required this.isChecked, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Desenha hexágono
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Preenchimento se marcado
    if (isChecked) {
      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);
    }

    // Contorno
    final strokePaint = Paint()
      ..color = isChecked ? color : color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, strokePaint);

    // Marca de check se marcado
    if (isChecked) {
      final checkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      final checkPath = Path();
      checkPath.moveTo(center.dx - radius * 0.4, center.dy);
      checkPath.lineTo(center.dx - radius * 0.1, center.dy + radius * 0.3);
      checkPath.lineTo(center.dx + radius * 0.4, center.dy - radius * 0.3);

      canvas.drawPath(checkPath, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =============================================================================
// STAT DISPLAY - Linha de estatística para Step 4 (layout de dossiê)
// =============================================================================

class StatDisplay extends StatelessWidget {
  final String label;
  final String formula;
  final String value;

  const StatDisplay({
    super.key,
    required this.label,
    required this.formula,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Coluna esquerda (label + fórmula)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label em Branco-Osso
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: Color(0xFFe0e0e0),
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),

                // Fórmula em cinza-claro
                Text(
                  formula,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF888888),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Valor em selo hexagonal vermelho
          _buildHexagonalBadge(value),
        ],
      ),
    );
  }

  Widget _buildHexagonalBadge(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.scarletRed,
        boxShadow: [
          BoxShadow(
            color: AppColors.scarletRed.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
