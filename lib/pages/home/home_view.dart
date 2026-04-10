import 'dart:io';

import 'package:drawing_board/lang/lang.dart';
import 'package:drawing_board/pages/home/home_logic.dart';
import 'package:drawing_board/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeView extends GetView<HomeLogic> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final df = DateFormat('MM-dd HH:mm');
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding:
                  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: ScreenUtil().setHeight(24)),
                    Text(
                      Lang.homeTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.headlineMedium?.copyWith(
                        fontSize: ScreenUtil().setSp(34),
                        color: AppTheme.onSurfaceDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(8)),
                    Text(
                      Lang.homeSubtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodyMedium?.copyWith(
                        fontSize: ScreenUtil().setSp(14),
                        height: 1.4,
                        color: AppTheme.onSurfaceVariantDark,
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(20)),
                    Obx(() {
                      if (controller.projects.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final row = controller.projects.first;
                      return Material(
                        color: AppTheme.primaryAccent.withValues(alpha: 0.14),
                        borderRadius:
                            BorderRadius.circular(ScreenUtil().radius(14)),
                        child: InkWell(
                          onTap: controller.openFirstProject,
                          borderRadius:
                              BorderRadius.circular(ScreenUtil().radius(14)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(16),
                              vertical: ScreenUtil().setHeight(14),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.history_rounded,
                                  color: AppTheme.primaryAccent,
                                  size: ScreenUtil().setWidth(26),
                                ),
                                SizedBox(width: ScreenUtil().setWidth(12)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        Lang.homeContinuePrefix,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: ScreenUtil().setSp(12),
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryAccent,
                                        ),
                                      ),
                                      SizedBox(
                                          height: ScreenUtil().setHeight(4)),
                                      Text(
                                        row.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: tt.titleSmall?.copyWith(
                                          fontSize: ScreenUtil().setSp(15),
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.onSurfaceDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppTheme.onSurfaceVariantDark,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: ScreenUtil().setHeight(16)),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: controller.openNewCanvas,
                        child: Text(
                          Lang.homeNewCanvas,
                          style: TextStyle(fontSize: ScreenUtil().setSp(16)),
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(20)),
                    Obx(() => _HomeMiniSummary(
                          projectCount: controller.projectCount.value,
                          totalStrokes: controller.totalStrokes.value,
                          onOpenStats: controller.openStats,
                        )),
                    SizedBox(height: ScreenUtil().setHeight(24)),
                    Row(
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
                            Lang.homeQuickTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(13),
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurfaceVariantDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ScreenUtil().setHeight(12)),
                    Row(
                      children: [
                        Expanded(
                          child: _HomeQuickTile(
                            icon: Icons.draw_outlined,
                            label: Lang.homeQuickTrace,
                            onTap: controller.goTraceTab,
                          ),
                        ),
                        SizedBox(width: ScreenUtil().setWidth(10)),
                        Expanded(
                          child: _HomeQuickTile(
                            icon: Icons.tune_rounded,
                            label: Lang.homeQuickSettings,
                            onTap: controller.openSettings,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ScreenUtil().setHeight(28)),
                    Text(
                      Lang.homeRecent,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleLarge?.copyWith(
                        fontSize: ScreenUtil().setSp(18),
                        color: AppTheme.onSurfaceDark,
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(16)),
                  ],
                ),
              ),
            ),
            Obx(() {
              if (controller.projects.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(20),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerDark,
                        borderRadius:
                            BorderRadius.circular(ScreenUtil().radius(12)),
                      ),
                      child: Text(
                        Lang.homeEmpty,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodyMedium?.copyWith(
                          fontSize: ScreenUtil().setSp(15),
                          color: AppTheme.onSurfaceVariantDark,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return SliverList.separated(
                itemCount: controller.projects.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: ScreenUtil().setHeight(10)),
                itemBuilder: (_, i) {
                  final row = controller.projects[i];
                  final thumb = row.thumbPath;
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(20),
                    ),
                    child: Material(
                      color: AppTheme.surfaceContainerDark,
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().radius(12)),
                      child: InkWell(
                        onTap: () => controller.openProject(row),
                        borderRadius:
                            BorderRadius.circular(ScreenUtil().radius(12)),
                        child: SizedBox(
                          height: ScreenUtil().setHeight(88),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(
                                    ScreenUtil().radius(12),
                                  ),
                                ),
                                child: SizedBox(
                                  width: ScreenUtil().setWidth(100),
                                  height: double.infinity,
                                  child: thumb != null &&
                                          File(thumb).existsSync()
                                      ? Image.file(
                                          File(thumb),
                                          fit: BoxFit.cover,
                                        )
                                      : ColoredBox(
                                          color: AppTheme.surfaceDark,
                                          child: Icon(
                                            Icons.image_outlined,
                                            color:
                                                AppTheme.onSurfaceVariantDark,
                                          ),
                                        ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil().setWidth(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        row.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: tt.titleMedium?.copyWith(
                                          fontSize: ScreenUtil().setSp(16),
                                          color: AppTheme.onSurfaceDark,
                                        ),
                                      ),
                                      Text(
                                        df.format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                            row.updatedAt,
                                          ),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: tt.bodySmall?.copyWith(
                                          fontSize: ScreenUtil().setSp(13),
                                          color: AppTheme.onSurfaceVariantDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => controller.deleteProject(row),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
            SliverToBoxAdapter(
              child: SizedBox(height: ScreenUtil().setHeight(32)),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeMiniSummary extends StatelessWidget {
  const _HomeMiniSummary({
    required this.projectCount,
    required this.totalStrokes,
    required this.onOpenStats,
  });

  final int projectCount;
  final int totalStrokes;
  final VoidCallback onOpenStats;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final numFmt = NumberFormat.decimalPattern('en_US');
    final outerR = ScreenUtil().radius(16);
    final innerR = ScreenUtil().radius(15);
    final borderW = ScreenUtil().setWidth(1.5);
    return Semantics(
      button: true,
      label: Lang.homeMiniSummaryTitle,
      hint: Lang.homeMiniSummaryTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(outerR),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryAccent.withValues(alpha: 0.55),
              AppTheme.secondaryAccent.withValues(alpha: 0.40),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(borderW),
          child: Material(
            color: AppTheme.surfaceContainerDark,
            borderRadius: BorderRadius.circular(innerR),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onOpenStats,
              borderRadius: BorderRadius.circular(innerR),
              splashColor: AppTheme.primaryAccent.withValues(alpha: 0.14),
              highlightColor: AppTheme.primaryAccent.withValues(alpha: 0.07),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(16),
                  ScreenUtil().setHeight(14),
                  ScreenUtil().setWidth(14),
                  ScreenUtil().setHeight(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: ScreenUtil().setWidth(3),
                          height: ScreenUtil().setHeight(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.primaryAccent,
                                AppTheme.secondaryAccent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        SizedBox(width: ScreenUtil().setWidth(8)),
                        Expanded(
                          child: Text(
                            Lang.homeMiniSummaryTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.titleSmall?.copyWith(
                              fontSize: ScreenUtil().setSp(15),
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurfaceDark,
                            ),
                          ),
                        ),
                        Text(
                          Lang.homeMiniSummaryCtaShort,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(13),
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondaryAccent,
                          ),
                        ),
                        SizedBox(width: ScreenUtil().setWidth(4)),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: ScreenUtil().setWidth(22),
                          color: AppTheme.onSurfaceVariantDark,
                        ),
                      ],
                    ),
                    SizedBox(height: ScreenUtil().setHeight(14)),
                    Row(
                      children: [
                        _HomeStatCell(
                          icon: Icons.collections_bookmark_outlined,
                          label: Lang.profileStatWorks,
                          value: numFmt.format(projectCount),
                          accent: AppTheme.primaryAccent,
                        ),
                        SizedBox(width: ScreenUtil().setWidth(10)),
                        _HomeStatCell(
                          icon: Icons.brush_outlined,
                          label: Lang.statsStrokeTotal,
                          value: numFmt.format(totalStrokes),
                          accent: AppTheme.secondaryAccent,
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
    );
  }
}

class _HomeStatCell extends StatelessWidget {
  const _HomeStatCell({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(ScreenUtil().radius(12)),
          border: Border.all(
            color: AppTheme.outlineDark.withValues(alpha: 0.4),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(12),
            vertical: ScreenUtil().setHeight(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: ScreenUtil().setWidth(18),
                    color: accent.withValues(alpha: 0.9),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(6)),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(12),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurfaceVariantDark,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(8)),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.titleLarge?.copyWith(
                  fontSize: ScreenUtil().setSp(22),
                  fontWeight: FontWeight.w700,
                  color: accent,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeQuickTile extends StatelessWidget {
  const _HomeQuickTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceContainerDark,
      borderRadius: BorderRadius.circular(ScreenUtil().radius(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtil().radius(12)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(12),
            vertical: ScreenUtil().setHeight(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: ScreenUtil().setWidth(26),
                color: AppTheme.primaryAccent,
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(13),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
