import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CsvExporter {
  static Future<bool> share(String fileName, String content) async {
    try {
      final Uint8List bytes = utf8.encode(content);

      // Web has no temp folder: the file is made in memory, and the browser downloads it when it can't share files.
      if (kIsWeb) {
        final XFile webFile = XFile.fromData(bytes, mimeType: 'text/csv', name: fileName);
        await Share.shareXFiles([webFile], subject: fileName, fileNameOverrides: [fileName]);
        return true;
      }

      final Directory folder = await getTemporaryDirectory();
      final File file = File('${folder.path}/$fileName');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path, mimeType: 'text/csv')], subject: fileName);
      return true;
    } catch (e) {
      debugPrint('CsvExporter.share failed: $e');
      return false;
    }
  }
}
