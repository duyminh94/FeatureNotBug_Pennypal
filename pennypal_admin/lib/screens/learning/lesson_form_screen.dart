import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/learning_content.dart';
import '../../controllers/learning_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/lesson_editor.dart';
import 'lesson_labels.dart';

class LessonFormScreen extends StatefulWidget {
  final String lessonId;

  final LearningContent? initial;

  final Future<bool> Function(LearningContent lesson) saveLesson;

  const LessonFormScreen({super.key, required this.lessonId, this.initial, this.saveLesson = LearningService.save});

  @override
  State<LessonFormScreen> createState() => _LessonFormScreenState();
}

class _LessonFormScreenState extends State<LessonFormScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _titleEnController = TextEditingController();
  final TextEditingController _bodyEnController = TextEditingController();
  final TextEditingController _titleViController = TextEditingController();
  final TextEditingController _bodyViController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  String _topic = LearningTopics.budgeting;
  String _level = LearningLevels.beginner;
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    final LearningContent? lesson = widget.initial;
    if (lesson != null) {
      _titleEnController.text = lesson.titleEn;
      _bodyEnController.text = lesson.bodyEn;
      _titleViController.text = lesson.titleVi;
      _bodyViController.text = lesson.bodyVi;
      _imageUrlController.text = lesson.imageUrl ?? '';
      if (LearningTopics.values.contains(lesson.topic)) _topic = lesson.topic;
      if (LearningLevels.values.contains(lesson.level)) _level = lesson.level;
      _isActive = lesson.isActive;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleEnController.dispose();
    _bodyEnController.dispose();
    _titleViController.dispose();
    _bodyViController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  List<LessonLanguage> get _missing => LessonEditor.missingLanguages(
        titleEn: _titleEnController.text,
        bodyEn: _bodyEnController.text,
        titleVi: _titleViController.text,
        bodyVi: _bodyViController.text,
      );

  bool get _isImageUrlValid => LessonEditor.isValidImageUrl(_imageUrlController.text);

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final LearningContent? initial = widget.initial;
    final int now = DateTime.now().millisecondsSinceEpoch;
    final String imageUrl = _imageUrlController.text.trim();

    final LearningContent lesson = LearningContent(
      id: widget.lessonId,
      titleEn: _titleEnController.text.trim(),
      titleVi: _titleViController.text.trim(),
      bodyEn: _bodyEnController.text.trim(),
      bodyVi: _bodyViController.text.trim(),
      topic: _topic,
      level: _level,
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
      isActive: _isActive,
      createdAt: initial?.createdAt ?? now,
      updatedAt: now,
    );

    setState(() {
      _isSaving = true;
    });
    final bool isSaved = await widget.saveLesson(lesson);
    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });
    if (isSaved) {
      Navigator.of(context).pop(true);
      return;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.learningSaveFailed)));
  }

  String _missingMessage(AppLocalizations l10n, List<LessonLanguage> missing) {
    if (missing.length == 2) return l10n.learningMissingBoth;
    return missing.first == LessonLanguage.en ? l10n.learningMissingEn : l10n.learningMissingVi;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<LessonLanguage> missing = _missing;
    final bool canSave = missing.isEmpty && _isImageUrlValid;
    final bool isEnglishTab = _tabController.index == 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.commonClose,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(widget.initial == null ? l10n.learningNew : l10n.learningEdit, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primary,
                        indicatorColor: AppColors.primary,
                        tabs: [
                          _LanguageTab(label: 'English', isMissing: missing.contains(LessonLanguage.en)),
                          _LanguageTab(label: 'Tiếng Việt', isMissing: missing.contains(LessonLanguage.vi)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _Label(text: isEnglishTab ? l10n.learningTitleEn : l10n.learningTitleVi),
                      TextField(
                        key: ValueKey(isEnglishTab ? 'title_en' : 'title_vi'),
                        controller: isEnglishTab ? _titleEnController : _titleViController,
                        maxLength: LessonEditor.titleMaxLength,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 8),
                      _Label(text: isEnglishTab ? l10n.learningBodyEn : l10n.learningBodyVi),
                      TextField(
                        key: ValueKey(isEnglishTab ? 'body_en' : 'body_vi'),
                        controller: isEnglishTab ? _bodyEnController : _bodyViController,
                        minLines: 6,
                        maxLines: 12,
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Label(text: l10n.learningTopic),
                      DropdownButtonFormField<String>(
                        value: _topic,
                        items: LearningTopics.values
                            .map((topic) => DropdownMenuItem(value: topic, child: Text(LessonLabels.topic(l10n, topic))))
                            .toList(),
                        onChanged: (value) => setState(() => _topic = value ?? _topic),
                      ),
                      const SizedBox(height: 16),
                      _Label(text: l10n.learningLevel),
                      SegmentedButton<String>(
                        showSelectedIcon: false,
                        segments: LearningLevels.values
                            .map((level) => ButtonSegment(value: level, label: Text(LessonLabels.level(l10n, level))))
                            .toList(),
                        selected: {_level},
                        onSelectionChanged: (selected) => setState(() => _level = selected.first),
                      ),
                      const SizedBox(height: 16),
                      _Label(text: l10n.learningImageUrl),
                      TextField(
                        controller: _imageUrlController,
                        keyboardType: TextInputType.url,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'https://…',
                          errorText: _isImageUrlValid ? null : l10n.learningImageUrlInvalid,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                        title: Text(l10n.learningActive, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(l10n.learningActiveHint),
                      ),
                    ],
                  ),
                ),
              ),
              if (missing.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFFFF3C4), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _missingMessage(l10n, missing),
                          style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: canSave && !_isSaving ? _save : null,
                child: Text(l10n.learningSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTab extends StatelessWidget {
  final String label;
  final bool isMissing;

  const _LanguageTab({required this.label, required this.isMissing});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))),
          if (isMissing) ...[
            const SizedBox(width: 6),
            Semantics(
              label: l10n.learningMissingDot,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
