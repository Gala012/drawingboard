import 'package:drawing_board/pages/stats/stats_logic.dart';
import 'package:get/get.dart';

class StatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(StatsLogic.new);
  }
}
