import 'package:drawing_board/lang/lang.dart';
import 'package:drawing_board/pages/profile/profile_logic.dart';
import 'package:drawing_board/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ProfileView extends GetView<ProfileLogic> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
          children: [
            SizedBox(height: ScreenUtil().setHeight(20)),
            Text(
              Lang.profileTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.headlineSmall?.copyWith(
                fontSize: ScreenUtil().setSp(28),
                color: AppTheme.onSurfaceDark,
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(8)),
            Text(
              Lang.profileSummarySection,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.titleSmall?.copyWith(
                fontSize: ScreenUtil().setSp(14),
                color: AppTheme.onSurfaceVariantDark,
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(12)),
            Obx(() {
              if (controller.summaryLoading.value) {
                return Container(
                  height: ScreenUtil().setHeight(100),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerDark,
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().radius(12)),
                  ),
                  child: SizedBox(
                    width: ScreenUtil().setWidth(28),
                    height: ScreenUtil().setWidth(28),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryAccent,
                    ),
                  ),
                );
              }
              return Material(
                color: AppTheme.surfaceContainerDark,
                borderRadius:
                    BorderRadius.circular(ScreenUtil().radius(12)),
                child: InkWell(
                  onTap: controller.openStats,
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().radius(12)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: ScreenUtil().setHeight(16),
                      horizontal: ScreenUtil().setWidth(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _ProfileStatCell(
                                value: '${controller.projectCount.value}',
                                label: Lang.profileStatWorks,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: ScreenUtil().setHeight(40),
                              color: AppTheme.outlineDark,
                            ),
                            Expanded(
                              child: _ProfileStatCell(
                                value:
                                    '${controller.totalStrokes.value}',
                                label: Lang.statsStrokeTotal,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: ScreenUtil().setHeight(40),
                              color: AppTheme.outlineDark,
                            ),
                            Expanded(
                              child: _ProfileStatCell(
                                value:
                                    '${controller.streakDays.value}',
                                label: Lang.statsStreak,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ScreenUtil().setHeight(8)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              Lang.profileSummaryMore,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tt.labelMedium?.copyWith(
                                fontSize: ScreenUtil().setSp(13),
                                color: AppTheme.secondaryAccent,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: ScreenUtil().setWidth(18),
                              color: AppTheme.secondaryAccent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            SizedBox(height: ScreenUtil().setHeight(24)),
            _ProfileTile(
              icon: Icons.bar_chart_outlined,
              title: Lang.profileStats,
              onTap: controller.openStats,
            ),
            SizedBox(height: ScreenUtil().setHeight(8)),
            _ProfileTile(
              icon: Icons.settings_outlined,
              title: Lang.profileSettings,
              onTap: controller.openSettings,
            ),
            SizedBox(height: ScreenUtil().setHeight(8)),
            _ProfileTile(
              icon: Icons.help_outline,
              title: Lang.profileHelp,
              onTap: controller.openHelp,
            ),
            SizedBox(height: ScreenUtil().setHeight(8)),
            _ProfileTile(
              icon: Icons.info_outline,
              title: Lang.profileAbout,
              onTap: controller.openAbout,
            ),
            SizedBox(height: ScreenUtil().setHeight(24)),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatCell extends StatelessWidget {
  const _ProfileStatCell({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(4)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: ScreenUtil().setSp(20),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryAccent,
                ),
          ),
          SizedBox(height: ScreenUtil().setHeight(4)),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: ScreenUtil().setSp(11),
                  color: AppTheme.onSurfaceVariantDark,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceContainerDark,
      borderRadius: BorderRadius.circular(ScreenUtil().radius(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtil().radius(12)),
        child: SizedBox(
          height: ScreenUtil().setHeight(56),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.onSurfaceVariantDark),
                SizedBox(width: ScreenUtil().setWidth(12)),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: ScreenUtil().setSp(16),
                          color: AppTheme.onSurfaceDark,
                        ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.onSurfaceVariantDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
