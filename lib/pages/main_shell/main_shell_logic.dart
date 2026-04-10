import 'package:drawing_board/pages/home/home_logic.dart';
import 'package:drawing_board/pages/profile/profile_logic.dart';
import 'package:get/get.dart';

class MainShellLogic extends GetxController {
  final tabIndex = 0.obs;

  void setTab(int index) {
    tabIndex.value = index;
    if (index == 0 && Get.isRegistered<HomeLogic>()) {
      Get.find<HomeLogic>().refreshHome();
    }
    if (index == 2 && Get.isRegistered<ProfileLogic>()) {
      Get.find<ProfileLogic>().refreshSummary();
    }
  }
}
