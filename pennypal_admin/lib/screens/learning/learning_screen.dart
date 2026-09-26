import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/learning_content.dart';
import '../../services/learning_service.dart';
import '../../utils/admin_section.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/lesson_editor.dart';
import '../../widgets/confirm_dialog.dart';
import 'lesson_form_screen.dart';
import 'lesson_labels.dart';

/// Learning corner management: the admin adds, edits, hides or deletes the
/// bilingual lessons that students read in their app.
class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  late Stream<List<LearningContent>> _lessonStream;

  // Selected topic filter, null means all topics.
  String? _topic;

  @override
  void initState() {
    super.initState();
    _lessonStream = LearningService.watch();
  }

  /// Opens the lesson stream again after a loading error.
  void _retry() {
    setState(() {
      _lessonStream = LearningService.watch();
    });
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// Shows or hides a lesson for students without deleting it.
  Future<void> _setActive(LearningContent lesson, bool isActive) async {
    final l10n = AppLocalizations.of(context)!;
    final int now = DateTime.now().millisecondsSinceEpoch;
    final LearningContent changedLesson = LessonEditor.withActive(lesson, isActive, now);
    final bool isSaved = await LearningService.save(changedLesson);
    if (!mounted) return;

    if (!isSaved) {
      _showMessage(l10n.learningSaveFailed);
      return;
    }
    if (isActive) {
      _showMessage(l10n.learningShown(lesson.titleEn));
    } else {
      _showMessage(l10n.learningHiddenMessage(lesson.titleEn));
    }
  }

  /// Opens the form for a new lesson (no [lesson]) or an existing one, then saves the result.
  /// A new lesson gets its id here so the form does not need to know about Firebase.
  Future<void> _openForm({LearningContent? lesson}) async {
    final l10n = AppLocalizations.of(context)!;
    final String lessonId = lesson?.id ?? LearningService.newId();
    final LearningContent? edited = await Navigator.of(context).push<LearningContent>(
      MaterialPageRoute(builder: (context) => LessonFormScreen(lessonId: lessonId, initial: lesson)),
    );
    if (edited == null || !mounted) return;

    final bool isSaved = await LearningService.save(edited);
    if (!mounted) return;

    if (isSaved) {
      _showMessage(l10n.learningSaved);
    } else {
      _showMessage(l10n.learningSaveFailed);
    }
  }

  /// Deletes a lesson after the admin confirms; students lose it right away.
  Future<void> _delete(LearningContent lesson) async {
    final l10n = AppLocalizations.of(context)!;
    final bool confirmed = await showConfirmDialog(
      context,
      title: l10n.learningDeleteTitle,
      message: l10n.learningDeleteBody(lesson.titleEn),
      confirmLabel: l10n.commonDelete,
      isDestructive: true,
      icon: Icons.delete_outline,
    );
    if (!confirmed || !mounted) return;

    final bool isDeleted = await LearningService.delete(lesson.id);
    if (!mounted) return;

    if (isDeleted) {
      _showMessage(l10n.learningDeleted);
    } else {
      _showMessage(l10n.learningSaveFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<List<LearningContent>>(
      stream: _lessonStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _LoadError(message: l10n.learningLoadFailed, onRetry: _retry);
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildContent(l10n, snapshot.data!);
      },
    );
  }

  /// Topic chips, the add button, and the lessons as a table (tablet) or cards (phone).
  Widget _buildContent(AppLocalizations l10n, List<LearningContent> lessons) {
    final List<LearningContent> shown = LessonEditor.filter(lessons, _topic);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= AdminLayout.wideBreakpoint;

        final List<Widget> topicChips = [
          _TopicChip(label: l10n.learningAllTopics, isSelected: _topic == null, onTap: () => setState(() => _topic = null)),
        ];
        for (final String topic in LearningTopics.values) {
          topicChips.add(_TopicChip(
            label: LessonLabels.topic(l10n, topic),
            isSelected: _topic == topic,
            onTap: () => setState(() => _topic = topic),
          ));
        }

        final List<Widget> lessonCards = [];
        for (final LearningContent lesson in shown) {
          lessonCards.add(_LessonCard(
            lesson: lesson,
            onActiveChanged: (value) => _setActive(lesson, value),
            onEdit: () => _openForm(lesson: lesson),
            onDelete: () => _delete(lesson),
          ));
        }

        return ListView(
          padding: EdgeInsets.all(isWide ? 28 : 16),
          children: [
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: topicChips),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  tooltip: l10n.learningAdd,
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (shown.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.learningEmpty, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
                ),
              )
            else if (isWide)
              _buildTable(l10n, shown)
            else
              ...lessonCards,
          ],
        );
      },
    );
  }

  /// Tablet layout: one row per lesson with an Active switch and edit/delete buttons.
  Widget _buildTable(AppLocalizations l10n, List<LearningContent> shown) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          columns: [
            DataColumn(label: Text(l10n.learningTitleColumn)),
            DataColumn(label: Text(l10n.learningTopic)),
            DataColumn(label: Text(l10n.learningLevel)),
            DataColumn(label: Text(l10n.learningActive)),
            const DataColumn(label: SizedBox.shrink()),
          ],
          rows: shown.map((lesson) {
            return DataRow(cells: [
              DataCell(ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Text(lesson.titleEn, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
              )),
              DataCell(_Tag(text: LessonLabels.topic(l10n, lesson.topic), isTopic: true)),
              DataCell(_Tag(text: LessonLabels.level(l10n, lesson.level))),
              DataCell(Switch(value: lesson.isActive, onChanged: (value) => _setActive(lesson, value))),
              DataCell(_Actions(onEdit: () => _openForm(lesson: lesson), onDelete: () => _delete(lesson))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

/// Filter chip for one lesson topic.
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
        selectedColor: AppColors.textPrimary,
        labelStyle: TextStyle(fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.textPrimary),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

/// Small colored label for the topic or the level.
class _Tag extends StatelessWidget {
  final String text;
  final bool isTopic;

  const _Tag({required this.text, this.isTopic = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isTopic ? AppColors.infoSoft : AppColors.fill,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w600, color: isTopic ? AppColors.info : AppColors.textSecondary),
      ),
    );
  }
}

/// Edit and delete buttons of a lesson.
class _Actions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _Actions({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filled(
          style: IconButton.styleFrom(backgroundColor: AppColors.fill, foregroundColor: AppColors.textPrimary),
          tooltip: l10n.commonEdit,
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 20),
        ),
        const SizedBox(width: 6),
        IconButton.filled(
          style: IconButton.styleFrom(backgroundColor: AppColors.errorSoft, foregroundColor: AppColors.error),
          tooltip: l10n.commonDelete,
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 20),
        ),
      ],
    );
  }
}

/// Phone layout of one lesson; the switch shows or hides it for students.
class _LessonCard extends StatelessWidget {
  final LearningContent lesson;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LessonCard({required this.lesson, required this.onActiveChanged, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(lesson.titleEn, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
                Switch(value: lesson.isActive, onChanged: onActiveChanged),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Tag(text: LessonLabels.topic(l10n, lesson.topic), isTopic: true),
                _Tag(text: LessonLabels.level(l10n, lesson.level)),
              ],
            ),
            const Divider(height: 24, color: AppColors.border),
            Row(
              children: [
                Expanded(
                  child: Text(
                    lesson.isActive ? l10n.learningVisible : l10n.learningHidden,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: lesson.isActive ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ),
                _Actions(onEdit: onEdit, onDelete: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the lessons cannot be loaded, e.g. no connection or no permission.
class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
          ],
        ),
      ),
    );
  }
}
