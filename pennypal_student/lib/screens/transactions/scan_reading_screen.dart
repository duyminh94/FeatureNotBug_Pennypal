import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/receipt_scan_result.dart';
import '../../controllers/receipt_scan_service.dart';
import '../../utils/app_theme.dart';

class ScanReadingScreen extends StatefulWidget {
  final String imagePath;

  const ScanReadingScreen({super.key, required this.imagePath});

  @override
  State<ScanReadingScreen> createState() => _ScanReadingScreenState();
}

class _ScanReadingScreenState extends State<ScanReadingScreen> {
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _read();
  }

  Future<void> _read() async {
    final ReceiptScanResult result = await ReceiptScanService.readReceipt(widget.imagePath);
    if (!mounted || _isCancelled) return;
    Navigator.of(context).pop(result);
  }

  void _cancel() {
    _isCancelled = true;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 48, 40, 24),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.mint, width: 3),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(99)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Text(l10n.scanReading, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54, width: 1.5),
                minimumSize: const Size(120, 48),
              ),
              onPressed: _cancel,
              child: Text(l10n.commonCancel),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
