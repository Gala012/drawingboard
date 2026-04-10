import 'dart:collection';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:drawing_board/drawing/document_model.dart';
import 'package:drawing_board/drawing/document_painter.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class BucketService {
  static Future<RasterStroke?> fillAt({
    required DrawingDocument doc,
    required Map<String, ui.Image> rasterUi,
    required int revision,
    required Offset canvasPoint,
    required int fillArgb,
    int tolerance = 18,
    int maxSide = 480,
  }) async {
    final w0 = doc.canvasWidth;
    final h0 = doc.canvasHeight;
    if (w0 <= 0 || h0 <= 0) {
      return null;
    }

    final scale = maxSide / math.max(w0, h0);
    final tw = math.max(16, (w0 * scale).round());
    final th = math.max(16, (h0 * scale).round());

    final recorder = ui.PictureRecorder();
    final c = ui.Canvas(recorder, Rect.fromLTWH(0, 0, w0, h0));
    DocumentPainter(
      doc,
      revision: revision,
      rasterUi: rasterUi,
      showReferenceDim: false,
    ).paint(c, Size(w0, h0));
    final pic = recorder.endRecording();
    final uiImg = await pic.toImage(tw, th);
    final bd = await uiImg.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
    if (bd == null) {
      return null;
    }
    final rgba = bd.buffer.asUint8List();
    final snap = Uint8List.fromList(rgba);

    final cx = (canvasPoint.dx / w0 * tw).round().clamp(0, tw - 1);
    final cy = (canvasPoint.dy / h0 * th).round().clamp(0, th - 1);
    final fill = Color(fillArgb);
    final fr = (fill.r * 255).round().clamp(0, 255);
    final fg = (fill.g * 255).round().clamp(0, 255);
    final fb = (fill.b * 255).round().clamp(0, 255);
    final fa = (fill.a * 255).round().clamp(0, 255);

    _floodFillRgba(
      rgba,
      tw,
      th,
      cx,
      cy,
      fr,
      fg,
      fb,
      fa,
      tolerance,
    );

    var minX = tw;
    var minY = th;
    var maxX = 0;
    var maxY = 0;
    var any = false;
    for (var y = 0; y < th; y++) {
      for (var x = 0; x < tw; x++) {
        final i = (y * tw + x) * 4;
        var diff = false;
        for (var k = 0; k < 4; k++) {
          if (rgba[i + k] != snap[i + k]) {
            diff = true;
            break;
          }
        }
        if (diff) {
          any = true;
          minX = math.min(minX, x);
          minY = math.min(minY, y);
          maxX = math.max(maxX, x);
          maxY = math.max(maxY, y);
        }
      }
    }
    if (!any) {
      return null;
    }

    final cw = maxX - minX + 1;
    final ch = maxY - minY + 1;
    final out = img.Image(width: cw, height: ch, numChannels: 4, format: img.Format.uint8);
    for (var y = 0; y < ch; y++) {
      for (var x = 0; x < cw; x++) {
        final sx = minX + x;
        final sy = minY + y;
        final i = (sy * tw + sx) * 4;
        out.setPixelRgba(x, y, rgba[i], rgba[i + 1], rgba[i + 2], rgba[i + 3]);
      }
    }
    final png = Uint8List.fromList(img.encodePng(out));
    final dst = Rect.fromLTWH(
      minX * w0 / tw,
      minY * h0 / th,
      cw * w0 / tw,
      ch * h0 / th,
    );
    return RasterStroke(pngBytes: png, dst: dst);
  }

  static void _floodFillRgba(
    Uint8List buf,
    int w,
    int h,
    int sx,
    int sy,
    int fr,
    int fg,
    int fb,
    int fa,
    int tolerance,
  ) {
    final si = (sy * w + sx) * 4;
    final tr = buf[si];
    final tg = buf[si + 1];
    final tb = buf[si + 2];
    final ta = buf[si + 3];
    final q = Queue<(int, int)>();
    final seen = List<bool>.filled(w * h, false);
    bool close(int i) {
      final r = buf[i];
      final g = buf[i + 1];
      final b = buf[i + 2];
      final a = buf[i + 3];
      return (r - tr).abs() <= tolerance &&
          (g - tg).abs() <= tolerance &&
          (b - tb).abs() <= tolerance &&
          (a - ta).abs() <= tolerance;
    }

    void push(int x, int y) {
      if (x < 0 || y < 0 || x >= w || y >= h) {
        return;
      }
      final id = y * w + x;
      if (seen[id]) {
        return;
      }
      final i = id * 4;
      if (!close(i)) {
        return;
      }
      seen[id] = true;
      q.add((x, y));
    }

    push(sx, sy);
    while (q.isNotEmpty) {
      final (x, y) = q.removeFirst();
      final i = (y * w + x) * 4;
      buf[i] = fr;
      buf[i + 1] = fg;
      buf[i + 2] = fb;
      buf[i + 3] = fa;
      push(x + 1, y);
      push(x - 1, y);
      push(x, y + 1);
      push(x, y - 1);
    }
  }
}
