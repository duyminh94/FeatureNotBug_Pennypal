import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

/// Bottom sheet "Scan receipt": camera or gallery. Returns null when cancelled.
Future<ImageSource?> showScanSourceSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    builder: (sheetContext) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.txScanReceipt, style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(l10n.scanSheetBody, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                _SourceOption(
                  icon: Icons.photo_camera_outlined,
                  color: AppColors.primary,
                  background: AppColors.mintSoft,
                  title: l10n.scanFromCamera,
                  subtitle: l10n.scanFromCameraHint,
                  onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
                ),
                const SizedBox(height: 10),
                _SourceOption(
                  icon: Icons.photo_library_outlined,
                  color: AppColors.info,
                  background: AppColors.infoSoft,
                  title: l10n.scanFromGallery,
                  subtitle: l10n.scanFromGalleryHint,
                  onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border, width: 1.5)),
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(l10n.commonCancel),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// What the student chose after the camera permission was refused.
enum PermissionChoice { gallery, manual }

/// Bottom sheet shown when camera access is refused; the form keeps working by hand.
Future<PermissionChoice?> showCameraPermissionSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return showModalBottomSheet<PermissionChoice>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    builder: (sheetContext) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: AppColors.expenseSoft, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.no_photography_outlined, color: AppColors.expense, size: 30),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.scanPermissionDenied,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.scanPermissionBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(PermissionChoice.gallery),
                  child: Text(l10n.scanFromGallery),
                ),
                const SizedBox(height: 8),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: AppColors.textPrimary),
                  onPressed: () => Navigator.of(sheetContext).pop(PermissionChoice.manual),
                  child: Text(l10n.scanEnterManually),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Receipt thumbnail card: tap to see it full screen, bin button to remove it.
class ReceiptPhotoCard extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRemove;

  const ReceiptPhotoCard({super.key, required this.imagePath, required this.onRemove});

  void _showFullPhoto(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(child: Image.file(File(imagePath), fit: BoxFit.contain)),
            Positioned(
              right: 4,
              top: 4,
              child: IconButton(
                tooltip: MaterialLocalizations.of(dialogContext).closeButtonTooltip,
                color: Colors.white,
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showFullPhoto(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(imagePath),
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 52,
                    height: 52,
                    color: AppColors.fill,
                    child: const Icon(Icons.receipt_long_outlined, color: AppColors.textMuted),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.receiptPhoto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text(l10n.receiptPhotoHint, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  ],
                ),
              ),
              IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: AppColors.expenseSoft, foregroundColor: AppColors.expense),
                tooltip: l10n.receiptRemove,
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Which banner the form shows after a scan.
enum ScanNoticeType { none, filled, noText, noAmount }

/// Banner at the top of the form after a scan (BR-96).
class ScanNotice extends StatelessWidget {
  final ScanNoticeType type;

  const ScanNotice({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return switch (type) {
      ScanNoticeType.filled => _NoticeBox(
          background: AppColors.honeySoft,
          leading: const Icon(Icons.auto_awesome, color: AppColors.honeyText, size: 20),
          title: l10n.scanFilledHint,
        ),
      ScanNoticeType.noText => _NoticeBox(
          background: AppColors.expenseSoft,
          leading: Image.asset(AppAssets.pig, width: 44, height: 40, fit: BoxFit.cover),
          title: l10n.scanNoText,
          titleColor: AppColors.expense,
          body: l10n.scanNoTextBody,
        ),
      ScanNoticeType.noAmount => _NoticeBox(
          background: AppColors.honeySoft,
          leading: const Icon(Icons.warning_amber_rounded, color: AppColors.honeyText, size: 20),
          title: l10n.scanNoAmount,
          body: l10n.scanNoAmountBody,
        ),
      ScanNoticeType.none => const SizedBox.shrink(),
    };
  }
}

class _NoticeBox extends StatelessWidget {
  final Color background;
  final Widget leading;
  final String title;
  final Color titleColor;
  final String? body;

  const _NoticeBox({
    required this.background,
    required this.leading,
    required this.title,
    this.titleColor = AppColors.textPrimary,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: titleColor)),
                if (body != null) Text(body!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
