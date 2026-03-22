import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';

class ExportService {
  /// 保存到相册
  static Future<bool> saveToGallery(Uint8List bytes) async {
    try {
      await Gal.putImageBytes(bytes);
      return true;
    } catch (e) {
      debugPrint("Save error: $e");
      return false;
    }
  }

  static Future<void> shareImage(Uint8List bytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/pro_badminton_share.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'My Badminton Match Record 🏸');
    } catch (e) {
      debugPrint("Share error: $e");
    }
  }
}

void debugPrint(String msg) => print("[Export] $msg");
