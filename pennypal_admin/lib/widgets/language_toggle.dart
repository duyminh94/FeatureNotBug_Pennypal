import 'package:flutter/material.dart';

import '../services/locale_service.dart';
import '../utils/app_theme.dart';

/// Small EN / VI pill switch shown on the login screen.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentCode = Localizations.localeOf(context).languageCode;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption('en', 'EN', currentCode),
          _buildOption('vi', 'VI', currentCode),
        ],
      ),
    );
  }

  Widget _buildOption(String code, String text, String currentCode) {
    final bool isSelected = code == currentCode;

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: () => LocaleService.change(code),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(99),
            boxShadow: isSelected
                ? const [BoxShadow(color: Color(0x1A1F1A24), blurRadius: 6, offset: Offset(0, 2))]
                : null,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
