import 'package:get/get.dart';

import 'handel_logic.dart';

class HandelBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      HandelLogic(),
      permanent: true,
    );
  }
}
