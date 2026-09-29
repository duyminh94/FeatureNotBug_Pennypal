import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../controllers/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/auth_messages.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/labeled_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final Future<AuthProblem> Function(String email) sendReset;

  const ForgotPasswordScreen({super.key, this.sendReset = AuthService.sendPasswordReset});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const int _resendWaitSeconds = 45;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  Timer? _timer;
  String? _sentToEmail;
  int _secondsLeft = 0;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final AuthProblem problem = await widget.sendReset(_emailController.text);
    if (!mounted) return;
    if (problem != AuthProblem.none) {
      setState(() {
        _isLoading = false;
        _errorText = AuthMessages.text(l10n, problem);
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _sentToEmail = _emailController.text.trim();
      _secondsLeft = _resendWaitSeconds;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) timer.cancel();
      setState(() => _secondsLeft = _secondsLeft - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isWaiting = _secondsLeft > 0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(alignment: Alignment.centerLeft, child: CircleBackButton()),
                Center(child: Image.asset(AppAssets.pig, width: 140, height: 130, fit: BoxFit.cover)),
                const SizedBox(height: 16),
                Text(
                  l10n.authForgotPassword,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 30, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.authForgotSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                LabeledTextField(
                  label: l10n.authEmail,
                  icon: Icons.mail_outline,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (Validators.isEmpty(value)) return l10n.validationRequired;
                    return Validators.isValidEmail(value) ? null : l10n.validationEmail;
                  },
                ),
                if (_sentToEmail != null) ...[
                  const SizedBox(height: 16),
                  _SentNotice(title: l10n.authResetSentTitle, body: l10n.authResetSentBody(_sentToEmail!)),
                ],
                if (_errorText != null) ...[
                  const SizedBox(height: 16),
                  ErrorBanner(message: _errorText!),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: isWaiting || _isLoading ? null : _send,
                  child: _isLoading
                      ? const ButtonProgress()
                      : Text(isWaiting ? l10n.authResendIn(_secondsLeft) : l10n.authSendResetLink),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text(l10n.authBackToLogin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SentNotice extends StatelessWidget {
  final String title;
  final String body;

  const _SentNotice({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mintSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '$title ', style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: body),
                ],
              ),
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
