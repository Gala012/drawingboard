import 'package:drawing_board/pages/guide/guide_logic.dart';
import 'package:get/get.dart';

class GuideBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(GuideLogic.new);
  }
}
