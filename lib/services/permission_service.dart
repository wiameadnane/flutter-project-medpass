import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Requests camera and storage permissions for scanning
  /// Returns true if both are granted
  static Future<bool> requestScanPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final storageStatus = await Permission.storage.request();

    if (cameraStatus.isGranted && storageStatus.isGranted) {
      return true;
    }

    // If permanently denied, open app settings
    if (cameraStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }
}
