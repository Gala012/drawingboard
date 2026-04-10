import 'package:drawing_board/lang/lang.dart';
import 'package:drawing_board/pages/stats/stats_logic.dart';
import 'package:drawing_board/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StatsView extends GetView<StatsLogic> {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final numFmt = NumberFormat.decimalPattern('en_US');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Lang.statsTitle,
          style: TextStyle(fontSize: ScreenUtil().setSp(18)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              Lang.statsSectionActivity,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.titleSmall?.copyWith(
                fontSize: ScreenUtil().setSp(13),
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurfaceVariantDark,
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(10)),
            Obx(
              () => _statsPairRow(
                _StatCard(
                  label: Lang.statsTodayStrokes,
                  value: numFmt.format(controller.todayStrokes.value),
                  valueFontSize: ScreenUtil().setSp(22),
                  valueColor: AppTheme.secondaryAccent,
                ),
                _StatCard(
                  label: Lang.statsLast7Days,
                  value: numFmt.format(controller.last7Strokes.value),
                  valueFontSize: ScreenUtil().setSp(22),
                  valueColor: AppTheme.primaryAccent,
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(20)),
            Text(
              Lang.statsSectionTotals,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.titleSmall?.copyWith(
                fontSize: ScreenUtil().setSp(13),
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurfaceVariantDark,
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(10)),
            Obx(
              () => _statsPairRow(
                _StatCard(
                  label: Lang.statsStrokeTotal,
                  value: numFmt.format(controller.totalStrokes.value),
                  valueFontSize: ScreenUtil().setSp(22),
                ),
                _StatCard(
                  label: Lang.statsStreak,
                  value: numFmt.format(controller.streakDays.value),
                  valueFontSize: ScreenUtil().setSp(22),
                  valueColor: AppTheme.secondaryAccent,
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(20)),
            Text(
              Lang.statsSectionWorks,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.titleSmall?.copyWith(
                fontSize: ScreenUtil().setSp(13),
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurfaceVariantDark,
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(10)),
            Obx(
              () => _statsPairRow(
                _StatCard(
                  label: Lang.statsWorksCount,
                  value: numFmt.format(controller.projectCount.value),
                  valueFontSize: ScreenUtil().setSp(22),
                ),
                _StatCard(
                  label: Lang.statsTraceWorks,
                  value: numFmt.format(controller.traceProjectCount.value),
                  valueFontSize: ScreenUtil().setSp(22),
                  valueColor: AppTheme.secondaryAccent,
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(10)),
            Obx(
              () => _statsPairRow(
                _StatCard(
                  label: Lang.statsLayerTotal,
                  value: numFmt.format(controller.layerTotal.value),
                  valueFontSize: ScreenUtil().setSp(22),
                ),
                _StatCard(
                  label: Lang.statsLargestCanvas,
                  value: StatsView.largestCanvasValue(
                    controller.maxCanvasW.value,
                    controller.maxCanvasH.value,
                  ),
                  valueFontSize: ScreenUtil().setSp(20),
                  valueColor: AppTheme.primaryAccent,
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(10)),
            Obx(() {
              final ms = controller.latestUpdatedMs.value;
              if (ms <= 0) {
                return const SizedBox.shrink();
              }
              final df = DateFormat('yyyy-MM-dd HH:mm');
              return _StatCard(
                label: Lang.statsLastSaved,
                value: df.format(DateTime.fromMillisecondsSinceEpoch(ms)),
                valueFontSize: ScreenUtil().setSp(17),
                valueColor: AppTheme.onSurfaceDark,
              );
            }),
            SizedBox(height: ScreenUtil().setHeight(24)),
            Text(
              Lang.statsHeatmapTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.titleMedium?.copyWith(
                fontSize: ScreenUtil().setSp(16),
                color: AppTheme.onSurfaceDark,
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(12)),
            Obx(() {
              final counts = controller.heatmapCounts;
              final maxV = controller.heatmax.value;
              if (counts.isEmpty) {
                return const SizedBox.shrink();
              }
              return Wrap(
                spacing: ScreenUtil().setWidth(6),
                runSpacing: ScreenUtil().setHeight(6),
                children: List.generate(counts.length, (i) {
                  final n = counts[i];
                  final t = maxV > 0 ? (n / maxV).clamp(0.0, 1.0) : 0.0;
                  final col = Color.lerp(
                    AppTheme.surfaceContainerDark,
                    AppTheme.primaryAccent,
                    t,
                  )!;
                  return Container(
                    width: ScreenUtil().setWidth(22),
                    height: ScreenUtil().setHeight(28),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: col,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.outlineDark),
                    ),
                    child: n == 0
                        ? const SizedBox.shrink()
                        : Text(
                            n > 99 ? '99+' : '$n',
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(9),
                              color: AppTheme.onSurfaceDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  );
                }),
              );
            }),
            SizedBox(height: ScreenUtil().setHeight(24)),
            Obx(
              () => controller.totalStrokes.value == 0 &&
                      controller.projectCount.value == 0
                  ? Text(
                      Lang.statsPlaceholder,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodyMedium?.copyWith(
                        fontSize: ScreenUtil().setSp(14),
                        color: AppTheme.onSurfaceVariantDark,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  static String largestCanvasValue(int w, int h) {
    if (w <= 0 || h <= 0) {
      return Lang.statsDashEmpty;
    }
    return '$w×$h';
  }

  static Widget _statsPairRow(
    Widget left,
    Widget right,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        SizedBox(width: ScreenUtil().setWidth(10)),
        Expanded(child: right),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueFontSize,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final double? valueFontSize;

  @override
  Widget build(BuildContext context) {
    final fs = valueFontSize ?? ScreenUtil().setSp(24);
    final vc = valueColor ?? AppTheme.primaryAccent;
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerDark,
        borderRadius: BorderRadius.circular(ScreenUtil().radius(12)),
        border: Border.all(
          color: AppTheme.outlineDark.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: ScreenUtil().setSp(13),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceVariantDark,
                ),
          ),
          SizedBox(height: ScreenUtil().setHeight(8)),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: fs,
                  fontWeight: FontWeight.w700,
                  color: vc,
                  height: 1.15,
                ),
          ),
        ],
      ),
    );
  }
}
