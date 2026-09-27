import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/support_query.dart';
import '../../models/user_profile.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

class SupportFormScreen extends StatefulWidget {
  final UserProfile? profile;

  const SupportFormScreen({super.key, this.profile});

  @override
  State<SupportFormScreen> createState() => _SupportFormScreenState();
}

class _SupportFormScreenState extends State<SupportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _hasTriedToSend = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String? _validateLength(String? value, int min, int max, AppLocalizations l10n) {
    if (Validators.isEmpty(value)) return l10n.validationRequired;
    if (Validators.isLengthBetween(value, min, max)) return null;
    return (value ?? '').trim().length < min ? l10n.validationMinLength(min) : l10n.validationMaxLength(max);
  }

  void _send() {
    setState(() => _hasTriedToSend = true);
    if (!_formKey.currentState!.validate()) return;

    final int now = DateTime.now().millisecondsSinceEpoch;
    final SupportQuery query = SupportQuery(
      id: 'sq_$now',
      userEmail: widget.profile?.email ?? FirebaseAuth.instance.currentUser?.email ?? '',
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
      submittedAt: now,
    );
    Navigator.of(context).pop(query);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.supportNew, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _hasTriedToSend ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _FieldLabel(text: l10n.supportSubject),
            TextFormField(
              controller: _subjectController,
              maxLength: FormLimits.subjectMax,
              textInputAction: TextInputAction.next,
              validator: (value) => _validateLength(value, FormLimits.subjectMin, FormLimits.subjectMax, l10n),
              decoration: InputDecoration(
                hintText: l10n.supportSubjectHint,
                prefixIcon: const Icon(Icons.subject, color: AppColors.textMuted),
                errorMaxLines: 2,
              ),
            ),
            const SizedBox(height: 8),
            _FieldLabel(text: l10n.supportMessage),
            TextFormField(
              controller: _messageController,
              maxLines: 7,
              maxLength: FormLimits.messageMax,
              validator: (value) => _validateLength(value, FormLimits.messageMin, FormLimits.messageMax, l10n),
              decoration: InputDecoration(hintText: l10n.supportMessageHint, errorMaxLines: 2),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: _send, icon: const Icon(Icons.send_outlined), label: Text(l10n.supportSend)),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
    );
  }
}
