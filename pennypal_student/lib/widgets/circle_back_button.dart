import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/app_theme.dart';

/// White round back button used at the top of full-screen forms.
class CircleBackButton extends StatelessWidget {
  const CircleBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: const Color(0x331F1A24),
      child: IconButton(
        tooltip: AppLocalizations.of(context)!.commonBack,
        icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}
