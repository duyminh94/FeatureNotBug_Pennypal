enum AdminSection { overview, analytics, users, learning, support, feedbacks, settings }

class AdminLayout {
  static const double wideBreakpoint = 600;

  // The navigation rail (logo + 7 sections + logout) needs about 490px and cannot scroll,
  // so shorter screens (a phone turned sideways) use the drawer, whose list scrolls.
  static const double railMinHeight = 520;
}
