import 'package:drawing_board/db_drawing_board/db_drawing_board_helper.dart';
import 'package:drawing_board/pages/main_shell/main_shell_logic.dart';
import 'package:get/get.dart';

class HomeLogic extends GetxController {
  final projects = <ProjectRow>[].obs;
  final projectCount = 0.obs;
  final totalStrokes = 0.obs;

  @override
  void onReady() {
    super.onReady();
    refreshHome();
  }

  Future<void> refreshHome() async {
    await Future.wait([loadProjects(), loadSummary()]);
  }

  Future<void> loadProjects() async {
    final list = await DbDrawingBoardHelper.instance.listProjects();
    projects.assignAll(list);
  }

  Future<void> loadSummary() async {
    projectCount.value =
        await DbDrawingBoardHelper.instance.projectCount();
    totalStrokes.value =
        await DbDrawingBoardHelper.instance.totalStrokeCount();
  }

  void openNewCanvas() {
    Get.toNamed('/canvas');
  }

  void openProject(ProjectRow row) {
    Get.toNamed('/canvas', arguments: {'id': row.id});
  }

  void openFirstProject() {
    if (projects.isEmpty) {
      return;
    }
    openProject(projects.first);
  }

  void goTraceTab() {
    if (Get.isRegistered<MainShellLogic>()) {
      Get.find<MainShellLogic>().setTab(1);
    }
  }

  void openStats() => Get.toNamed('/stats');
  void openSettings() => Get.toNamed('/settings');

  Future<void> deleteProject(ProjectRow row) async {
    await DbDrawingBoardHelper.instance.deleteProject(row.id);
    await refreshHome();
  }
}
