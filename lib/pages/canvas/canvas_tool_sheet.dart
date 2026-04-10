import 'package:drawing_board/drawing/document_model.dart';
import 'package:drawing_board/lang/lang.dart';
import 'package:drawing_board/pages/canvas/canvas_logic.dart';
import 'package:drawing_board/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CanvasToolSheet extends StatefulWidget {
  const CanvasToolSheet({super.key, required this.logic});

  final CanvasLogic logic;

  @override
  State<CanvasToolSheet> createState() => _CanvasToolSheetState();
}

class _CanvasToolSheetState extends State<CanvasToolSheet>
    with SingleTickerProviderStateMixin {
  static const List<_ToolSpec> _tools = [
    _ToolSpec(DrawTool.pen, Lang.toolPen, Icons.brush_rounded),
    _ToolSpec(DrawTool.eraser, Lang.toolEraser, Icons.auto_fix_high_rounded),
    _ToolSpec(DrawTool.line, Lang.toolLine, Icons.show_chart_rounded),
    _ToolSpec(DrawTool.rect, Lang.toolRect, Icons.crop_square_rounded),
    _ToolSpec(DrawTool.ellipse, Lang.toolEllipse, Icons.circle_outlined),
    _ToolSpec(DrawTool.bucket, Lang.toolBucket, Icons.format_color_fill_rounded),
  ];

  late TabController _tabController;
  int _tabLen = 2;

  int _needTabLen(CanvasLogic logic) =>
      logic.doc.value.referenceImagePath != null ? 3 : 2;

  @override
  void initState() {
    super.initState();
    _tabLen = _needTabLen(widget.logic);
    _tabController = TabController(length: _tabLen, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final logic = widget.logic;
      final needLen = _needTabLen(logic);
      if (needLen != _tabLen) {
        final nextLen = needLen;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (nextLen != _needTabLen(widget.logic)) return;
          final idx = _tabController.index.clamp(0, nextLen - 1);
          setState(() {
            _tabController.dispose();
            _tabLen = nextLen;
            _tabController = TabController(
              length: nextLen,
              vsync: this,
              initialIndex: idx,
            );
          });
        });
      }
      return _buildSheet(context, logic);
    });
  }

  Widget _buildSheet(BuildContext context, CanvasLogic logic) {
    final mq = MediaQuery.of(context);
    final hs = ScreenUtil().setWidth(20);
    final vs = ScreenUtil().setHeight(6);

    final tabs = <Widget>[
      Tab(text: Lang.toolSectionColorStroke),
      Tab(text: Lang.toolSectionLayersPanel),
      if (_tabLen == 3) Tab(text: Lang.toolSectionTraceRef),
    ];

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: mq.size.height * 0.92),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            flex: 2,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(hs, vs, hs, 0),
              child: Column(
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
                  SizedBox(height: ScreenUtil().setHeight(18)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Lang.canvasAllTools,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontSize: ScreenUtil().setSp(22),
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.onSurfaceDark,
                                    letterSpacing: -0.3,
                                  ),
                            ),
                            SizedBox(height: ScreenUtil().setHeight(4)),
                            Text(
                              Lang.toolSheetSubtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(13),
                                height: 1.35,
                                color: AppTheme.onSurfaceVariantDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: Lang.canvasClose,
                        style: IconButton.styleFrom(
                          foregroundColor: AppTheme.onSurfaceVariantDark,
                        ),
                        onPressed: Get.back,
                        icon: Icon(Icons.close_rounded,
                            size: ScreenUtil().setWidth(24)),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setHeight(22)),
                  _sectionLabel(context, Lang.toolSectionDrawing),
                  SizedBox(height: ScreenUtil().setHeight(10)),
                  _sectionCard(
                    child: GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: ScreenUtil().setHeight(10),
                      crossAxisSpacing: ScreenUtil().setWidth(10),
                      childAspectRatio: 0.92,
                      children: [
                        for (final spec in _tools)
                          _ToolGridTile(
                            spec: spec,
                            selected: logic.tool.value == spec.tool,
                            onTap: () => logic.setTool(spec.tool),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hs),
            child: Theme(
              data: Theme.of(context).copyWith(
                splashColor:
                    AppTheme.primaryAccent.withValues(alpha: 0.12),
                hoverColor:
                    AppTheme.primaryAccent.withValues(alpha: 0.06),
              ),
              child: Material(
                color: Colors.transparent,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: AppTheme.primaryAccent,
                  unselectedLabelColor: AppTheme.onSurfaceVariantDark,
                  labelStyle: TextStyle(
                    fontSize: ScreenUtil().setSp(14),
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: ScreenUtil().setSp(14),
                    fontWeight: FontWeight.w600,
                  ),
                  indicatorColor: AppTheme.primaryAccent,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor:
                      AppTheme.outlineDark.withValues(alpha: 0.45),
                  dividerHeight: 1,
                  tabs: tabs,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildColorStrokeTab(context, logic, hs),
                _buildLayersTab(context, logic, hs),
                if (_tabLen == 3) _buildTraceTab(context, logic, hs),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              hs,
              ScreenUtil().setHeight(16),
              hs,
              ScreenUtil().setHeight(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Get.back();
                      await logic.sharePng();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.onSurfaceDark,
                      side: BorderSide(
                        color: AppTheme.outlineDark.withValues(alpha: 0.85),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setHeight(14),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ScreenUtil().radius(14)),
                      ),
                    ),
                    icon: Icon(
                      Icons.ios_share_rounded,
                      size: ScreenUtil().setWidth(20),
                    ),
                    label: Text(
                      Lang.toolExportShare,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(15),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(12)),
                Expanded(
                  child: FilledButton(
                    onPressed: Get.back,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setHeight(14),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ScreenUtil().radius(14)),
                      ),
                    ),
                    child: Text(
                      Lang.canvasClose,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(15),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorStrokeTab(
      BuildContext context, CanvasLogic logic, double hs) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(hs, ScreenUtil().setHeight(12), hs, 16),
      child: _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: ScreenUtil().setWidth(44),
                  height: ScreenUtil().setWidth(44),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(logic.brushColor.value),
                    border: Border.all(
                      color: AppTheme.outlineDark,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(14)),
                Expanded(
                  child: Text(
                    Lang.canvasCurrentColor,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(13),
                      height: 1.35,
                      color: AppTheme.onSurfaceVariantDark,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setHeight(12)),
            Text(
              Lang.toolRecentColors,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(12),
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceDark,
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(10)),
            SizedBox(
              height: ScreenUtil().setHeight(44),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: logic.recentColors.length,
                separatorBuilder: (context, _) =>
                    SizedBox(width: ScreenUtil().setWidth(10)),
                itemBuilder: (context, i) {
                  final c = logic.recentColors[i];
                  final on = logic.brushColor.value == c;
                  return GestureDetector(
                    onTap: () => logic.setColor(c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      width: ScreenUtil().setWidth(40),
                      height: ScreenUtil().setWidth(40),
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: on
                              ? AppTheme.primaryAccent
                              : AppTheme.outlineDark,
                          width: on ? 2.5 : 1,
                        ),
                        boxShadow: on
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryAccent
                                      .withValues(alpha: 0.35),
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(18)),
            Row(
              children: [
                Expanded(
                  child: Text(
                    Lang.toolBrushSize,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(13),
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceDark,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(10),
                    vertical: ScreenUtil().setHeight(4),
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryAccent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppTheme.primaryAccent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    '${logic.brushWidth.value.round()} ${Lang.toolPixelUnit}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(12),
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryAccent,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setHeight(6)),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppTheme.primaryAccent,
                inactiveTrackColor:
                    AppTheme.outlineDark.withValues(alpha: 0.55),
                thumbColor: AppTheme.primaryAccent,
                overlayColor: AppTheme.primaryAccent.withValues(alpha: 0.2),
                trackHeight: 3,
              ),
              child: Slider(
                value: logic.brushWidth.value.clamp(1, 48),
                min: 1,
                max: 48,
                onChanged: (v) => logic.brushWidth.value = v,
              ),
            ),
            Divider(
              height: ScreenUtil().setHeight(22),
              color: AppTheme.outlineDark.withValues(alpha: 0.45),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Lang.toolShapeFill,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(13),
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurfaceDark,
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(2)),
                      Text(
                        Lang.toolShapeFillHint,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(11),
                          height: 1.3,
                          color: AppTheme.onSurfaceVariantDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: logic.shapeFilled.value,
                  onChanged: (v) => logic.shapeFilled.value = v,
                  activeTrackColor:
                      AppTheme.primaryAccent.withValues(alpha: 0.45),
                  activeThumbColor: AppTheme.primaryAccent,
                  inactiveTrackColor:
                      AppTheme.outlineDark.withValues(alpha: 0.65),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayersTab(
      BuildContext context, CanvasLogic logic, double hs) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(hs, ScreenUtil().setHeight(12), hs, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${Lang.toolLayer} · ${logic.doc.value.activeLayerIndex + 1}/${logic.doc.value.layers.length}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(12),
                    color: AppTheme.onSurfaceVariantDark,
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor:
                      AppTheme.primaryAccent.withValues(alpha: 0.12),
                  foregroundColor: AppTheme.primaryAccent,
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(12),
                    vertical: ScreenUtil().setHeight(8),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: logic.addLayer,
                icon:
                    Icon(Icons.add_rounded, size: ScreenUtil().setWidth(18)),
                label: Text(
                  Lang.toolAddLayer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(13),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setHeight(10)),
          _sectionCard(
            child: Column(
              children:
                  List.generate(logic.doc.value.layers.length, (i) {
                final l = logic.doc.value.layers[i];
                final active = i == logic.doc.value.activeLayerIndex;
                final bottom = i < logic.doc.value.layers.length - 1
                    ? Border(
                        bottom: BorderSide(
                          color: AppTheme.outlineDark
                              .withValues(alpha: 0.4),
                        ),
                      )
                    : null;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => logic.setActiveLayer(i),
                    borderRadius:
                        active ? BorderRadius.circular(12) : BorderRadius.zero,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setHeight(12),
                        horizontal: ScreenUtil().setWidth(4),
                      ),
                      decoration: BoxDecoration(
                        border: bottom,
                        color: active
                            ? AppTheme.primaryAccent.withValues(alpha: 0.1)
                            : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            icon: Icon(
                              l.visible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              size: ScreenUtil().setWidth(22),
                              color: l.visible
                                  ? AppTheme.onSurfaceVariantDark
                                  : AppTheme.onSurfaceVariantDark
                                      .withValues(alpha: 0.45),
                            ),
                            onPressed: () => logic.toggleLayerVisible(i),
                          ),
                          SizedBox(width: ScreenUtil().setWidth(4)),
                          Expanded(
                            child: Text(
                              l.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(14),
                                fontWeight: active
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: AppTheme.onSurfaceDark,
                              ),
                            ),
                          ),
                          if (active)
                            Padding(
                              padding: EdgeInsets.only(
                                right: ScreenUtil().setWidth(8),
                              ),
                              child: Icon(
                                Icons.check_circle_rounded,
                                size: ScreenUtil().setWidth(22),
                                color: AppTheme.primaryAccent,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraceTab(BuildContext context, CanvasLogic logic, double hs) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(hs, ScreenUtil().setHeight(12), hs, 16),
      child: _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    Lang.toolReferenceOpacity,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(13),
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceDark,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(10),
                    vertical: ScreenUtil().setHeight(4),
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryAccent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppTheme.primaryAccent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    '${(logic.doc.value.referenceImageOpacity * 100).round()}%',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(12),
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryAccent,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setHeight(6)),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppTheme.primaryAccent,
                inactiveTrackColor:
                    AppTheme.outlineDark.withValues(alpha: 0.55),
                thumbColor: AppTheme.primaryAccent,
                overlayColor: AppTheme.primaryAccent.withValues(alpha: 0.2),
                trackHeight: 3,
              ),
              child: Slider(
                value:
                    logic.doc.value.referenceImageOpacity.clamp(0.0, 1.0),
                min: 0,
                max: 1,
                onChanged: logic.setReferenceOpacity,
              ),
            ),
            Divider(
              height: ScreenUtil().setHeight(20),
              color: AppTheme.outlineDark.withValues(alpha: 0.45),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Lang.toolReferenceFit,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(13),
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurfaceDark,
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(2)),
                      Text(
                        Lang.toolReferenceFitHint,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(11),
                          height: 1.3,
                          color: AppTheme.onSurfaceVariantDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: logic.doc.value.referenceFitContain,
                  onChanged: logic.setReferenceFitContain,
                  activeTrackColor:
                      AppTheme.primaryAccent.withValues(alpha: 0.45),
                  activeThumbColor: AppTheme.primaryAccent,
                  inactiveTrackColor:
                      AppTheme.outlineDark.withValues(alpha: 0.65),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: ScreenUtil().setWidth(3),
          height: ScreenUtil().setHeight(14),
          decoration: BoxDecoration(
            color: AppTheme.primaryAccent,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(8)),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(13),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: AppTheme.onSurfaceVariantDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(ScreenUtil().radius(16)),
        border: Border.all(
          color: AppTheme.outlineDark.withValues(alpha: 0.55),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(14)),
        child: child,
      ),
    );
  }
}

class _ToolSpec {
  const _ToolSpec(this.tool, this.label, this.icon);
  final DrawTool tool;
  final String label;
  final IconData icon;
}

class _ToolGridTile extends StatelessWidget {
  const _ToolGridTile({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final _ToolSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtil().radius(14)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primaryAccent.withValues(alpha: 0.16)
                : AppTheme.surfaceContainerDark.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(ScreenUtil().radius(14)),
            border: Border.all(
              color: selected
                  ? AppTheme.primaryAccent
                  : AppTheme.outlineDark.withValues(alpha: 0.65),
              width: selected ? 1.5 : 1,
            ),
          ),
          padding: EdgeInsets.symmetric(
            vertical: ScreenUtil().setHeight(10),
            horizontal: ScreenUtil().setWidth(6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                spec.icon,
                size: ScreenUtil().setWidth(26),
                color: selected
                    ? AppTheme.primaryAccent
                    : AppTheme.onSurfaceVariantDark,
              ),
              SizedBox(height: ScreenUtil().setHeight(8)),
              Text(
                spec.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(12),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? AppTheme.onSurfaceDark
                      : AppTheme.onSurfaceVariantDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
