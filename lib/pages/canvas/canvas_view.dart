import 'dart:async';

import 'package:drawing_board/drawing/document_model.dart';
import 'package:drawing_board/drawing/document_painter.dart';
import 'package:drawing_board/lang/lang.dart';
import 'package:drawing_board/pages/canvas/canvas_logic.dart';
import 'package:drawing_board/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CanvasView extends StatefulWidget {
  const CanvasView({super.key});

  @override
  State<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends State<CanvasView> {
  final Map<int, Offset> _ptr = {};
  late TransformationController _tc;
  CanvasLogic get logic => Get.find<CanvasLogic>();

  @override
  void initState() {
    super.initState();
    _tc = TransformationController();
    logic.attachTransform(_tc);
  }

  @override
  void dispose() {
    logic.detachTransform();
    _tc.dispose();
    super.dispose();
  }

  Offset? _toCanvas(Offset global) {
    final ctx = logic.painterKey.currentContext;
    if (ctx == null) {
      return null;
    }
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) {
      return null;
    }
    return box.globalToLocal(global);
  }

  void _onDown(PointerDownEvent e) {
    _ptr[e.pointer] = e.position;
    if (_ptr.length >= 2) {
      logic.cancelStrokeAndUndoPush();
      return;
    }
    final p = _toCanvas(e.position);
    if (p != null) {
      logic.startStroke(p);
    }
  }

  void _onMove(PointerMoveEvent e) {
    _ptr[e.pointer] = e.position;
    if (_ptr.length >= 2) {
      return;
    }
    final p = _toCanvas(e.position);
    if (p != null) {
      logic.appendPoint(p);
    }
  }

  void _onUp(PointerUpEvent e) {
    _ptr.remove(e.pointer);
    if (_ptr.length >= 2) {
      return;
    }
    final p = _toCanvas(e.position);
    if (p != null) {
      unawaited(logic.endStroke(p));
    }
    setState(() {});
  }

  void _onCancel(PointerCancelEvent e) {
    _ptr.remove(e.pointer);
    logic.cancelStroke();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppTheme.surfaceDark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.surfaceDark,
        systemNavigationBarDividerColor: AppTheme.surfaceDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: GetX<CanvasLogic>(
        builder: (c) {
          final rev = c.revision.value;
          final previewColor = c.brushColor.value;
          final previewW = c.brushWidth.value;
          final busy = c.bucketBusy.value;
          final activeTool = c.tool.value;
          return Scaffold(
            backgroundColor: AppTheme.surfaceDark,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SafeArea(
                  bottom: false,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.outlineDark.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(6),
                            vertical: ScreenUtil().setHeight(6),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _ChromeIconButton(
                                icon: Icons.close_rounded,
                                onPressed: c.back,
                                tooltip: Lang.canvasClose,
                                color: cs.onSurface,
                              ),
                              SizedBox(width: ScreenUtil().setWidth(4)),
                              Expanded(
                                child: Tooltip(
                                  message: Lang.canvasTitleEditHint,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () =>
                                          c.openRenameTitleSheet(context),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: ScreenUtil().setHeight(6),
                                          horizontal: ScreenUtil().setWidth(8),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              c.canvasHeaderTitle.value,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.archivo(
                                                fontSize:
                                                    ScreenUtil().setSp(17),
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.35,
                                                height: 1.15,
                                                color:
                                                    AppTheme.onSurfaceDark,
                                              ),
                                            ),
                                            SizedBox(
                                                height: ScreenUtil()
                                                    .setHeight(4)),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: ScreenUtil()
                                                      .setWidth(5),
                                                  height: ScreenUtil()
                                                      .setWidth(5),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppTheme
                                                        .primaryAccent,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: ScreenUtil()
                                                        .setWidth(6)),
                                                Flexible(
                                                  child: Text(
                                                    '${Lang.canvasTitle} · ${c.doc.value.canvasWidth.round()} × ${c.doc.value.canvasHeight.round()}',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts
                                                        .spaceGrotesk(
                                                      fontSize:
                                                          ScreenUtil()
                                                              .setSp(11),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      letterSpacing: 0.25,
                                                      color: AppTheme
                                                          .onSurfaceVariantDark,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: ScreenUtil().setWidth(4)),
                              _ChromeIconButton(
                                icon: Icons.undo_rounded,
                                onPressed: c.undo,
                                tooltip: Lang.canvasUndo,
                                color: cs.onSurface,
                              ),
                              SizedBox(width: ScreenUtil().setWidth(4)),
                              _ChromeIconButton(
                                icon: Icons.redo_rounded,
                                onPressed: c.redo,
                                tooltip: Lang.canvasRedo,
                                color: cs.onSurface,
                              ),
                              SizedBox(width: ScreenUtil().setWidth(4)),
                              _ChromeIconButton(
                                icon: Icons.fit_screen_rounded,
                                onPressed: c.resetView,
                                tooltip: Lang.toolResetView,
                                color: cs.onSurface,
                              ),
                            ],
                          ),
                        ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFF0C0C0E),
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(14),
                      vertical: ScreenUtil().setHeight(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        ScreenUtil().radius(14),
                      ),
                      child: ColoredBox(
                        color: const Color(0xFF121214),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!context.mounted) {
                                return;
                              }
                              c.fitCanvasToViewportIfNeeded(
                                Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                ),
                              );
                            });
                            return InteractiveViewer(
                              transformationController: _tc,
                              minScale: 0.2,
                              maxScale: 5,
                              panEnabled: false,
                              clipBehavior: Clip.hardEdge,
                              boundaryMargin: const EdgeInsets.all(1e6),
                              child: Center(
                                child: RepaintBoundary(
                                  key: c.painterKey,
                                  child: Listener(
                                    behavior: HitTestBehavior.opaque,
                                    onPointerDown: _onDown,
                                    onPointerMove: _onMove,
                                    onPointerUp: _onUp,
                                    onPointerCancel: _onCancel,
                                    child: SizedBox(
                                      width: c.doc.value.canvasWidth,
                                      height: c.doc.value.canvasHeight,
                                      child: CustomPaint(
                                        isComplex: true,
                                        willChange: true,
                                        painter: DocumentPainter(
                                          c.doc.value,
                                          revision: rev,
                                          draftFreehand: c.draftFreehand,
                                          draftLine: c.draftLine,
                                          draftRect: c.draftRect,
                                          draftEllipse: c.draftEllipse,
                                          rasterUi: c.rasterUi,
                                          previewColor: previewColor,
                                          previewWidth: previewW,
                                          showReferenceDim: false,
                                          referenceImage:
                                              c.referenceImageForPaint,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                ColoredBox(
                  color: AppTheme.surfaceDark,
                  child: SafeArea(
                    top: false,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        border: Border(
                          top: BorderSide(
                            color: AppTheme.outlineDark
                                .withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        ScreenUtil().setWidth(14),
                        ScreenUtil().setHeight(12),
                        ScreenUtil().setWidth(14),
                        ScreenUtil().setHeight(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (busy)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: ScreenUtil().setHeight(10),
                              ),
                              child: LinearProgressIndicator(
                                minHeight: 3,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(99),
                                ),
                                color: AppTheme.primaryAccent,
                                backgroundColor: AppTheme.outlineDark,
                              ),
                            )
                          else ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                Lang.canvasQuickTools,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(11),
                                  color: AppTheme.onSurfaceVariantDark,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            SizedBox(height: ScreenUtil().setHeight(8)),
                            SizedBox(
                              height: ScreenUtil().setHeight(52),
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.zero,
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  _QuickTool(
                                    selected: activeTool == DrawTool.pen,
                                    icon: Icons.brush_rounded,
                                    tooltip: Lang.toolPen,
                                    onTap: () => c.setTool(DrawTool.pen),
                                  ),
                                  SizedBox(width: ScreenUtil().setWidth(8)),
                                  _QuickTool(
                                    selected: activeTool == DrawTool.eraser,
                                    icon: Icons.auto_fix_high_rounded,
                                    tooltip: Lang.toolEraser,
                                    onTap: () => c.setTool(DrawTool.eraser),
                                  ),
                                  SizedBox(width: ScreenUtil().setWidth(8)),
                                  _QuickTool(
                                    selected: activeTool == DrawTool.line,
                                    icon: Icons.show_chart_rounded,
                                    tooltip: Lang.toolLine,
                                    onTap: () => c.setTool(DrawTool.line),
                                  ),
                                  SizedBox(width: ScreenUtil().setWidth(8)),
                                  _QuickTool(
                                    selected: activeTool == DrawTool.rect,
                                    icon: Icons.crop_square_rounded,
                                    tooltip: Lang.toolRect,
                                    onTap: () => c.setTool(DrawTool.rect),
                                  ),
                                  SizedBox(width: ScreenUtil().setWidth(8)),
                                  _QuickTool(
                                    selected: activeTool == DrawTool.ellipse,
                                    icon: Icons.circle_outlined,
                                    tooltip: Lang.toolEllipse,
                                    onTap: () => c.setTool(DrawTool.ellipse),
                                  ),
                                  SizedBox(width: ScreenUtil().setWidth(8)),
                                  _QuickTool(
                                    selected: activeTool == DrawTool.bucket,
                                    icon: Icons.format_color_fill_rounded,
                                    tooltip: Lang.toolBucket,
                                    onTap: () => c.setTool(DrawTool.bucket),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: ScreenUtil().setHeight(12)),
                            Row(
                              children: [
                                Tooltip(
                                  message: Lang.canvasAllTools,
                                  child: Material(
                                    color: AppTheme.surfaceContainerDark,
                                    borderRadius: BorderRadius.circular(14),
                                    child: InkWell(
                                      onTap: () => c.openToolSheet(context),
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        width: ScreenUtil().setWidth(48),
                                        height: ScreenUtil().setWidth(48),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color: AppTheme.outlineDark,
                                            width: 1,
                                          ),
                                        ),
                                        child: Container(
                                          width: ScreenUtil().setWidth(32),
                                          height: ScreenUtil().setWidth(32),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(previewColor),
                                            border: Border.all(
                                              color: AppTheme
                                                  .onSurfaceVariantDark
                                                  .withValues(alpha: 0.4),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: ScreenUtil().setWidth(12)),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () =>
                                        unawaited(c.saveNow()),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppTheme.primaryAccent,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: ScreenUtil().setHeight(14),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.save_rounded,
                                          size: ScreenUtil().setWidth(22),
                                        ),
                                        SizedBox(
                                            width: ScreenUtil().setWidth(8)),
                                        Flexible(
                                          child: Text(
                                            Lang.canvasSave,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: ScreenUtil().setSp(16),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ],
                    ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ChromeIconButton extends StatelessWidget {
  const _ChromeIconButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final s = ScreenUtil().setWidth(44);
    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: s,
          height: s,
          child: Icon(
            icon,
            size: ScreenUtil().setWidth(24),
            color: color,
          ),
        ),
      ),
    );
    final t = tooltip;
    if (t != null && t.isNotEmpty) {
      return Tooltip(message: t, child: child);
    }
    return child;
  }
}

class _QuickTool extends StatelessWidget {
  const _QuickTool({
    required this.selected,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = ScreenUtil().setWidth(52);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: selected
            ? AppTheme.primaryAccent.withValues(alpha: 0.22)
            : AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: w,
            height: w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? AppTheme.primaryAccent
                    : AppTheme.outlineDark,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Icon(
              icon,
              size: ScreenUtil().setWidth(24),
              color: selected
                  ? AppTheme.primaryAccent
                  : AppTheme.onSurfaceVariantDark,
            ),
          ),
        ),
      ),
    );
  }
}
