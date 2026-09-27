import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/learning_content.dart';
import '../../services/learning_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/category_display.dart';
import '../../utils/constants.dart';
import '../../utils/learning_filter.dart';
import '../../utils/sample_lessons.dart';
import '../../widgets/empty_state.dart';
import 'learning_detail_screen.dart';
import 'learning_widgets.dart';

class LearningScreen extends StatefulWidget {
  final List<LearningContent>? lessons;

  const LearningScreen({super.key, this.lessons});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  late final Stream<List<LearningContent>> _lessonsStream = LearningService.watch();
  String? _topic;

  void _openLesson(LearningContent lesson) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => LearningDetailScreen(lesson: lesson)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.lessons != null) {
      return _buildScaffold(l10n, widget.lessons!);
    }

    return StreamBuilder<List<LearningContent>>(
      stream: _lessonsStream,
      initialData: SampleLessons.all(),
      builder: (context, snapshot) {
        final List<LearningContent> lessons = snapshot.data ?? SampleLessons.all();
        return _buildScaffold(l10n, lessons);
      },
    );
  }

  Widget _buildScaffold(AppLocalizations l10n, List<LearningContent> lessons) {
    final List<LearningContent> allVisible = LearningFilter.visible(lessons);
    final List<LearningContent> shown = LearningFilter.visible(lessons, topic: _topic);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.menuLearning, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: allVisible.isEmpty
          ? EmptyState(icon: Icons.menu_book_outlined, message: l10n.learningEmpty)
          : Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Row(
                    children: [
                      _TopicChip(label: l10n.learningAll, isSelected: _topic == null, onTap: () => setState(() => _topic = null)),
                      ...LearningTopics.values.map((topic) => _TopicChip(
                            label: LearningDisplay.topicName(l10n, topic),
                            isSelected: _topic == topic,
                            onTap: () => setState(() => _topic = topic),
                          )),
                    ],
                  ),
                ),
                Expanded(
                  child: shown.isEmpty
                      ? EmptyState(icon: Icons.menu_book_outlined, message: l10n.learningEmptyTopic)
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          children: shown
                              .map((lesson) => _LessonCard(lesson: lesson, onTap: () => _openLesson(lesson)))
                              .toList(),
                        ),
                ),
              ],
            ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TopicChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        labelStyle: TextStyle(fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.textPrimary),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final LearningContent lesson;
  final VoidCallback onTap;

  const _LessonCard({required this.lesson, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String languageCode = Localizations.localeOf(context).languageCode;
    final String body = lesson.bodyFor(languageCode);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 120,
              color: LearningDisplay.topicSoftColor(lesson.topic),
              child: Stack(
                children: [
                  Positioned(
                    left: 12,
                    top: 12,
                    child: LearningTag(
                      text: LearningDisplay.topicName(l10n, lesson.topic),
                      background: AppColors.surface,
                      foreground: AppColors.textPrimary,
                    ),
                  ),
                  Center(
                    child: Icon(LearningDisplay.topicIcon(lesson.topic), size: 56, color: LearningDisplay.topicColor(lesson.topic)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.titleFor(languageCode),
                    style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 19, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      LevelTag(text: LearningDisplay.levelName(l10n, lesson.level)),
                      const SizedBox(width: 10),
                      Text(
                        l10n.learningMinutes(LearningFilter.readingMinutes(body)),
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
