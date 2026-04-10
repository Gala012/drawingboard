import 'package:drawing_board/pages/settings/settings_logic.dart';
import 'package:get/get.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(SettingsLogic.new);
  }
}
