import 'package:drawing_board/db_drawing_board/db_drawing_board_helper.dart';
import 'package:get/get.dart';

class StatsLogic extends GetxController {
  final totalStrokes = 0.obs;
  final streakDays = 0.obs;
  final todayStrokes = 0.obs;
  final last7Strokes = 0.obs;
  final projectCount = 0.obs;
  final layerTotal = 0.obs;
  final traceProjectCount = 0.obs;
  final maxCanvasW = 0.obs;
  final maxCanvasH = 0.obs;
  final latestUpdatedMs = 0.obs;
  final heatmapCounts = <int>[].obs;
  final heatmax = 1.obs;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    totalStrokes.value =
        await DbDrawingBoardHelper.instance.totalStrokeCount();
    streakDays.value =
        await DbDrawingBoardHelper.instance.computeStreakDaysAsync();
    todayStrokes.value =
        await DbDrawingBoardHelper.instance.strokeCountForToday();
    last7Strokes.value =
        await DbDrawingBoardHelper.instance.strokeSumForLastDays(7);
    final table = await DbDrawingBoardHelper.instance.loadProjectTableAggregate();
    projectCount.value = table.projectCount;
    maxCanvasW.value = table.maxCanvasW;
    maxCanvasH.value = table.maxCanvasH;
    latestUpdatedMs.value = table.latestUpdatedAtMs;
    final docAgg =
        await DbDrawingBoardHelper.instance.loadDocumentAggregates();
    layerTotal.value = docAgg.totalLayerCount;
    traceProjectCount.value = docAgg.traceProjectCount;
    final now = DateTime.now();
    final keys = <String>[];
    for (var i = 13; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      keys.add(
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
      );
    }
    final map = await DbDrawingBoardHelper.instance.strokeCountsLastDays(14);
    final counts = <int>[];
    var mx = 1;
    for (final k in keys) {
      final n = map[k] ?? 0;
      counts.add(n);
      if (n > mx) {
        mx = n;
      }
    }
    heatmax.value = mx;
    heatmapCounts.assignAll(counts);
  }
}
