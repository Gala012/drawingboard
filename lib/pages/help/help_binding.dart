import 'package:drawing_board/pages/help/help_logic.dart';
import 'package:get/get.dart';

class HelpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(HelpLogic.new);
  }
}
