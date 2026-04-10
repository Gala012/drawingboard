import 'package:drawing_board/pages/assets/assets_logic.dart';
import 'package:drawing_board/pages/home/home_logic.dart';
import 'package:drawing_board/pages/main_shell/main_shell_logic.dart';
import 'package:drawing_board/pages/profile/profile_logic.dart';
import 'package:get/get.dart';

class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(MainShellLogic.new);
    Get.lazyPut(HomeLogic.new);
    Get.lazyPut(AssetsLogic.new);
    Get.lazyPut(ProfileLogic.new);
  }
}
