import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/app_theme.dart';
import '../utils/pager.dart';

class PageControls extends StatelessWidget {
  final int pageIndex;
  final int total;
  final ValueChanged<int> onPageChanged;

  const PageControls({super.key, required this.pageIndex, required this.total, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final int pageCount = Pager.pageCount(total);
    final int from = pageIndex * Pager.pageSize + 1;
    int to = from + Pager.pageSize - 1;
    if (to > total) to = total;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(l10n.commonShowing(from, to, total), style: const TextStyle(color: AppColors.textSecondary)),
          ),
          IconButton.outlined(
            tooltip: l10n.commonPrevious,
            onPressed: pageIndex == 0 ? null : () => onPageChanged(pageIndex - 1),
            icon: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 8),
          IconButton.outlined(
            tooltip: l10n.commonNext,
            onPressed: pageIndex >= pageCount - 1 ? null : () => onPageChanged(pageIndex + 1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
