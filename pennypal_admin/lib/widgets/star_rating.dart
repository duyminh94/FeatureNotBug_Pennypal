import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/app_theme.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;

  const StarRating({super.key, required this.rating, this.size = 20});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final int filled = rating.round();

    return Semantics(
      container: true,
      label: l10n.feedbackRatingLabel(filled),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int star = 1; star <= 5; star++)
              Icon(star <= filled ? Icons.star_rounded : Icons.star_outline_rounded, size: size, color: AppColors.star),
          ],
        ),
      ),
    );
  }
}
