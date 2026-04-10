import 'package:get_storage/get_storage.dart';

class SettingsStorage {
  static const box = 'settings';
  static const keyStabilizer = 'stabilizer_on';
  static const keyStabilizerWindow = 'stabilizer_window';
  static const keyBucketTol = 'bucket_tolerance';
  static const keyPaperDark = 'paper_dark';

  static bool stabilizerOn() =>
      GetStorage(box).read(keyStabilizer) as bool? ?? true;

  static int stabilizerWindow() {
    final v = GetStorage(box).read(keyStabilizerWindow) as int?;
    if (v == null) {
      return 3;
    }
    return v.clamp(1, 7);
  }

  static int bucketTolerance() {
    final v = GetStorage(box).read(keyBucketTol) as int?;
    if (v == null) {
      return 18;
    }
    return v.clamp(0, 80);
  }

  static bool paperDark() =>
      GetStorage(box).read(keyPaperDark) as bool? ?? false;

  static void setStabilizerOn(bool v) =>
      GetStorage(box).write(keyStabilizer, v);

  static void setStabilizerWindow(int v) =>
      GetStorage(box).write(keyStabilizerWindow, v.clamp(1, 7));

  static void setBucketTolerance(int v) =>
      GetStorage(box).write(keyBucketTol, v.clamp(0, 80));

  static void setPaperDark(bool v) =>
      GetStorage(box).write(keyPaperDark, v);
}
