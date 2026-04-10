import 'package:drawing_board/lang/lang.dart';
import 'package:drawing_board/pages/assets/assets_view.dart';
import 'package:drawing_board/pages/home/home_view.dart';
import 'package:drawing_board/pages/main_shell/main_shell_logic.dart';
import 'package:drawing_board/pages/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MainShellView extends GetView<MainShellLogic> {
  const MainShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.tabIndex.value,
          children: const [
            HomeView(),
            AssetsView(),
            ProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: ScreenUtil().setHeight(64),
          selectedIndex: controller.tabIndex.value,
          onDestinationSelected: controller.setTab,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.brush_outlined, size: ScreenUtil().setWidth(24)),
              selectedIcon:
                  Icon(Icons.brush, size: ScreenUtil().setWidth(24)),
              label: Lang.tabCreate,
            ),
            NavigationDestination(
              icon: Icon(Icons.draw_outlined, size: ScreenUtil().setWidth(24)),
              selectedIcon: Icon(Icons.draw, size: ScreenUtil().setWidth(24)),
              label: Lang.tabAssets,
            ),
            NavigationDestination(
              icon:
                  Icon(Icons.person_outline, size: ScreenUtil().setWidth(24)),
              selectedIcon: Icon(Icons.person, size: ScreenUtil().setWidth(24)),
              label: Lang.tabProfile,
            ),
          ],
        ),
      ),
    );
  }
}
