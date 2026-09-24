import 'package:flutter/material.dart';

/// Dashboard card with an icon, a title and a big value text.
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color mainColor = color ?? Theme.of(context).colorScheme.primary;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: mainColor),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: textTheme.titleSmall)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(color: mainColor),
            ),
          ],
        ),
      ),
    );
  }
}
