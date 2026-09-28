import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/learning_content.dart';
import '../../utils/app_theme.dart';
import '../../utils/category_display.dart';
import '../../utils/constants.dart';
import '../../utils/learning_filter.dart';
import 'widgets.dart';

class LearningDetailScreen extends StatelessWidget {
  final LearningContent lesson;

  const LearningDetailScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String languageCode = Localizations.localeOf(context).languageCode;
    final String body = lesson.bodyFor(languageCode);
    final Color topicColor = LearningDisplay.topicColor(lesson.topic);
    final String? imageUrl = lesson.imageUrl;

    return Scaffold(
      appBar: AppBar(backgroundColor: LearningDisplay.topicSoftColor(lesson.topic)),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: LearningDisplay.topicSoftColor(lesson.topic),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Stack(
              children: [
                Center(
                  child: imageUrl == null || imageUrl.isEmpty
                      ? Icon(LearningDisplay.topicIcon(lesson.topic), size: 96, color: topicColor)
                      : Image.network(
                          imageUrl,
                          height: 160,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(LearningDisplay.topicIcon(lesson.topic), size: 96, color: topicColor),
                        ),
                ),
                Positioned(right: 16, bottom: 0, child: Image.asset(AppAssets.pig, height: 90)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    LearningTag(
                      text: LearningDisplay.topicName(l10n, lesson.topic),
                      background: LearningDisplay.topicSoftColor(lesson.topic),
                      foreground: topicColor,
                    ),
                    LevelTag(text: LearningDisplay.levelName(l10n, lesson.level)),
                    Text(
                      l10n.learningMinutes(LearningFilter.readingMinutes(body)),
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  lesson.titleFor(languageCode),
                  style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 26, fontWeight: FontWeight.w800, height: 1.2),
                ),
                const SizedBox(height: 12),
                ...LearningFilter.paragraphs(body).map((paragraph) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(paragraph, style: const TextStyle(fontSize: 17, height: 1.5)),
                    )),
                const SizedBox(height: 8),
                Text(
                  l10n.learningDisclaimer,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
