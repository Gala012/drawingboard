import 'package:drawing_board/db_drawing_board/db_drawing_board_helper.dart';
import 'package:get/get.dart';

class ProfileLogic extends GetxController {
  final projectCount = 0.obs;
  final totalStrokes = 0.obs;
  final streakDays = 0.obs;
  final summaryLoading = true.obs;

  @override
  void onReady() {
    super.onReady();
    refreshSummary();
  }

  Future<void> refreshSummary() async {
    summaryLoading.value = true;
    try {
      final db = DbDrawingBoardHelper.instance;
      projectCount.value = await db.projectCount();
      totalStrokes.value = await db.totalStrokeCount();
      streakDays.value = await db.computeStreakDaysAsync();
    } finally {
      summaryLoading.value = false;
    }
  }

  Future<void> openStats() async {
    await Get.toNamed('/stats');
    await refreshSummary();
  }
  void openSettings() => Get.toNamed('/settings');
  void openHelp() => Get.toNamed('/help');
  void openAbout() => Get.toNamed('/about');
}
