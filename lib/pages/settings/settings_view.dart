import 'package:drawing_board/lang/lang.dart';
import 'package:drawing_board/pages/settings/settings_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SettingsView extends GetView<SettingsLogic> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Lang.settingsTitle,
          style: TextStyle(fontSize: ScreenUtil().setSp(18)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        children: [
          Obx(
            () => SwitchListTile(
              title: Text(
                Lang.settingsStabilizer,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              value: controller.stabilizer.value,
              onChanged: controller.setStabilizer,
            ),
          ),
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Lang.settingsStabilizerWindow,
                  style: TextStyle(fontSize: ScreenUtil().setSp(14)),
                ),
                Slider(
                  value: controller.stabilizerWindow.value.toDouble(),
                  min: 1,
                  max: 7,
                  divisions: 6,
                  label: '${controller.stabilizerWindow.value}',
                  onChanged: controller.setWindow,
                ),
              ],
            ),
          ),
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Lang.settingsBucketTol,
                  style: TextStyle(fontSize: ScreenUtil().setSp(14)),
                ),
                Slider(
                  value: controller.bucketTol.value.toDouble(),
                  min: 0,
                  max: 80,
                  divisions: 80,
                  label: '${controller.bucketTol.value}',
                  onChanged: controller.setBucketTol,
                ),
              ],
            ),
          ),
          Obx(
            () => SwitchListTile(
              title: Text(
                Lang.settingsPaperDark,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                Lang.settingsPaperDarkHint,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: ScreenUtil().setSp(12)),
              ),
              value: controller.paperDark.value,
              onChanged: controller.setPaperDark,
            ),
          ),
        ],
      ),
    );
  }
}
