import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:drawing_board/drawing/document_model.dart';
import 'package:flutter/material.dart';

class DocumentPainter extends CustomPainter {
  DocumentPainter(
    this.doc, {
    required this.revision,
    this.draftFreehand,
    this.draftLine,
    this.draftRect,
    this.draftEllipse,
    this.rasterUi = const {},
    this.previewColor = 0xFFEC4899,
    this.previewWidth = 3,
    this.showReferenceDim = false,
    this.referenceImage,
    this.paintReference = true,
  });

  final DrawingDocument doc;
  final int revision;
  final FreehandStroke? draftFreehand;
  final LineStroke? draftLine;
  final RectStroke? draftRect;
  final EllipseStroke? draftEllipse;
  final Map<String, ui.Image> rasterUi;
  final int previewColor;
  final double previewWidth;
  final bool showReferenceDim;
  final ui.Image? referenceImage;
  final bool paintReference;

  @override
  void paint(Canvas canvas, Size size) {
    final paper = Rect.fromLTWH(0, 0, doc.canvasWidth, doc.canvasHeight);
    canvas.drawRect(paper, Paint()..color = Color(doc.backgroundColor));

    if (paintReference && referenceImage != null) {
      _paintReferenceUnderlay(canvas, paper, referenceImage!);
    }

    for (var li = 0; li < doc.layers.length; li++) {
      final layer = doc.layers[li];
      if (!layer.visible || layer.opacity <= 0) {
        continue;
      }
      final layerBlend = blendModeFromIndex(layer.blendModeIndex);
      canvas.saveLayer(
        paper,
        Paint()..blendMode = layerBlend,
      );
      for (var si = 0; si < layer.strokes.length; si++) {
        final s = layer.strokes[si];
        final key = '$li-$si';
        if (s is RasterStroke) {
          final img = rasterUi[key];
          if (img != null) {
            paintImage(
              canvas: canvas,
              rect: s.dst,
              image: img,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.medium,
            );
          }
        } else {
          _drawStroke(canvas, paper, s, layer.opacity);
        }
      }
      canvas.restore();
    }

    if (draftFreehand != null) {
      if (draftFreehand!.points.length == 1) {
        final o = draftFreehand!.points.first;
        canvas.drawCircle(
          o,
          previewWidth / 2,
          Paint()..color = Color(previewColor),
        );
      } else if (draftFreehand!.points.length >= 2) {
        _drawFreehand(
          canvas,
          paper,
          draftFreehand!,
          1,
          previewColor,
          previewWidth,
        );
      }
    }
    if (draftLine != null) {
      _drawLine(
        canvas,
        draftLine!.a,
        draftLine!.b,
        previewColor,
        previewWidth,
        1,
      );
    }
    if (draftRect != null) {
      _drawRectLike(
        canvas,
        draftRect!.rect,
        previewColor,
        previewWidth,
        1,
        draftRect!.filled,
      );
    }
    if (draftEllipse != null) {
      _drawEllipseLike(
        canvas,
        draftEllipse!.rect,
        previewColor,
        previewWidth,
        1,
        draftEllipse!.filled,
      );
    }

    if (showReferenceDim) {
      canvas.drawRect(
        paper,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.08)
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _paintReferenceUnderlay(Canvas canvas, Rect bounds, ui.Image img) {
    final src = Rect.fromLTWH(
      0,
      0,
      img.width.toDouble(),
      img.height.toDouble(),
    );
    final sw = src.width;
    final sh = src.height;
    final bw = bounds.width;
    final bh = bounds.height;
    late double scale;
    if (doc.referenceFitContain) {
      scale = math.min(bw / sw, bh / sh);
    } else {
      scale = math.max(bw / sw, bh / sh);
    }
    final dw = sw * scale;
    final dh = sh * scale;
    final dst = Rect.fromLTWH(
      bounds.left + (bw - dw) / 2,
      bounds.top + (bh - dh) / 2,
      dw,
      dh,
    );
    final a = doc.referenceImageOpacity.clamp(0.0, 1.0);
    if (a <= 0) {
      return;
    }
    canvas.saveLayer(
      bounds,
      Paint()..color = Color.fromRGBO(255, 255, 255, a),
    );
    canvas.drawImageRect(
      img,
      src,
      dst,
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.restore();
  }

  void _drawStroke(Canvas canvas, Rect bounds, Stroke s, double layerOpacity) {
    switch (s) {
      case FreehandStroke fs:
        _drawFreehand(canvas, bounds, fs, layerOpacity, fs.color, fs.width);
      case LineStroke ls:
        _drawLine(canvas, ls.a, ls.b, ls.color, ls.width, layerOpacity);
      case RectStroke rs:
        _drawRectLike(
          canvas,
          rs.rect,
          rs.color,
          rs.width,
          layerOpacity,
          rs.filled,
        );
      case EllipseStroke es:
        _drawEllipseLike(
          canvas,
          es.rect,
          es.color,
          es.width,
          layerOpacity,
          es.filled,
        );
      case RasterStroke():
        break;
    }
  }

  void _drawFreehand(
    Canvas canvas,
    Rect bounds,
    FreehandStroke s,
    double layerOpacity,
    int color,
    double width,
  ) {
    if (s.points.length < 2) {
      if (s.points.isEmpty) {
        return;
      }
      final p = Paint()
        ..color = _applyLayerAlpha(Color(color), layerOpacity)
        ..strokeWidth = width
        ..style = PaintingStyle.fill;
      canvas.drawCircle(s.points.first, width / 2, p);
      return;
    }
    final path = Path()..moveTo(s.points.first.dx, s.points.first.dy);
    for (var i = 1; i < s.points.length; i++) {
      path.lineTo(s.points[i].dx, s.points[i].dy);
    }
    if (s.eraser) {
      canvas.saveLayer(bounds, Paint());
      final er = Paint()
        ..blendMode = BlendMode.clear
        ..strokeWidth = width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, er);
      canvas.restore();
    } else {
      final paint = Paint()
        ..color = _applyLayerAlpha(Color(color), layerOpacity)
        ..strokeWidth = width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, paint);
    }
  }

  void _drawLine(
    Canvas canvas,
    Offset a,
    Offset b,
    int color,
    double width,
    double layerOpacity,
  ) {
    final paint = Paint()
      ..color = _applyLayerAlpha(Color(color), layerOpacity)
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(a, b, paint);
  }

  void _drawRectLike(
    Canvas canvas,
    Rect r,
    int color,
    double width,
    double layerOpacity,
    bool filled,
  ) {
    final c = _applyLayerAlpha(Color(color), layerOpacity);
    if (filled) {
      canvas.drawRect(r, Paint()..color = c);
    } else {
      final p = Paint()
        ..color = c
        ..strokeWidth = width
        ..style = PaintingStyle.stroke;
      canvas.drawRect(r, p);
    }
  }

  void _drawEllipseLike(
    Canvas canvas,
    Rect r,
    int color,
    double width,
    double layerOpacity,
    bool filled,
  ) {
    final c = _applyLayerAlpha(Color(color), layerOpacity);
    if (filled) {
      canvas.drawOval(r, Paint()..color = c);
    } else {
      final p = Paint()
        ..color = c
        ..strokeWidth = width
        ..style = PaintingStyle.stroke;
      canvas.drawOval(r, p);
    }
  }

  Color _applyLayerAlpha(Color c, double layerOpacity) {
    return c.withValues(
      alpha: c.a * layerOpacity.clamp(0.0, 1.0),
    );
  }

  @override
  bool shouldRepaint(covariant DocumentPainter oldDelegate) {
    return oldDelegate.revision != revision ||
        oldDelegate.draftFreehand != draftFreehand ||
        oldDelegate.draftLine != draftLine ||
        oldDelegate.draftRect != draftRect ||
        oldDelegate.draftEllipse != draftEllipse ||
        oldDelegate.rasterUi != rasterUi ||
        oldDelegate.showReferenceDim != showReferenceDim ||
        oldDelegate.referenceImage != referenceImage ||
        oldDelegate.paintReference != paintReference;
  }
}
