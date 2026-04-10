import 'package:drawing_board/pages/about/about_logic.dart';
import 'package:get/get.dart';

class AboutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(AboutLogic.new);
  }
}
