import 'dart:async';

import 'dart:convert';
import 'dart:ui' as ui;

import 'package:drawing_board/app/settings_storage.dart';
import 'package:drawing_board/db_drawing_board/db_drawing_board_helper.dart';
import 'package:drawing_board/drawing/document_model.dart';
import 'package:drawing_board/lang/lang.dart';
import 'package:drawing_board/pages/home/home_logic.dart';
import 'package:drawing_board/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AssetsLogic extends GetxController {
  static const _boxName = 'assets';
  static const _keyRecent = 'trace_recent';

  final traceAssets = <String>[].obs;
  final traceLoading = true.obs;
  final recentTracePaths = <String>[].obs;

  @override
  void onReady() {
    super.onReady();
    unawaited(_loadTraceManifest());
  }

  Future<List<String>> _collectTraceKeysFromBundle() async {
    try {
      final raw = await rootBundle.loadString('assets/trace/trace_manifest.json');
      final decoded = jsonDecode(raw);
      if (decoded is List && decoded.isNotEmpty) {
        return decoded.map((e) => e as String).toList();
      }
    } catch (_) {}
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final all = manifest.listAssets();
      if (all.isNotEmpty) {
        return all;
      }
    } catch (_) {}
    try {
      final s = await rootBundle.loadString('AssetManifest.json');
      final map = jsonDecode(s) as Map<String, dynamic>;
      return map.keys.toList();
    } catch (_) {}
    return [];
  }

  Future<void> _loadTraceManifest() async {
    traceLoading.value = true;
    try {
      final keys = await _collectTraceKeysFromBundle();
      final list = keys
          .where((k) => k.startsWith('assets/trace/'))
          .where((k) => !k.endsWith('trace_manifest.json'))
          .where((k) {
            if (k.contains('/.')) {
              return false;
            }
            final l = k.toLowerCase();
            return l.endsWith('.jpg') ||
                l.endsWith('.jpeg') ||
                l.endsWith('.png') ||
                l.endsWith('.webp');
          })
          .toList()
        ..sort(_traceAssetCompare);
      traceAssets.assignAll(list);
      _syncRecentWithManifest();
    } catch (_) {
      traceAssets.clear();
      recentTracePaths.clear();
    } finally {
      traceLoading.value = false;
    }
  }

  void _syncRecentWithManifest() {
    final raw = GetStorage(_boxName).read(_keyRecent);
    if (raw is! List) {
      recentTracePaths.clear();
      return;
    }
    final paths = raw
        .cast<String>()
        .where((p) => traceAssets.contains(p))
        .toList();
    recentTracePaths.assignAll(paths);
  }

  void _rememberTrace(String path) {
    var list = <String>[];
    final raw = GetStorage(_boxName).read(_keyRecent);
    if (raw is List) {
      list = raw.cast<String>().toList();
    }
    list.remove(path);
    list.insert(0, path);
    if (list.length > 10) {
      list = list.sublist(0, 10);
    }
    GetStorage(_boxName).write(_keyRecent, list);
    _syncRecentWithManifest();
  }

  int _traceAssetCompare(String a, String b) {
    final da = _traceSortKey(a);
    final db = _traceSortKey(b);
    final c = da.compareTo(db);
    if (c != 0) {
      return c;
    }
    final na = _numericStem(a);
    final nb = _numericStem(b);
    if (na != null && nb != null) {
      return na.compareTo(nb);
    }
    return a.compareTo(b);
  }

  String _traceSortKey(String assetPath) {
    final parts = assetPath.split('/');
    if (parts.length < 3) {
      return assetPath;
    }
    return parts.sublist(0, parts.length - 1).join('/');
  }

  static String traceFolderLabel(String assetPath) {
    final parts = assetPath.split('/');
    if (parts.length < 2) {
      return '';
    }
    final folder = parts[parts.length - 2];
    return folder.replaceAll('_', ' ');
  }

  int? _numericStem(String assetPath) {
    final name = assetPath.split('/').last;
    final stem = name.split('.').first;
    return int.tryParse(stem);
  }

  void openTracePreview(BuildContext context, String assetPath) {
    final cs = Theme.of(context).colorScheme;
    final stem = assetPath.split('/').last.split('.').first;
    final h = MediaQuery.sizeOf(context).height;
    Get.bottomSheet<void>(
      ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ScreenUtil().radius(24)),
        ),
        child: Container(
          color: cs.surfaceContainerHighest,
          constraints: BoxConstraints(maxHeight: h * 0.9),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                ScreenUtil().setWidth(20),
                ScreenUtil().setHeight(10),
                ScreenUtil().setWidth(20),
                ScreenUtil().setHeight(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: ScreenUtil().setWidth(40),
                      height: ScreenUtil().setHeight(4),
                      decoration: BoxDecoration(
                        color: AppTheme.outlineDark,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(16)),
                  Text(
                    Lang.assetsTracePreviewTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: ScreenUtil().setSp(20),
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurfaceDark,
                        ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(4)),
                  Text(
                    '#$stem · ${AssetsLogic.traceFolderLabel(assetPath)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(13),
                      color: AppTheme.onSurfaceVariantDark,
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(14)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(ScreenUtil().radius(14)),
                    child: ColoredBox(
                      color: AppTheme.surfaceDark,
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Image.asset(
                          assetPath,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          cacheWidth: 720,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(22)),
                  FilledButton(
                    onPressed: () {
                      Get.back<void>();
                      Future.microtask(
                        () => unawaited(openTraceLineart(assetPath)),
                      );
                    },
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setHeight(14),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ScreenUtil().radius(14),
                        ),
                      ),
                    ),
                    child: Text(
                      Lang.assetsTraceStart,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(8)),
                  TextButton(
                    onPressed: Get.back<void>,
                    child: Text(
                      Lang.canvasClose,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enterBottomSheetDuration: const Duration(milliseconds: 260),
      exitBottomSheetDuration: const Duration(milliseconds: 220),
    );
  }

  Future<void> openTraceLineart(String assetPath) async {
    _rememberTrace(assetPath);
    final bd = await rootBundle.load(assetPath);
    final codec =
        await ui.instantiateImageCodec(bd.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final iw = frame.image.width;
    final ih = frame.image.height;
    frame.image.dispose();

    final doc = DrawingDocument(
      canvasWidth: iw.toDouble(),
      canvasHeight: ih.toDouble(),
      backgroundColor:
          SettingsStorage.paperDark() ? 0xFF121214 : 0xFFF4F4F5,
    );
    doc.referenceImagePath = assetPath;
    doc.referenceImageOpacity = 0.42;
    doc.referenceFitContain = true;

    final base = assetPath.split('/').last.split('.').first;
    final pack = AssetsLogic.traceFolderLabel(assetPath);
    final title = pack.isEmpty
        ? '${Lang.assetsTraceSectionTitle} · $base'
        : '${Lang.assetsTraceSectionTitle} · $pack · $base';

    final id = await DbDrawingBoardHelper.instance.insertProject(
      title: title,
      doc: doc,
    );
    Get.toNamed('/canvas', arguments: {'id': id});
    if (Get.isRegistered<HomeLogic>()) {
      unawaited(Get.find<HomeLogic>().refreshHome());
    }
  }
}
