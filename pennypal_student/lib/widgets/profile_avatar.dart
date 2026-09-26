import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class ProfileAvatar extends StatelessWidget {
  final String fullName;
  final double size;

  const ProfileAvatar({super.key, required this.fullName, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textPrimary, width: 3),
      ),
      child: Text(
        Formatters.initials(fullName),
        style: TextStyle(fontFamily: AppFonts.heading, fontSize: size / 2.8, fontWeight: FontWeight.w800),
      ),
    );
  }
}
