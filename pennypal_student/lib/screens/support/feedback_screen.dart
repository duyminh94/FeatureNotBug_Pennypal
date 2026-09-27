import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/user_profile.dart';
import '../../services/feedback_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../widgets/labeled_text_field.dart';
import '../../widgets/success_view.dart';

class FeedbackScreen extends StatefulWidget {
  final UserProfile? profile;

  const FeedbackScreen({super.key, this.profile});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  static const int _maxRating = 5;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(text: widget.profile?.fullName ?? '');
  late final TextEditingController _emailController = TextEditingController(text: widget.profile?.email ?? '');
  final TextEditingController _commentsController = TextEditingController();
  int _rating = 0;
  int? _sentRating;
  bool _hasTriedToSend = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  String _ratingLabel(AppLocalizations l10n) {
    return switch (_rating) {
      1 => l10n.feedbackRating1,
      2 => l10n.feedbackRating2,
      3 => l10n.feedbackRating3,
      4 => l10n.feedbackRating4,
      5 => l10n.feedbackRating5,
      _ => '',
    };
  }

  /// Rating 1-5 is required; the feedback goes to Firebase and only the admin can read it.
  void _send() {
    setState(() => _hasTriedToSend = true);
    final bool isFormValid = _formKey.currentState!.validate();
    if (!isFormValid || _rating == 0) return;

    final bool isSent = FeedbackService.send(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _rating,
      _commentsController.text.trim(),
    );
    if (!isSent) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorUnknown)));
      return;
    }
    setState(() => _sentRating = _rating);
  }

  void _resetForm() {
    _nameController.text = widget.profile?.fullName ?? '';
    _emailController.text = widget.profile?.email ?? '';
    _commentsController.clear();
    setState(() {
      _rating = 0;
      _sentRating = null;
      _hasTriedToSend = false;
    });
  }

  void _goHome() => Navigator.of(context).popUntil((route) => route.isFirst);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final int? sentRating = _sentRating;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.dashFeedback, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: sentRating == null
          ? _buildForm(l10n)
          : SuccessView(
              title: l10n.feedbackThanks(Formatters.givenName(_nameController.text)),
              message: l10n.feedbackThanksBody(sentRating),
              primaryLabel: l10n.commonBackHome,
              onPrimary: _goHome,
              secondaryLabel: l10n.feedbackSendAnother,
              onSecondary: _resetForm,
            ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    final bool showRatingError = _hasTriedToSend && _rating == 0;

    return Form(
      key: _formKey,
      autovalidateMode: _hasTriedToSend ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Image.asset(AppAssets.pig, height: 90, fit: BoxFit.contain),
                  const SizedBox(height: 8),
                  Text(
                    l10n.feedbackQuestion,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  // Five 56px buttons need 280px; on a narrower screen the row shrinks a little instead of overflowing.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int star = 1; star <= _maxRating; star++)
                          IconButton(
                            tooltip: l10n.feedbackStar(star),
                            iconSize: 40,
                            onPressed: () => setState(() => _rating = star),
                            icon: Icon(
                              star <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: star <= _rating ? AppColors.honey : AppColors.border,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    showRatingError ? l10n.validationRating : _ratingLabel(l10n),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: showRatingError ? AppColors.error : AppColors.honeyText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          LabeledTextField(
            label: l10n.authFullName,
            icon: Icons.person_outline,
            controller: _nameController,
            validator: (value) => Validators.isEmpty(value) ? l10n.validationRequired : null,
          ),
          const SizedBox(height: 16),
          LabeledTextField(
            label: l10n.authEmail,
            icon: Icons.mail_outline,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (Validators.isEmpty(value)) return l10n.validationRequired;
              return Validators.isValidEmail(value) ? null : l10n.validationEmail;
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              l10n.feedbackComments,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ),
          TextFormField(
            controller: _commentsController,
            maxLines: 5,
            maxLength: FormLimits.commentsMax,
            decoration: InputDecoration(hintText: l10n.feedbackCommentsHint),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: _send, icon: const Icon(Icons.send_outlined), label: Text(l10n.feedbackSend)),
        ],
      ),
    );
  }
}
