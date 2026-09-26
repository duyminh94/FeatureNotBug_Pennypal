import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CsvExporter {
  static Future<bool> share(String fileName, String content) async {
    try {
      final Directory folder = await getTemporaryDirectory();
      final File file = File('${folder.path}/$fileName');
      await file.writeAsBytes(utf8.encode(content));
      await Share.shareXFiles([XFile(file.path, mimeType: 'text/csv')], subject: fileName);
      return true;
    } catch (e) {
      debugPrint('CsvExporter.share failed: $e');
      return false;
    }
  }
}
