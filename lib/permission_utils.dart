import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  /// 检查并申请相册权限
  static Future<bool> requestPhotoLibrary(BuildContext context) async {
    final status = await Permission.photos.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.photos.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermissionSettingsDialog(
          context,
          title: "需要相册权限",
          content: "保存比分截图需要访问相册，请在设置中开启权限。",
        );
      }
      return false;
    }

    return false;
  }

  /// 打开系统设置弹窗
  static Future<void> _showPermissionSettingsDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(ctx);
            },
            child: const Text("去设置"),
          ),
        ],
      ),
    );
  }
}