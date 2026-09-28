import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import 'firebase_options.dart';
import 'screens/auth/splash_screen.dart';
import 'controllers/locale_service.dart';
import 'controllers/push_notification_service.dart';
import 'utils/app_theme.dart';

/// Starts Firebase, loads the saved language, prepares phone notifications, then shows the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Offline cache only works on Android / iOS (database.md section 8).
    if (!kIsWeb) {
      try {
        FirebaseDatabase.instance.setPersistenceEnabled(true);
      } catch (_) {}
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  await LocaleService.load();
  await PushNotificationService.init();
  runApp(const PennyPalApp());
}

/// Root widget: theme, language and localization delegates.
class PennyPalApp extends StatelessWidget {
  const PennyPalApp({super.key});

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
          home: const SplashScreen(),
        );
      },
    );
  }
}
