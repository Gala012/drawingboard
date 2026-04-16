import 'package:drawing_board/app/app_keys.dart';
import 'package:drawing_board/app/settings_storage.dart';
import 'package:drawing_board/db_drawing_board/db_drawing_board_helper.dart';
import 'package:drawing_board/lang/lang.dart';
import 'package:drawing_board/pages/about/about_binding.dart';
import 'package:drawing_board/pages/about/about_view.dart';
import 'package:drawing_board/pages/canvas/canvas_binding.dart';
import 'package:drawing_board/pages/canvas/canvas_view.dart';
import 'package:drawing_board/pages/guide/guide_binding.dart';
import 'package:drawing_board/pages/guide/guide_view.dart';
import 'package:drawing_board/pages/handel/handel_binding.dart';
import 'package:drawing_board/pages/handel/handel_view.dart';
import 'package:drawing_board/pages/help/help_binding.dart';
import 'package:drawing_board/pages/help/help_feedback.dart';
import 'package:drawing_board/pages/help/help_view.dart';
import 'package:drawing_board/pages/main_shell/main_shell_binding.dart';
import 'package:drawing_board/pages/main_shell/main_shell_view.dart';
import 'package:drawing_board/pages/settings/settings_binding.dart';
import 'package:drawing_board/pages/settings/settings_view.dart';
import 'package:drawing_board/pages/stats/stats_binding.dart';
import 'package:drawing_board/pages/stats/stats_view.dart';
import 'package:drawing_board/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await GetStorage.init(SettingsStorage.box);
  await GetStorage.init('assets');
  await DbDrawingBoardHelper.instance.database;
  final seen = GetStorage().read(AppKeys.hasSeenGuide) == true;
  final start = seen ? '/main' : '/guide';
  runApp(DrawingBoardApp(initialRoute: start));
}

class DrawingBoardApp extends StatelessWidget {
  const DrawingBoardApp({required this.initialRoute, super.key});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          title: Lang.appName,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          getPages: CanvasD,
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 220),
        );
      },
    );
  }
}
List<GetPage<dynamic>> CanvasD = [
  GetPage(
    name: '/',
    page: () => const HandelView(),
    binding: HandelBinding(),
  ),
  GetPage(
    name: '/guide',
    page: () => const GuideView(),
    binding: GuideBinding(),
  ),
  GetPage(
    name: '/main',
    page: () => const MainShellView(),
    binding: MainShellBinding(),
  ),
  GetPage(
    name: '/canvas',
    page: () => const CanvasView(),
    binding: CanvasBinding(),
  ),
  GetPage(
    name: '/feedback',
    page: () => const HelpFeedback(),
  ),
  GetPage(
    name: '/stats',
    page: () => const StatsView(),
    binding: StatsBinding(),
  ),
  GetPage(
    name: '/settings',
    page: () => const SettingsView(),
    binding: SettingsBinding(),
  ),
  GetPage(
    name: '/help',
    page: () => const HelpView(),
    binding: HelpBinding(),
  ),
  GetPage(
    name: '/about',
    page: () => const AboutView(),
    binding: AboutBinding(),
  ),
];