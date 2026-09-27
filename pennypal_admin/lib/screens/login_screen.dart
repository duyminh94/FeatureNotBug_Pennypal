import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../services/admin_auth_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../models/admin_data.dart';
import '../utils/validators.dart';
import '../widgets/language_toggle.dart';
import 'admin_shell.dart';

class LoginScreen extends StatefulWidget {
  final AdminData? data;
  final Future<AdminLoginResult> Function(String email, String password) signIn;

  const LoginScreen({super.key, this.data, this.signIn = AdminAuthService.signIn});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordHidden = true;
  AdminLoginProblem _problem = AdminLoginProblem.none;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _problem = AdminLoginProblem.none;
    });

    final AdminLoginResult result = await widget.signIn(_emailController.text, _passwordController.text);
    if (!mounted) return;
    if (!result.isSuccess) {
      setState(() {
        _isLoading = false;
        _problem = result.problem;
      });
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AdminShell(data: widget.data, admin: result.admin!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String? errorText = switch (_problem) {
      AdminLoginProblem.notAdmin => l10n.loginNotAdmin,
      AdminLoginProblem.wrongCredentials => l10n.loginWrong,
      AdminLoginProblem.tooManyRequests => l10n.loginTooMany,
      AdminLoginProblem.network => l10n.loginNetwork,
      AdminLoginProblem.unknown => l10n.loginUnknown,
      AdminLoginProblem.none => null,
    };

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const Align(alignment: Alignment.centerRight, child: LanguageToggle()),
                  Image.asset(AppAssets.logo, height: 150),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      const Text('PennyPal', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          l10n.adminBadge,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(l10n.loginSubtitle, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (errorText != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: AppColors.errorSoft, borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(errorText, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            Text(l10n.loginEmail, style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onChanged: (_) => setState(() => _problem = AdminLoginProblem.none),
                              validator: (value) {
                                if (Validators.isEmpty(value)) return l10n.validationRequired;
                                return Validators.isValidEmail(value) ? null : l10n.validationEmail;
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(l10n.loginPassword, style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _isPasswordHidden,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _signIn(),
                              validator: (value) => Validators.isEmpty(value) ? l10n.validationRequired : null,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  tooltip: _isPasswordHidden ? l10n.loginShowPassword : l10n.loginHidePassword,
                                  icon: Icon(_isPasswordHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                  onPressed: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            FilledButton(
                              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                              onPressed: _isLoading ? null : _signIn,
                              child: _isLoading
                                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                  : Text(l10n.loginSignIn),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.loginFootnote, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
