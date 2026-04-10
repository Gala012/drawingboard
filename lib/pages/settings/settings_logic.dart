import 'package:drawing_board/app/settings_storage.dart';
import 'package:get/get.dart';

class SettingsLogic extends GetxController {
  final stabilizer = true.obs;
  final stabilizerWindow = 3.obs;
  final bucketTol = 18.obs;
  final paperDark = false.obs;

  @override
  void onInit() {
    super.onInit();
    stabilizer.value = SettingsStorage.stabilizerOn();
    stabilizerWindow.value = SettingsStorage.stabilizerWindow();
    bucketTol.value = SettingsStorage.bucketTolerance();
    paperDark.value = SettingsStorage.paperDark();
  }

  void setStabilizer(bool v) {
    stabilizer.value = v;
    SettingsStorage.setStabilizerOn(v);
  }

  void setWindow(double v) {
    final i = v.round();
    stabilizerWindow.value = i;
    SettingsStorage.setStabilizerWindow(i);
  }

  void setBucketTol(double v) {
    final i = v.round();
    bucketTol.value = i;
    SettingsStorage.setBucketTolerance(i);
  }

  void setPaperDark(bool v) {
    paperDark.value = v;
    SettingsStorage.setPaperDark(v);
  }
}
