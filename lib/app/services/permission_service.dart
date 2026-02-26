import 'package:permission_handler/permission_handler.dart';

/// Handles all runtime permission logic
class PermissionService {
  /// Ensures both camera and mic permissions are granted
  static Future<bool> ensureCameraAndMic() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    return statuses[Permission.camera]?.isGranted == true &&
        statuses[Permission.microphone]?.isGranted == true;
  }

  /// Ensures gallery access across iOS and Android 13+ compatibility
  static Future<bool> ensureGallery() async {
    final photos = await Permission.photos.request();
    if (photos.isGranted) return true;

    // Fallback for older Android versions
    final storage = await Permission.storage.request();
    return storage.isGranted;
  }
}
