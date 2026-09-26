import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/receipt_scan_result.dart';
import '../utils/receipt_parser.dart';
import '../utils/receipt_text_builder.dart';

/// Result of picking a receipt photo.
enum PickPhotoStatus { picked, cancelled, permissionDenied, failed }

class PickPhotoResult {
  final PickPhotoStatus status;
  final String? imagePath;

  const PickPhotoResult(this.status, [this.imagePath]);
}

/// Takes or picks a receipt photo, keeps it on the phone and reads it with ML Kit (BR-90 to BR-97).
class ReceiptScanService {
  static const Set<String> _deniedCodes = {'camera_access_denied', 'photo_access_denied'};

  /// Receipt scan uses ML Kit, which does not run on Web (A-13).
  static bool get isSupported => !kIsWeb;

  static Future<PickPhotoResult> pickPhoto(ImageSource source) async {
    try {
      final XFile? photo = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 85);
      if (photo == null) return const PickPhotoResult(PickPhotoStatus.cancelled);
      final String savedPath = await _copyToAppFolder(photo);
      return PickPhotoResult(PickPhotoStatus.picked, savedPath);
    } on PlatformException catch (e) {
      debugPrint('ReceiptScanService.pickPhoto failed: ${e.code} ${e.message}');
      final bool isDenied = _deniedCodes.contains(e.code);
      return PickPhotoResult(isDenied ? PickPhotoStatus.permissionDenied : PickPhotoStatus.failed);
    } catch (e) {
      debugPrint('ReceiptScanService.pickPhoto failed: $e');
      return const PickPhotoResult(PickPhotoStatus.failed);
    }
  }

  /// BR-97: the photo lives in the app folder on this phone only.
  static Future<String> _copyToAppFolder(XFile photo) async {
    final Directory documents = await getApplicationDocumentsDirectory();
    final Directory receiptFolder = Directory('${documents.path}/receipts');
    if (!await receiptFolder.exists()) await receiptFolder.create(recursive: true);
    final String targetPath = '${receiptFolder.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await photo.saveTo(targetPath);
    return targetPath;
  }

  /// Reads the photo with ML Kit; a reading error counts as "no text" so the form still works (BR-96).
  static Future<ReceiptScanResult> readReceipt(String imagePath) async {
    final TextRecognizer recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final RecognizedText recognized = await recognizer.processImage(InputImage.fromFilePath(imagePath));
      final List<TextLinePosition> lines = [
        for (final TextBlock block in recognized.blocks)
          for (final TextLine line in block.lines)
            TextLinePosition(
              text: line.text,
              top: line.boundingBox.top,
              bottom: line.boundingBox.bottom,
              left: line.boundingBox.left,
            ),
      ];
      return ReceiptParser.parse(ReceiptTextBuilder.buildRows(lines)).withImagePath(imagePath);
    } catch (e) {
      debugPrint('ReceiptScanService.readReceipt failed: $e');
      return ReceiptScanResult(hasText: false, date: DateTime.now(), imagePath: imagePath);
    } finally {
      await recognizer.close();
    }
  }

  /// Removes a receipt photo that the student no longer wants.
  static Future<void> deletePhoto(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('ReceiptScanService.deletePhoto failed: $e');
    }
  }
}
