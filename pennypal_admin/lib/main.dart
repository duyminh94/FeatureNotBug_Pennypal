import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'firebase_options.dart';
import 'screens/login/login_screen.dart';
import 'services/locale_service.dart';
import 'utils/app_theme.dart';

/// Starts Firebase and the saved language, then opens the admin login.
/// The app still opens when Firebase fails so the login screen can show the error.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  await LocaleService.load();
  runApp(const PennyPalAdminApp());
}

/// Root widget; rebuilds the whole app when the admin switches EN / VI.
class PennyPalAdminApp extends StatelessWidget {
  const PennyPalAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleService.locale,
      builder: (context, locale, _) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: locale,
          supportedLocales: LocaleService.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const LoginScreen(),
        );
      },
    );
  }
}
