import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../controllers/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/auth_messages.dart';
import '../../utils/constants.dart';
import '../main_shell.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  static const Duration minimumShowTime = Duration(milliseconds: 1500);

  final Future<AuthResult?> Function() checkSession;

  const SplashScreen({super.key, this.checkSession = AuthService.checkSession});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showGetStarted = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final List<Object?> results = await Future.wait([
      Future<void>.delayed(SplashScreen.minimumShowTime),
      widget.checkSession(),
    ]);
    if (!mounted) return;

    final AuthResult? session = results[1] as AuthResult?;
    if (session == null) {
      setState(() => _showGetStarted = true);
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final Widget next = session.isSuccess
        ? MainShell(profile: session.profile!)
        : LoginScreen(initialMessage: AuthMessages.text(l10n, session.problem));
    _openScreen(next);
  }

  void _openScreen(Widget screen) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 300,
                height: 300,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.honeySoft,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(AppAssets.logo, semanticLabel: l10n.appTitle),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.splashTagline,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.splashSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const Spacer(flex: 3),
              if (_showGetStarted)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _openScreen(const LoginScreen()),
                    child: Text(l10n.splashGetStarted),
                  ),
                )
              else ...[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Dot(color: AppColors.textPrimary),
                    _Dot(color: AppColors.pink),
                    _Dot(color: AppColors.mint),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.commonLoading,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
