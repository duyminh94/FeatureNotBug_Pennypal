import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'firebase_options.dart';
import 'services/locale_service.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';
import 'widgets/error_state.dart';

/// Starts Firebase, loads the saved language, then shows the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Offline cache only works on Android / iOS (database.md section 8).
    if (!kIsWeb) {
      FirebaseDatabase.instance.setPersistenceEnabled(true);
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  await LocaleService.load();
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
          home: const _StartScreen(),
        );
      },
    );
  }
}

/// Temporary start screen until the Splash screen is built.
/// It proves the language switch and the database connection work.
class _StartScreen extends StatefulWidget {
  const _StartScreen();

  @override
  State<_StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<_StartScreen> {
  late Future<DataSnapshot> _settingsFuture;

  @override
  void initState() {
    super.initState();
    _settingsFuture = _readAppSettings();
  }

  /// Reads app_settings once to check the database connection.
  Future<DataSnapshot> _readAppSettings() {
    return FirebaseDatabase.instance.ref(DbNodes.appSettings).get();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('English')),
                ButtonSegment(value: 'vi', label: Text('Tiếng Việt')),
              ],
              selected: {languageCode},
              onSelectionChanged: (selection) =>
                  LocaleService.change(selection.first),
            ),
            const SizedBox(height: 24),
            Text(l10n.categoryFood),
            Text(l10n.commonSave),
            const SizedBox(height: 24),
            FutureBuilder<DataSnapshot>(
              future: _settingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Text(l10n.commonLoading);
                }
                if (snapshot.hasError) {
                  return ErrorState(
                    onRetry: () => setState(() {
                      _settingsFuture = _readAppSettings();
                    }),
                  );
                }
                final Object? value = snapshot.data?.value;
                final Map<dynamic, dynamic> settings =
                    value is Map ? value : {};
                return Text(
                  'Firebase OK · ${settings[DbFields.supportEmail] ?? '-'}',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
