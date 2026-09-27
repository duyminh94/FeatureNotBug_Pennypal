import 'package:pennypal_student/l10n/app_localizations.dart';

import '../services/auth_service.dart';

class AuthMessages {
  static String text(AppLocalizations l10n, AuthProblem problem) {
    return switch (problem) {
      AuthProblem.invalidLogin => l10n.errorInvalidLogin,
      AuthProblem.emailInUse => l10n.errorEmailInUse,
      AuthProblem.weakPassword => l10n.errorWeakPassword,
      AuthProblem.tooManyRequests => l10n.errorTooManyRequests,
      AuthProblem.network => l10n.errorNetwork,
      AuthProblem.permission => l10n.errorPermission,
      AuthProblem.wrongApp => l10n.errorWrongApp,
      AuthProblem.locked => l10n.errorAccountLocked,
      AuthProblem.none || AuthProblem.unknown => l10n.errorUnknown,
    };
  }
}
