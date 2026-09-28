import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../controllers/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/auth_messages.dart';
import '../../utils/category_display.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/labeled_text_field.dart';
import 'notification_permission_screen.dart';

/// S03 Register: profile fields, optional student status and password check.
class RegisterScreen extends StatefulWidget {
  final Future<AuthResult> Function(RegisterForm form) register;

  const RegisterScreen({super.key, this.register = AuthService.register});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _studentStatus;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final AuthResult result = await widget.register(RegisterForm(
      fullName: _nameController.text,
      email: _emailController.text,
      mobileNumber: _mobileController.text,
      studentStatus: _studentStatus,
      password: _passwordController.text,
    ));
    if (!mounted) return;
    if (!result.isSuccess) {
      setState(() {
        _isLoading = false;
        _errorText = AuthMessages.text(l10n, result.problem);
      });
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => NotificationPermissionScreen(profile: result.profile!)),
      (route) => false,
    );
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
                const Align(alignment: Alignment.centerLeft, child: CircleBackButton()),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Image.asset(AppAssets.pig, width: 72, height: 66, fit: BoxFit.cover),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.authRegisterTitle,
                            style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 28, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            l10n.authRegisterSubtitle,
                            style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LabeledTextField(
                  label: l10n.authFullName,
                  icon: Icons.people_outline,
                  controller: _nameController,
                  keyboardType: TextInputType.name,
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
                LabeledTextField(
                  label: l10n.authMobile,
                  icon: Icons.smartphone,
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (Validators.isEmpty(value)) return l10n.validationRequired;
                    return Validators.isValidMobile(value) ? null : l10n.validationMobile;
                  },
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    l10n.authStudentStatus,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _studentStatus,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.school_outlined, color: AppColors.textMuted, size: 22),
                  ),
                  items: StudentStatuses.values
                      .map((status) => DropdownMenuItem(value: status, child: Text(StudentStatusDisplay.name(l10n, status))))
                      .toList(),
                  onChanged: (value) => setState(() => _studentStatus = value),
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: l10n.authPassword,
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  obscureText: true,
                  helperText: l10n.validationPassword,
                  validator: (value) {
                    if (Validators.isEmpty(value)) return l10n.validationRequired;
                    return Validators.isValidPassword(value) ? null : l10n.validationPassword;
                  },
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: l10n.authConfirmPassword,
                  icon: Icons.lock_outline,
                  controller: _confirmController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (Validators.isEmpty(value)) return l10n.validationRequired;
                    return value == _passwordController.text ? null : l10n.validationPasswordMatch;
                  },
                ),
                const SizedBox(height: 28),
                if (_errorText != null) ...[
                  ErrorBanner(message: _errorText!),
                  const SizedBox(height: 12),
                ],
                FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading ? const ButtonProgress() : Text(l10n.authRegisterButton),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.authHaveAccount, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: Text(l10n.authLoginButton),
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
