import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/utils/dice_sprite_mapper.dart';
import '../models/dice_pool.dart';

/// Widget que renderiza um dado específico da sprite sheet
class DiceSpriteWidget extends StatefulWidget {
  final DiceType diceType;
  final int? faceValue; // Se null, mostra o dado tipo (header), se não, mostra a face específica
  final double size;
  final Color? color; // Cor para aplicar filtro (opcional)

  const DiceSpriteWidget({
    Key? key,
    required this.diceType,
    this.faceValue,
    required this.size,
    this.color,
  }) : super(key: key);

  @override
  State<DiceSpriteWidget> createState() => _DiceSpriteWidgetState();
}

class _DiceSpriteWidgetState extends State<DiceSpriteWidget> {
  ui.Image? _spriteSheet;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSpriteSheet();
  }

  Future<void> _loadSpriteSheet() async {
    try {
      final ByteData data = await rootBundle.load('assets/images/dice/dices.jpg');
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();

      if (mounted) {
        setState(() {
          _spriteSheet = frameInfo.image;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading sprite sheet: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _spriteSheet?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _spriteSheet == null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _DiceSpritePainter(
        spriteSheet: _spriteSheet!,
        diceType: widget.diceType,
        faceValue: widget.faceValue,
        color: widget.color,
      ),
    );
  }
}

/// CustomPainter que desenha o sprite do dado
class _DiceSpritePainter extends CustomPainter {
  final ui.Image spriteSheet;
  final DiceType diceType;
  final int? faceValue;
  final Color? color;

  _DiceSpritePainter({
    required this.spriteSheet,
    required this.diceType,
    this.faceValue,
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Determina qual parte da sprite sheet usar
    final Rect sourceRect = faceValue == null
        ? DiceSpriteMapper.getDiceTypeRect(diceType)
        : DiceSpriteMapper.getDiceFaceRect(diceType, faceValue!);

    // Área de destino (onde desenhar no canvas)
    final Rect destRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Paint para desenhar a imagem
    final Paint paint = Paint()
      ..filterQuality = FilterQuality.high;

    // NOTA: Filtro de cor removido temporariamente para manter os detalhes da sprite sheet
    // A sprite sheet é preto/branco, então os dados aparecem em preto
    // TODO: Implementar colorização que preserve os detalhes (requer shader customizado)

    // Desenha o pedaço da sprite sheet
    canvas.drawImageRect(
      spriteSheet,
      sourceRect,
      destRect,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _DiceSpritePainter oldDelegate) {
    return oldDelegate.spriteSheet != spriteSheet ||
        oldDelegate.diceType != diceType ||
        oldDelegate.faceValue != faceValue ||
        oldDelegate.color != color;
  }
}
