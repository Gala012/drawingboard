import 'package:drawing_board/lang/lang.dart';
import 'package:drawing_board/pages/guide/guide_logic.dart';
import 'package:drawing_board/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GuideView extends GetView<GuideLogic> {
  const GuideView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: controller.skip,
                    child: Text(
                      Lang.guideSkip,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(15),
                        color: AppTheme.onSurfaceVariantDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: [
                  _GuidePage(
                    title: Lang.guideSlide1Title,
                    subtitle: Lang.guideSlide1Subtitle,
                  ),
                  _GuidePage(
                    title: Lang.guideSlide2Title,
                    subtitle: Lang.guideSlide2Subtitle,
                  ),
                  _GuidePage(
                    title: Lang.guideSlide3Title,
                    subtitle: Lang.guideSlide3Subtitle,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                ScreenUtil().setWidth(24),
                ScreenUtil().setHeight(8),
                ScreenUtil().setWidth(24),
                ScreenUtil().setHeight(24),
              ),
              child: Column(
                children: [
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (i) {
                          final active = controller.currentPage.value == i;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(4),
                            ),
                            width: active
                                ? ScreenUtil().setWidth(22)
                                : ScreenUtil().setWidth(8),
                            height: ScreenUtil().setHeight(8),
                            decoration: BoxDecoration(
                              color: active
                                  ? cs.primary
                                  : AppTheme.outlineDark,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        }),
                      )),
                  SizedBox(height: ScreenUtil().setHeight(20)),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() {
                      final last = controller.currentPage.value == 2;
                      return FilledButton(
                        onPressed: controller.next,
                        child: Text(
                          last ? Lang.guideStart : Lang.guideNext,
                          style: TextStyle(fontSize: ScreenUtil().setSp(16)),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuidePage extends StatelessWidget {
  const _GuidePage({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(28)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.onSurfaceDark,
                  fontSize: ScreenUtil().setSp(32),
                  height: 1.05,
                ),
          ),
          SizedBox(height: ScreenUtil().setHeight(16)),
          Text(
            subtitle,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.onSurfaceVariantDark,
                  fontSize: ScreenUtil().setSp(16),
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}
