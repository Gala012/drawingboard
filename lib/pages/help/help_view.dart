import 'package:drawing_board/lang/lang.dart';
import 'package:drawing_board/pages/help/help_logic.dart';
import 'package:drawing_board/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HelpView extends GetView<HelpLogic> {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Lang.helpTitle,
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
            _enP(tt, Lang.helpBodyP1),
            SizedBox(height: ScreenUtil().setHeight(16)),
            _enP(tt, Lang.helpBodyP2),
            SizedBox(height: ScreenUtil().setHeight(16)),
            _enP(tt, Lang.helpBodyP3),
            SizedBox(height: ScreenUtil().setHeight(16)),
            _enP(tt, Lang.helpBodyP4),
          ],
        ),
      ),
    );
  }

  Widget _enP(TextTheme tt, String text) {
    return Text(
      text,
      style: tt.bodyLarge?.copyWith(
        fontSize: ScreenUtil().setSp(15),
        color: AppTheme.onSurfaceDark,
        height: 1.5,
      ),
    );
  }
}
