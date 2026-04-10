import 'package:drawing_board/pages/canvas/canvas_logic.dart';
import 'package:get/get.dart';

class CanvasBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final id = args is Map ? args['id'] as int? : null;
    Get.lazyPut(() => CanvasLogic(projectId: id));
  }
}
