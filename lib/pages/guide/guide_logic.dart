import 'package:drawing_board/app/app_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class GuideLogic extends GetxController {
  final PageController pageController = PageController();
  final currentPage = 0.obs;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void skip() {
    _complete();
  }

  void next() {
    if (currentPage.value < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    } else {
      _complete();
    }
  }

  void _complete() {
    GetStorage().write(AppKeys.hasSeenGuide, true);
    Get.offAllNamed('/main');
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
