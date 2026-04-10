import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

enum DrawTool { pen, eraser, line, rect, ellipse, bucket, importRef }

class DrawingLayer {
  DrawingLayer({
    required this.id,
    required this.name,
    this.visible = true,
    this.opacity = 1,
    this.blendModeIndex = 0,
    List<Stroke>? strokes,
  }) : strokes = strokes ?? [];

  String id;
  String name;
  bool visible;
  double opacity;
  int blendModeIndex;
  List<Stroke> strokes;

  DrawingLayer clone() {
    return DrawingLayer(
      id: id,
      name: name,
      visible: visible,
      opacity: opacity,
      blendModeIndex: blendModeIndex,
      strokes: strokes.map((s) => s.clone()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'v': visible,
        'o': opacity,
        'b': blendModeIndex,
        's': strokes.map((e) => e.toJson()).toList(),
      };

  static DrawingLayer fromJson(Map<String, dynamic> j) {
    return DrawingLayer(
      id: j['id']! as String,
      name: j['name']! as String,
      visible: j['v']! as bool,
      opacity: (j['o'] as num).toDouble(),
      blendModeIndex: j['b']! as int,
      strokes: (j['s'] as List<dynamic>)
          .map((e) => Stroke.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DrawingDocument {
  DrawingDocument({
    required this.canvasWidth,
    required this.canvasHeight,
    this.backgroundColor = 0xFFFFFFFF,
    this.activeLayerIndex = 0,
    List<DrawingLayer>? layers,
    this.referenceImageOpacity = 0.35,
    this.referenceFitContain = true,
  }) : layers = layers ?? _defaultLayers();

  double canvasWidth;
  double canvasHeight;
  int backgroundColor;
  int activeLayerIndex;
  List<DrawingLayer> layers;
  double referenceImageOpacity;
  bool referenceFitContain;
  String? referenceImagePath;

  static List<DrawingLayer> _defaultLayers() {
    return [
      DrawingLayer(
        id: 'layer_1',
        name: 'Layer 1',
        blendModeIndex: 0,
      ),
    ];
  }

  DrawingDocument cloneDeep() {
    return DrawingDocument(
      canvasWidth: canvasWidth,
      canvasHeight: canvasHeight,
      backgroundColor: backgroundColor,
      activeLayerIndex: activeLayerIndex,
      layers: layers.map((e) => e.clone()).toList(),
      referenceImageOpacity: referenceImageOpacity,
      referenceFitContain: referenceFitContain,
    )..referenceImagePath = referenceImagePath;
  }

  Map<String, dynamic> toJson() => {
        'w': canvasWidth,
        'h': canvasHeight,
        'bg': backgroundColor,
        'i': activeLayerIndex,
        'ref_op': referenceImageOpacity,
        'ref_fit': referenceFitContain,
        'ref_path': referenceImagePath,
        'layers': layers.map((e) => e.toJson()).toList(),
      };

  static DrawingDocument fromJson(Map<String, dynamic> j) {
    final doc = DrawingDocument(
      canvasWidth: (j['w'] as num).toDouble(),
      canvasHeight: (j['h'] as num).toDouble(),
      backgroundColor: j['bg'] as int? ?? 0xFFFFFFFF,
      activeLayerIndex: j['i'] as int? ?? 0,
      layers: (j['layers'] as List<dynamic>?)
              ?.map((e) => DrawingLayer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          _defaultLayers(),
      referenceImageOpacity: (j['ref_op'] as num?)?.toDouble() ?? 0.35,
      referenceFitContain: j['ref_fit'] as bool? ?? true,
    );
    doc.referenceImagePath = j['ref_path'] as String?;
    return doc;
  }
}

sealed class Stroke {
  Stroke clone();
  Map<String, dynamic> toJson();

  static Stroke fromJson(Map<String, dynamic> j) {
    final t = j['t'] as String;
    switch (t) {
      case 'free':
        return FreehandStroke.fromJson(j);
      case 'line':
        return LineStroke.fromJson(j);
      case 'rect':
        return RectStroke.fromJson(j);
      case 'ellipse':
        return EllipseStroke.fromJson(j);
      case 'raster':
        return RasterStroke.fromJson(j);
      default:
        return FreehandStroke(
          color: 0xFF000000,
          width: 2,
          eraser: false,
          points: const [],
        );
    }
  }
}

class FreehandStroke extends Stroke {
  FreehandStroke({
    required this.color,
    required this.width,
    required this.eraser,
    required this.points,
  });

  int color;
  double width;
  bool eraser;
  List<Offset> points;

  @override
  FreehandStroke clone() {
    return FreehandStroke(
      color: color,
      width: width,
      eraser: eraser,
      points: List.from(points),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        't': 'free',
        'c': color,
        'w': width,
        'e': eraser,
        'p': points.map((o) => [o.dx, o.dy]).toList(),
      };

  static FreehandStroke fromJson(Map<String, dynamic> j) {
    final raw = j['p'] as List<dynamic>;
    return FreehandStroke(
      color: j['c']! as int,
      width: (j['w'] as num).toDouble(),
      eraser: j['e']! as bool,
      points: raw.map((e) {
        final p = e as List<dynamic>;
        return Offset(
          (p[0] as num).toDouble(),
          (p[1] as num).toDouble(),
        );
      }).toList(),
    );
  }
}

class LineStroke extends Stroke {
  LineStroke({
    required this.color,
    required this.width,
    required this.a,
    required this.b,
  });

  int color;
  double width;
  Offset a;
  Offset b;

  @override
  LineStroke clone() {
    return LineStroke(color: color, width: width, a: a, b: b);
  }

  @override
  Map<String, dynamic> toJson() => {
        't': 'line',
        'c': color,
        'w': width,
        'a': [a.dx, a.dy],
        'b': [b.dx, b.dy],
      };

  static LineStroke fromJson(Map<String, dynamic> j) {
    final ai = j['a'] as List<dynamic>;
    final bi = j['b'] as List<dynamic>;
    return LineStroke(
      color: j['c']! as int,
      width: (j['w'] as num).toDouble(),
      a: Offset((ai[0] as num).toDouble(), (ai[1] as num).toDouble()),
      b: Offset((bi[0] as num).toDouble(), (bi[1] as num).toDouble()),
    );
  }
}

class RectStroke extends Stroke {
  RectStroke({
    required this.color,
    required this.width,
    required this.rect,
    required this.filled,
  });

  int color;
  double width;
  Rect rect;
  bool filled;

  @override
  RectStroke clone() {
    return RectStroke(
      color: color,
      width: width,
      rect: rect,
      filled: filled,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        't': 'rect',
        'c': color,
        'w': width,
        'r': [rect.left, rect.top, rect.width, rect.height],
        'f': filled,
      };

  static RectStroke fromJson(Map<String, dynamic> j) {
    final r = j['r'] as List<dynamic>;
    return RectStroke(
      color: j['c']! as int,
      width: (j['w'] as num).toDouble(),
      rect: Rect.fromLTWH(
        (r[0] as num).toDouble(),
        (r[1] as num).toDouble(),
        (r[2] as num).toDouble(),
        (r[3] as num).toDouble(),
      ),
      filled: j['f']! as bool,
    );
  }
}

class EllipseStroke extends Stroke {
  EllipseStroke({
    required this.color,
    required this.width,
    required this.rect,
    required this.filled,
  });

  int color;
  double width;
  Rect rect;
  bool filled;

  @override
  EllipseStroke clone() {
    return EllipseStroke(
      color: color,
      width: width,
      rect: rect,
      filled: filled,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        't': 'ellipse',
        'c': color,
        'w': width,
        'r': [rect.left, rect.top, rect.width, rect.height],
        'f': filled,
      };

  static EllipseStroke fromJson(Map<String, dynamic> j) {
    final r = j['r'] as List<dynamic>;
    return EllipseStroke(
      color: j['c']! as int,
      width: (j['w'] as num).toDouble(),
      rect: Rect.fromLTWH(
        (r[0] as num).toDouble(),
        (r[1] as num).toDouble(),
        (r[2] as num).toDouble(),
        (r[3] as num).toDouble(),
      ),
      filled: j['f']! as bool,
    );
  }
}

class RasterStroke extends Stroke {
  RasterStroke({
    required this.pngBytes,
    required this.dst,
  });

  Uint8List pngBytes;
  Rect dst;

  @override
  RasterStroke clone() {
    return RasterStroke(pngBytes: Uint8List.fromList(pngBytes), dst: dst);
  }

  @override
  Map<String, dynamic> toJson() => {
        't': 'raster',
        'd': base64Encode(pngBytes),
        'r': [dst.left, dst.top, dst.width, dst.height],
      };

  static RasterStroke fromJson(Map<String, dynamic> j) {
    final r = j['r'] as List<dynamic>;
    return RasterStroke(
      pngBytes: Uint8List.fromList(base64Decode(j['d']! as String)),
      dst: Rect.fromLTWH(
        (r[0] as num).toDouble(),
        (r[1] as num).toDouble(),
        (r[2] as num).toDouble(),
        (r[3] as num).toDouble(),
      ),
    );
  }
}

BlendMode blendModeFromIndex(int i) {
  return switch (i) {
    1 => BlendMode.multiply,
    2 => BlendMode.screen,
    3 => BlendMode.colorBurn,
    4 => BlendMode.colorDodge,
    _ => BlendMode.srcOver,
  };
}
