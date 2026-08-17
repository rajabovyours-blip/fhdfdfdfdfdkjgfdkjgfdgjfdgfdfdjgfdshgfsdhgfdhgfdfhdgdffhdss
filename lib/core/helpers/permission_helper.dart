import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestCamera() async {
    return await Permission.camera.request().isGranted;
  }

  static Future<bool> requestStorage() async {
    return await Permission.storage.request().isGranted;
  }
}
