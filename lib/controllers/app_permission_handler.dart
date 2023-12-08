import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// Permission Handler Camera
class CameraPermissionHandler {
  static Future<void> handleCameraPermission(BuildContext context, Function onSuccess) async {
    final messanger = ScaffoldMessenger.of(context);
    PermissionStatus status = await Permission.camera.request();

    if (status == PermissionStatus.granted) {
      onSuccess();
    } else if (status == PermissionStatus.denied) {
      messanger.showSnackBar(SnackBar(
        content: const Text('Cannot Access Camera'),
        action: SnackBarAction(
          label: 'Open App Settings',
          onPressed: () {
            openAppSettings();
          },
        ),
      ));
    } else if (status == PermissionStatus.limited) {
      debugPrint('Permission is Limited');
    } else if (status == PermissionStatus.restricted) {
      messanger.showSnackBar(SnackBar(
        content: const Text('Allow us to use Camera'),
        action: SnackBarAction(
          label: 'Open App Settings',
          onPressed: () {
            openAppSettings();
          },
        ),
      ));
    } else if (status == PermissionStatus.permanentlyDenied) {
      messanger.showSnackBar(SnackBar(
        content: const Text('Cannot use Camera'),
        action: SnackBarAction(
          label: 'Open App Settings',
          onPressed: () {
            openAppSettings();
          },
        ),
      ));
    }
  }
}

// Permission Handler Storage
class StoragePermissionHandler {
  static Future<void> handleStoragePermission(BuildContext context, Function onSuccess) async {
    final messanger = ScaffoldMessenger.of(context);
    PermissionStatus status = await Permission.storage.request();

    if (status == PermissionStatus.granted) {
      onSuccess();
    } else if (status == PermissionStatus.denied) {
      messanger.showSnackBar(SnackBar(
        content: const Text('Cannot Access Storage'),
        action: SnackBarAction(
          label: 'Open App Settings',
          onPressed: () {
            openAppSettings();
          },
        ),
      ));
    } else if (status == PermissionStatus.limited) {
      debugPrint('Permission is Limited');
    } else if (status == PermissionStatus.restricted) {
      messanger.showSnackBar(SnackBar(
        content: const Text('Allow us to use Storage'),
        action: SnackBarAction(
          label: 'Open App Settings',
          onPressed: () {
            openAppSettings();
          },
        ),
      ));
    } else if (status == PermissionStatus.permanentlyDenied) {
      messanger.showSnackBar(SnackBar(
        content: const Text('Cannot use Storage'),
        action: SnackBarAction(
          label: 'Open App Settings',
          onPressed: () {
            openAppSettings();
          },
        ),
      ));
    }
  }
}