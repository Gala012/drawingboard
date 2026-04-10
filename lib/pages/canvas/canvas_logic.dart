import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:drawing_board/app/settings_storage.dart';
import 'package:drawing_board/db_drawing_board/db_drawing_board_helper.dart';
import 'package:drawing_board/drawing/bucket_service.dart';
import 'package:drawing_board/drawing/document_model.dart';
import 'package:drawing_board/drawing/document_painter.dart';
import 'package:drawing_board/lang/lang.dart';
import 'package:drawing_board/pages/canvas/canvas_tool_sheet.dart';
import 'package:drawing_board/pages/home/home_logic.dart';
import 'package:drawing_board/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CanvasLogic extends GetxController {
  CanvasLogic({this.projectId});

  final int? projectId;

  final repaint = ValueNotifier<int>(0);
  final doc = DrawingDocument(canvasWidth: 800, canvasHeight: 1200).obs;
  final Map<String, ui.Image> rasterUi = <String, ui.Image>{};
  final revision = 0.obs;

  final tool = DrawTool.pen.obs;
  final brushColor = 0xFFEC4899.obs;
  final brushWidth = 4.0.obs;
  final shapeFilled = false.obs;

  TransformationController? _transform;

  FreehandStroke? _draftFree;
  Offset? _shapeA;
  Offset? _shapeB;

  final undoStack = <DrawingDocument>[].obs;
  final redoStack = <DrawingDocument>[].obs;

  final recentColors = <int>[0xFFEC4899, 0xFF06B6D4, 0xFFFFFFFF, 0xFF18181B].obs;

  final bucketBusy = false.obs;

  final canvasHeaderTitle = Lang.defaultProjectTitle.obs;

  GlobalKey painterKey = GlobalKey();
  int? _persistedId;
  String? _referencePathLoaded;
  ui.Image? _referenceImage;
  bool _canvasHydrated = false;
  bool _referenceViewportFitApplied = false;
  Size? _lastReferenceViewport;

  ui.Image? get referenceImageForPaint => _referenceImage;

  FreehandStroke? get draftFreehand => _draftFree;

  void attachTransform(TransformationController c) {
    _transform = c;
  }

  void detachTransform() {
    _transform = null;
  }

  @override
  void onInit() {
    super.onInit();
    _loadOrCreate();
  }

  Future<void> _loadOrCreate() async {
    _canvasHydrated = false;
    _referenceViewportFitApplied = false;
    if (projectId != null) {
      final row = await DbDrawingBoardHelper.instance.getProject(projectId!);
      if (row != null) {
        _persistedId = row.id;
        doc.value = row.parseDoc();
        canvasHeaderTitle.value =
            row.title.trim().isEmpty ? Lang.defaultProjectTitle : row.title;
        await _decodeRasters();
        await _syncReferenceImage();
        revision.value++;
        repaint.value++;
        _canvasHydrated = true;
        return;
      }
    }
    final fresh = DrawingDocument(canvasWidth: 800, canvasHeight: 1200);
    if (SettingsStorage.paperDark()) {
      fresh.backgroundColor = 0xFF121214;
    }
    doc.value = fresh;
    canvasHeaderTitle.value = Lang.defaultProjectTitle;
    _persistedId = null;
    await _syncReferenceImage();
    revision.value++;
    repaint.value++;
    _canvasHydrated = true;
  }

  void fitCanvasToViewportIfNeeded(Size viewport) {
    if (!_canvasHydrated) {
      return;
    }
    final path = doc.value.referenceImagePath;
    if (path == null || path.isEmpty) {
      return;
    }
    if (viewport.width < 32 || viewport.height < 32) {
      return;
    }
    _lastReferenceViewport = viewport;
    if (_referenceViewportFitApplied) {
      return;
    }
    final cw = doc.value.canvasWidth;
    final ch = doc.value.canvasHeight;
    if (cw < 1 || ch < 1) {
      return;
    }
    final t = _transform;
    if (t == null) {
      return;
    }
    _referenceViewportFitApplied = true;
    final s0 = math.min(viewport.width / cw, viewport.height / ch);
    final s = s0 * 0.92;
    if (s0 >= 1.0) {
      t.value = Matrix4.identity();
      return;
    }
    final center = Matrix4.translationValues(
      viewport.width / 2,
      viewport.height / 2,
      0,
    );
    final scaleM = Matrix4.diagonal3Values(s, s, 1);
    final origin = Matrix4.translationValues(-cw / 2, -ch / 2, 0);
    t.value = center * scaleM * origin;
  }

  Future<void> _syncReferenceImage() async {
    final path = doc.value.referenceImagePath;
    if (path == _referencePathLoaded &&
        (path == null || _referenceImage != null)) {
      return;
    }
    _referencePathLoaded = path;
    _referenceImage?.dispose();
    _referenceImage = null;
    if (path == null || path.isEmpty) {
      return;
    }
    try {
      final bd = await rootBundle.load(path);
      final codec =
          await ui.instantiateImageCodec(bd.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _referenceImage = frame.image;
    } catch (_) {
      _referenceImage = null;
    }
  }

  Future<void> _decodeRasters() async {
    final images = <String, ui.Image>{};
    for (var li = 0; li < doc.value.layers.length; li++) {
      final layer = doc.value.layers[li];
      for (var si = 0; si < layer.strokes.length; si++) {
        final s = layer.strokes[si];
        if (s is RasterStroke) {
          final codec = await ui.instantiateImageCodec(s.pngBytes);
          final frame = await codec.getNextFrame();
          images['$li-$si'] = frame.image;
        }
      }
    }
    for (final old in rasterUi.values) {
      old.dispose();
    }
    rasterUi
      ..clear()
      ..addAll(images);
  }

  void bumpRevision() {
    revision.value++;
    repaint.value++;
  }

  void pushUndo() {
    undoStack.add(doc.value.cloneDeep());
    if (undoStack.length > 40) {
      undoStack.removeAt(0);
    }
    redoStack.clear();
  }

  void undo() {
    if (undoStack.isEmpty) {
      return;
    }
    redoStack.add(doc.value.cloneDeep());
    doc.value = undoStack.removeLast();
    unawaited(_reloadDecodedImages());
    bumpRevision();
  }

  void redo() {
    if (redoStack.isEmpty) {
      return;
    }
    undoStack.add(doc.value.cloneDeep());
    doc.value = redoStack.removeLast();
    unawaited(_reloadDecodedImages());
    bumpRevision();
  }

  Future<void> _reloadDecodedImages() async {
    await _decodeRasters();
    await _syncReferenceImage();
    bumpRevision();
  }

  void startStroke(Offset canvasPoint) {
    pushUndo();
    final color = tool.value == DrawTool.eraser ? 0xFFFFFFFF : brushColor.value;
    final w = brushWidth.value;
    switch (tool.value) {
      case DrawTool.pen:
      case DrawTool.eraser:
        _draftFree = FreehandStroke(
          color: color,
          width: w,
          eraser: tool.value == DrawTool.eraser,
          points: [_smooth(canvasPoint)],
        );
        break;
      case DrawTool.line:
      case DrawTool.rect:
      case DrawTool.ellipse:
      case DrawTool.bucket:
        _shapeA = canvasPoint;
        _shapeB = canvasPoint;
      case DrawTool.importRef:
        break;
    }
    bumpRevision();
  }

  void appendPoint(Offset canvasPoint) {
    switch (tool.value) {
      case DrawTool.pen:
      case DrawTool.eraser:
        if (_draftFree == null) {
          return;
        }
        _draftFree!.points.add(_smooth(canvasPoint));
        break;
      case DrawTool.line:
      case DrawTool.rect:
      case DrawTool.ellipse:
        _shapeB = canvasPoint;
      case DrawTool.bucket:
      case DrawTool.importRef:
        break;
    }
    bumpRevision();
  }

  Offset _smooth(Offset o) {
    if (!SettingsStorage.stabilizerOn()) {
      return o;
    }
    if (_draftFree == null || _draftFree!.points.isEmpty) {
      return o;
    }
    final n = SettingsStorage.stabilizerWindow();
    final pts = _draftFree!.points;
    final start = pts.length >= n ? pts.length - n : 0;
    var sx = 0.0;
    var sy = 0.0;
    var c = 0;
    for (var i = start; i < pts.length; i++) {
      sx += pts[i].dx;
      sy += pts[i].dy;
      c++;
    }
    sx += o.dx;
    sy += o.dy;
    c++;
    return Offset(sx / c, sy / c);
  }

  Future<void> endStroke(Offset canvasPoint) async {
    final d = doc.value;
    final li = d.activeLayerIndex.clamp(0, d.layers.length - 1);
    switch (tool.value) {
      case DrawTool.pen:
      case DrawTool.eraser:
        if (_draftFree != null && _draftFree!.points.length >= 2) {
          d.layers[li].strokes.add(_draftFree!.clone());
          await _afterStrokeCommit(1);
        }
        _draftFree = null;
        break;
      case DrawTool.line:
        if (_shapeA != null && _shapeB != null) {
          d.layers[li].strokes.add(LineStroke(
            color: brushColor.value,
            width: brushWidth.value,
            a: _shapeA!,
            b: _shapeB!,
          ));
          await _afterStrokeCommit(1);
        }
        _shapeA = null;
        _shapeB = null;
        break;
      case DrawTool.rect:
        if (_shapeA != null && _shapeB != null) {
          final r = Rect.fromPoints(_shapeA!, _shapeB!);
          d.layers[li].strokes.add(RectStroke(
            color: brushColor.value,
            width: brushWidth.value,
            rect: r,
            filled: shapeFilled.value,
          ));
          await _afterStrokeCommit(1);
        }
        _shapeA = null;
        _shapeB = null;
        break;
      case DrawTool.ellipse:
        if (_shapeA != null && _shapeB != null) {
          final r = Rect.fromPoints(_shapeA!, _shapeB!);
          d.layers[li].strokes.add(EllipseStroke(
            color: brushColor.value,
            width: brushWidth.value,
            rect: r,
            filled: shapeFilled.value,
          ));
          await _afterStrokeCommit(1);
        }
        _shapeA = null;
        _shapeB = null;
        break;
      case DrawTool.bucket:
        if (_shapeA != null) {
          bucketBusy.value = true;
          final rs = await BucketService.fillAt(
            doc: d,
            rasterUi: rasterUi,
            revision: revision.value,
            canvasPoint: _shapeA!,
            fillArgb: brushColor.value,
            tolerance: SettingsStorage.bucketTolerance(),
          );
          bucketBusy.value = false;
          if (rs != null) {
            d.layers[li].strokes.add(rs);
            await _decodeRasters();
            await _afterStrokeCommit(1);
          }
        }
        _shapeA = null;
        _shapeB = null;
        break;
      case DrawTool.importRef:
        break;
    }
    doc.refresh();
    bumpRevision();
    scheduleSave();
  }

  void cancelStrokeAndUndoPush() {
    if (undoStack.isNotEmpty) {
      undoStack.removeLast();
    }
    cancelStroke();
  }

  Future<void> _afterStrokeCommit(int strokes) async {
    _pushRecent(brushColor.value);
    await DbDrawingBoardHelper.instance.addStrokeCountForToday(strokes);
  }

  void _pushRecent(int c) {
    recentColors.remove(c);
    recentColors.insert(0, c);
    if (recentColors.length > 6) {
      recentColors.removeRange(6, recentColors.length);
    }
  }

  void cancelStroke() {
    _draftFree = null;
    _shapeA = null;
    _shapeB = null;
    bumpRevision();
  }

  Timer? _saveDebounce;

  void scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 900), () {
      unawaited(persist());
    });
  }

  Future<void> saveNow() async {
    _saveDebounce?.cancel();
    await persist();
    Get.snackbar(Lang.appName, Lang.msgSaved);
  }

  Future<void> persist() async {
    final d = doc.value;
    var id = _persistedId ?? projectId;
    final title = canvasHeaderTitle.value.trim().isEmpty
        ? Lang.defaultProjectTitle
        : canvasHeaderTitle.value;
    if (id == null) {
      id = await DbDrawingBoardHelper.instance.insertProject(
        title: title,
        doc: d,
      );
      _persistedId = id;
    } else {
      await DbDrawingBoardHelper.instance.updateProject(id: id, doc: d);
    }
    final thumb = await _renderThumb();
    if (thumb != null) {
      await DbDrawingBoardHelper.instance.updateProject(
        id: id,
        thumbPath: thumb,
      );
    }
    _refreshHome();
  }

  Future<String?> _renderThumb() async {
    try {
      final ctx = painterKey.currentContext;
      if (ctx == null) {
        return null;
      }
      final box = ctx.findRenderObject() as RenderRepaintBoundary?;
      if (box == null || !box.isRepaintBoundary) {
        return null;
      }
      final img = await box.toImage(pixelRatio: 0.35);
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      if (bd == null) {
        return null;
      }
      final dir = await getApplicationDocumentsDirectory();
      final name = 'thumb_${_persistedId ?? DateTime.now().millisecondsSinceEpoch}.png';
      final f = File('${dir.path}/$name');
      await f.writeAsBytes(bd.buffer.asUint8List(), flush: true);
      return f.path;
    } catch (_) {
      return null;
    }
  }

  void _refreshHome() {
    if (Get.isRegistered<HomeLogic>()) {
      unawaited(Get.find<HomeLogic>().refreshHome());
    }
  }

  LineStroke? get draftLine =>
      _shapeA != null && _shapeB != null && tool.value == DrawTool.line
          ? LineStroke(
              color: brushColor.value,
              width: brushWidth.value,
              a: _shapeA!,
              b: _shapeB!,
            )
          : null;

  RectStroke? get draftRect =>
      _shapeA != null && _shapeB != null && tool.value == DrawTool.rect
          ? RectStroke(
              color: brushColor.value,
              width: brushWidth.value,
              rect: Rect.fromPoints(_shapeA!, _shapeB!),
              filled: shapeFilled.value,
            )
          : null;

  EllipseStroke? get draftEllipse =>
      _shapeA != null && _shapeB != null && tool.value == DrawTool.ellipse
          ? EllipseStroke(
              color: brushColor.value,
              width: brushWidth.value,
              rect: Rect.fromPoints(_shapeA!, _shapeB!),
              filled: shapeFilled.value,
            )
          : null;

  void setTool(DrawTool t) => tool.value = t;

  void setColor(int argb) {
    brushColor.value = argb;
    tool.value = DrawTool.pen;
  }

  void addLayer() {
    pushUndo();
    final d = doc.value;
    d.layers.add(DrawingLayer(
      id: 'layer_${DateTime.now().microsecondsSinceEpoch}',
      name: 'Layer ${d.layers.length + 1}',
    ));
    d.activeLayerIndex = d.layers.length - 1;
    doc.refresh();
    bumpRevision();
    scheduleSave();
  }

  void setActiveLayer(int i) {
    doc.update((d) {
      d!.activeLayerIndex = i.clamp(0, d.layers.length - 1);
    });
    bumpRevision();
  }

  void setReferenceOpacity(double v) {
    doc.update((d) {
      d!.referenceImageOpacity = v.clamp(0.0, 1.0);
    });
    bumpRevision();
    scheduleSave();
  }

  void setReferenceFitContain(bool v) {
    doc.update((d) {
      d!.referenceFitContain = v;
    });
    bumpRevision();
    scheduleSave();
  }

  void toggleLayerVisible(int i) {
    pushUndo();
    final d = doc.value;
    if (i >= 0 && i < d.layers.length) {
      d.layers[i].visible = !d.layers[i].visible;
    }
    doc.refresh();
    bumpRevision();
    scheduleSave();
  }

  void setLayerOpacity(int i, double o) {
    final d = doc.value;
    if (i >= 0 && i < d.layers.length) {
      d.layers[i].opacity = o.clamp(0.0, 1.0);
    }
    doc.refresh();
    bumpRevision();
  }

  void setLayerBlend(int i, int mode) {
    final d = doc.value;
    if (i >= 0 && i < d.layers.length) {
      d.layers[i].blendModeIndex = mode.clamp(0, 4);
    }
    doc.refresh();
    bumpRevision();
    scheduleSave();
  }

  void resetView() {
    final t = _transform;
    if (t == null) {
      return;
    }
    final path = doc.value.referenceImagePath;
    final vp = _lastReferenceViewport;
    if (path != null &&
        path.isNotEmpty &&
        vp != null &&
        vp.width >= 32 &&
        vp.height >= 32) {
      _referenceViewportFitApplied = false;
      fitCanvasToViewportIfNeeded(vp);
      return;
    }
    t.value = Matrix4.identity();
  }

  Future<void> sharePng() async {
    final d = doc.value;
    final recorder = ui.PictureRecorder();
    final c = ui.Canvas(
      recorder,
      Rect.fromLTWH(0, 0, d.canvasWidth, d.canvasHeight),
    );
    DocumentPainter(
      d,
      revision: revision.value,
      rasterUi: rasterUi,
      paintReference: false,
    ).paint(c, Size(d.canvasWidth, d.canvasHeight));
    final pic = recorder.endRecording();
    final img0 = await pic.toImage(
      d.canvasWidth.round(),
      d.canvasHeight.round(),
    );
    final bd = await img0.toByteData(format: ui.ImageByteFormat.png);
    if (bd == null) {
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    final f = File(
      '${dir.path}/export_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await f.writeAsBytes(bd.buffer.asUint8List(), flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(f.path)],
        text: Lang.appName,
      ),
    );
  }

  Future<void> applyCanvasTitle(String raw) async {
    final t = raw.trim();
    final next = t.isEmpty ? Lang.defaultProjectTitle : t;
    canvasHeaderTitle.value = next;
    final id = _persistedId ?? projectId;
    if (id != null) {
      await DbDrawingBoardHelper.instance.updateProject(id: id, title: next);
    }
    _refreshHome();
  }

  void openRenameTitleSheet(BuildContext context) {
    final tc = TextEditingController(text: canvasHeaderTitle.value);
    final focus = FocusNode();
    final cs = Theme.of(context).colorScheme;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focus.requestFocus();
    });

    unawaited(
      Get.bottomSheet<void>(
        Builder(
          builder: (modalCtx) {
            return AnimatedPadding(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(modalCtx).bottom,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(ScreenUtil().radius(24)),
                ),
                child: Material(
                  color: cs.surfaceContainerHighest,
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          ScreenUtil().setWidth(20),
                          ScreenUtil().setHeight(12),
                          ScreenUtil().setWidth(20),
                          ScreenUtil().setHeight(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                width: ScreenUtil().setWidth(40),
                                height: ScreenUtil().setHeight(4),
                                decoration: BoxDecoration(
                                  color: AppTheme.outlineDark,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            SizedBox(height: ScreenUtil().setHeight(16)),
                            Text(
                              Lang.canvasRenameSheetTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(18),
                                fontWeight: FontWeight.w700,
                                color: AppTheme.onSurfaceDark,
                              ),
                            ),
                            SizedBox(height: ScreenUtil().setHeight(12)),
                            TextField(
                              controller: tc,
                              focusNode: focus,
                              maxLength: 48,
                              maxLines: 1,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) async {
                                final v = tc.text;
                                Get.back<void>();
                                await applyCanvasTitle(v);
                              },
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(16),
                                color: AppTheme.onSurfaceDark,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: Lang.defaultProjectTitle,
                                filled: true,
                                fillColor: AppTheme.surfaceDark,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppTheme.outlineDark,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppTheme.outlineDark
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppTheme.primaryAccent,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: ScreenUtil().setHeight(20)),
                            FilledButton(
                              onPressed: () async {
                                final v = tc.text;
                                Get.back<void>();
                                await applyCanvasTitle(v);
                              },
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: ScreenUtil().setHeight(14),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                Lang.canvasRenameConfirm,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(16),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: ScreenUtil().setHeight(8)),
                            TextButton(
                              onPressed: () => Get.back<void>(),
                              child: Text(
                                Lang.canvasClose,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        enterBottomSheetDuration: const Duration(milliseconds: 260),
        exitBottomSheetDuration: const Duration(milliseconds: 220),
      ).whenComplete(() {
        tc.dispose();
        focus.dispose();
      }),
    );
  }

  void openToolSheet(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    Get.bottomSheet(
      ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ScreenUtil().radius(24)),
        ),
        child: Container(
          color: cs.surfaceContainerHighest,
          child: SafeArea(
            top: false,
            child: CanvasToolSheet(logic: this),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enterBottomSheetDuration: const Duration(milliseconds: 260),
      exitBottomSheetDuration: const Duration(milliseconds: 220),
    );
  }

  void back() {
    unawaited(persist());
    Get.back();
  }

  @override
  void onClose() {
    _saveDebounce?.cancel();
    detachTransform();
    for (final img in rasterUi.values) {
      img.dispose();
    }
    rasterUi.clear();
    _referenceImage?.dispose();
    _referenceImage = null;
    super.onClose();
  }
}
