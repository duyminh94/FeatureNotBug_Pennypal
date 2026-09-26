import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/auth_messages.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/labeled_text_field.dart';
import '../../widgets/language_toggle.dart';
import '../main_shell.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

/// S02 Login: email + password form with links to register and forgot password.
class LoginScreen extends StatefulWidget {
  final Future<AuthResult> Function(String email, String password) signIn;
  final String? initialMessage;

  const LoginScreen({super.key, this.signIn = AuthService.signIn, this.initialMessage});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordHidden = true;
  bool _isLoading = false;
  late String? _errorText = widget.initialMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final AuthResult result = await widget.signIn(_emailController.text, _passwordController.text);
    if (!mounted) return;
    if (!result.isSuccess) {
      setState(() {
        _isLoading = false;
        _errorText = AuthMessages.text(l10n, result.problem);
      });
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MainShell(profile: result.profile!)),
      (route) => false,
    );
  }

  void _openScreen(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(alignment: Alignment.centerRight, child: LanguageToggle()),
                Center(
                  child: Image.asset(AppAssets.logo, width: 180, height: 180, semanticLabel: l10n.appTitle),
                ),
                Text(
                  l10n.authLoginTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 30, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.authLoginSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
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
                LabeledTextField(
                  label: l10n.authPassword,
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  obscureText: _isPasswordHidden,
                  textInputAction: TextInputAction.done,
                  validator: (value) => Validators.isEmpty(value) ? l10n.validationRequired : null,
                  suffix: IconButton(
                    tooltip: _isPasswordHidden ? l10n.authShowPassword : l10n.authHidePassword,
                    icon: Icon(
                      _isPasswordHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _openScreen(const ForgotPasswordScreen()),
                    child: Text(l10n.authForgotPassword),
                  ),
                ),
                const SizedBox(height: 8),
                if (_errorText != null) ...[
                  ErrorBanner(message: _errorText!),
                  const SizedBox(height: 12),
                ],
                FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading ? const ButtonProgress() : Text(l10n.authLoginButton),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.authNoAccount, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: () => _openScreen(const RegisterScreen()),
                      child: Text(l10n.authRegisterNow),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
