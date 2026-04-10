import 'package:drawing_board/lang/lang.dart';
import 'package:drawing_board/pages/assets/assets_logic.dart';
import 'package:drawing_board/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AssetsView extends GetView<AssetsLogic> {
  const AssetsView({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldDark,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: ScreenUtil().setHeight(12)),
              Text(
                Lang.assetsTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.headlineSmall?.copyWith(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurfaceDark,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(6)),
              Text(
                Lang.assetsPageSubtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(13),
                  height: 1.35,
                  color: AppTheme.onSurfaceVariantDark,
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(14)),
              Expanded(
                child: _TracePanel(tt: tt, logic: controller),
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TracePanel extends StatelessWidget {
  const _TracePanel({
    required this.tt,
    required this.logic,
  });

  final TextTheme tt;
  final AssetsLogic logic;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (logic.traceLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (logic.traceAssets.isEmpty) {
        return Center(
          child: Text(
            Lang.assetsEmpty,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(
              fontSize: ScreenUtil().setSp(15),
              color: AppTheme.onSurfaceVariantDark,
            ),
          ),
        );
      }
      return Container(
        padding: EdgeInsets.fromLTRB(
          ScreenUtil().setWidth(12),
          ScreenUtil().setHeight(12),
          ScreenUtil().setWidth(12),
          ScreenUtil().setHeight(8),
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerDark,
          borderRadius: BorderRadius.circular(ScreenUtil().radius(16)),
          border: Border.all(
            color: AppTheme.outlineDark.withValues(alpha: 0.55),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Lang.assetsTraceSectionTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleMedium?.copyWith(
                          fontSize: ScreenUtil().setSp(19),
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurfaceDark,
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(4)),
                      Text(
                        Lang.assetsTraceLibraryHint,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(12),
                          height: 1.35,
                          color: AppTheme.onSurfaceVariantDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(10),
                    vertical: ScreenUtil().setHeight(6),
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppTheme.outlineDark.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(
                    '${logic.traceAssets.length}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(13),
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryAccent,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setHeight(6)),
            Text(
              Lang.assetsTraceCount,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(11),
                color: AppTheme.onSurfaceVariantDark,
              ),
            ),
            if (logic.recentTracePaths.isNotEmpty) ...[
              SizedBox(height: ScreenUtil().setHeight(14)),
              Text(
                Lang.assetsTraceRecent,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(12),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurfaceVariantDark,
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              SizedBox(
                height: ScreenUtil().setHeight(124),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: logic.recentTracePaths.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(width: ScreenUtil().setWidth(10)),
                  itemBuilder: (ctx, i) {
                    final path = logic.recentTracePaths[i];
                    final stem = path.split('/').last.split('.').first;
                    return SizedBox(
                      width: ScreenUtil().setWidth(92),
                      child: Material(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(
                          ScreenUtil().radius(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => logic.openTracePreview(context, path),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Image.asset(
                                  path,
                                  fit: BoxFit.cover,
                                  cacheWidth: 240,
                                  errorBuilder: (c, e, _) => Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: AppTheme.onSurfaceVariantDark,
                                      size: ScreenUtil().setWidth(28),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil().setWidth(6),
                                  vertical: ScreenUtil().setHeight(6),
                                ),
                                child: Text(
                                  '#$stem',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(11),
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            SizedBox(height: ScreenUtil().setHeight(14)),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(4)),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: ScreenUtil().setWidth(12),
                  mainAxisSpacing: ScreenUtil().setHeight(12),
                  mainAxisExtent: ScreenUtil().setHeight(228),
                ),
                itemCount: logic.traceAssets.length,
                itemBuilder: (ctx, i) {
                  final path = logic.traceAssets[i];
                  final stem = path.split('/').last.split('.').first;
                  final pack = AssetsLogic.traceFolderLabel(path);
                  return Material(
                    color: AppTheme.surfaceDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().radius(14)),
                      side: BorderSide(
                        color: AppTheme.outlineDark.withValues(alpha: 0.65),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => logic.openTracePreview(context, path),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  path,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  cacheWidth: 400,
                                  filterQuality: FilterQuality.medium,
                                  errorBuilder: (c, e, _) => Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: AppTheme.onSurfaceVariantDark,
                                      size: ScreenUtil().setWidth(32),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: ScreenUtil().setWidth(8),
                                  top: ScreenUtil().setHeight(8),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: ScreenUtil().setWidth(8),
                                      vertical: ScreenUtil().setHeight(4),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black
                                          .withValues(alpha: 0.45),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (pack.isNotEmpty)
                                          Text(
                                            pack,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: ScreenUtil().setSp(10),
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white
                                                  .withValues(alpha: 0.9),
                                            ),
                                          ),
                                        Text(
                                          '#$stem',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: ScreenUtil().setSp(11),
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(10),
                              vertical: ScreenUtil().setHeight(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.touch_app_rounded,
                                  size: ScreenUtil().setWidth(16),
                                  color: AppTheme.primaryAccent,
                                ),
                                SizedBox(width: ScreenUtil().setWidth(6)),
                                Expanded(
                                  child: Text(
                                    Lang.assetsTraceStart,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(13),
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.onSurfaceDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
