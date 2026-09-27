import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../models/app_notification.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';
import '../models/transaction_record.dart';
import '../models/user_profile.dart';
import '../services/budget_service.dart';
import '../services/goal_service.dart';
import '../services/notification_service.dart';
import '../services/push_notification_service.dart';
import '../services/transaction_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../utils/notification_builder.dart';
import '../utils/notification_display.dart';
import '../widgets/error_state.dart';
import 'budget/budget_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'goals/goals_screen.dart';
import 'more/more_screen.dart';
import 'notifications/notifications_screen.dart';
import 'transactions/history_screen.dart';

/// App frame after login: bottom navigation with 5 tabs.
class MainShell extends StatefulWidget {
  final UserProfile profile;
  final Stream<List<TransactionRecord>> Function(String uid) watchTransactions;
  final Stream<List<Budget>> Function(String uid) watchBudgets;
  final Stream<List<SavingsGoal>> Function(String uid) watchGoals;
  final Stream<Set<String>> Function(String uid) watchReadIds;
  final void Function(String uid, List<String> ids) markRead;

  const MainShell({
    super.key,
    required this.profile,
    this.watchTransactions = TransactionService.watch,
    this.watchBudgets = BudgetService.watch,
    this.watchGoals = GoalService.watch,
    this.watchReadIds = NotificationService.watchReadIds,
    this.markRead = NotificationService.markRead,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentTab = MainTabs.home;
  late UserProfile _profile = widget.profile;
  late Stream<List<TransactionRecord>> _transactionStream = _openTransactionStream();
  late Stream<List<Budget>> _budgetStream = _openBudgetStream();
  late Stream<List<SavingsGoal>> _goalStream = _openGoalStream();
  late Stream<Set<String>> _readIdsStream = _openReadIdsStream();
  // Notification ids already on screen. Null until the first data arrives.
  Set<String>? _knownNotificationIds;

  @override
  void initState() {
    super.initState();
    Formatters.setCurrency(widget.profile.currency);
    // Old accounts sign in without passing the S01 permission screen, so they are asked once here.
    PushNotificationService.requestPermissionIfNeverAsked();
  }

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile.currency != oldWidget.profile.currency) {
      Formatters.setCurrency(widget.profile.currency);
      _profile = widget.profile;
    }
  }

  void _openTab(int index) => setState(() => _currentTab = index);

  Stream<List<TransactionRecord>> _openTransactionStream() {
    try {
      return widget.watchTransactions(widget.profile.uid);
    } catch (e) {
      return Stream.error(e);
    }
  }

  Stream<List<Budget>> _openBudgetStream() {
    try {
      return widget.watchBudgets(widget.profile.uid);
    } catch (e) {
      return Stream.error(e);
    }
  }

  Stream<List<SavingsGoal>> _openGoalStream() {
    try {
      return widget.watchGoals(widget.profile.uid);
    } catch (e) {
      return Stream.error(e);
    }
  }

  Stream<Set<String>> _openReadIdsStream() {
    try {
      return widget.watchReadIds(widget.profile.uid);
    } catch (e) {
      return Stream.error(e);
    }
  }

  void _reloadData() {
    setState(() {
      _transactionStream = _openTransactionStream();
      _budgetStream = _openBudgetStream();
      _goalStream = _openGoalStream();
      _readIdsStream = _openReadIdsStream();
    });
  }

  /// Saves only the notifications that became read on the Notifications screen.
  void _saveReadIds(List<AppNotification> notifications, Set<String> readIds) {
    final List<String> newReadIds = [];
    for (final AppNotification notification in notifications) {
      if (notification.isRead && !readIds.contains(notification.id)) newReadIds.add(notification.id);
    }
    widget.markRead(widget.profile.uid, newReadIds);
  }

  void _openNotifications(List<AppNotification> notifications, Set<String> readIds) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NotificationsScreen(
          notifications: notifications,
          onChanged: (changed) => _saveReadIds(changed, readIds),
          onOpenTab: _openTab,
        ),
      ),
    );
  }

  /// Phone notification for alerts that appear while the app is open (SRS: "instant" spending alerts).
  /// The first time data arrives, the existing alerts are only remembered: they are old and already in the list,
  /// so opening the app again never shows them twice.
  void _pushNewNotifications(List<AppNotification> notifications) {
    final Set<String> currentIds = {};
    for (final AppNotification notification in notifications) {
      currentIds.add(notification.id);
    }

    final Set<String>? knownIds = _knownNotificationIds;
    _knownNotificationIds = currentIds;
    if (knownIds == null || !_profile.notificationsEnabled) return;

    final AppLocalizations l10n = AppLocalizations.of(context)!;
    for (final AppNotification notification in notifications) {
      final bool isNew = !knownIds.contains(notification.id);
      if (isNew && !notification.isRead) {
        PushNotificationService.show(
          notification.id,
          NotificationDisplay.title(l10n, notification),
          NotificationDisplay.message(l10n, notification),
        );
      }
    }
  }

  Widget _buildTabs(List<TransactionRecord> transactions, List<Budget> budgets, List<SavingsGoal> goals, Set<String> readIds) {
    final List<AppNotification> notifications =
        NotificationBuilder.build(transactions: transactions, budgets: budgets, goals: goals, readIds: readIds);
    _pushNewNotifications(notifications);
    // The student can turn alerts off in Settings: the list stays, only the badge is hidden.
    int unreadCount = 0;
    if (_profile.notificationsEnabled) unreadCount = NotificationDisplay.unreadCount(notifications);

    return IndexedStack(
      index: _currentTab,
      children: [
        DashboardScreen(
          transactions: transactions,
          budgets: budgets,
          goals: goals,
          userName: _profile.fullName,
          onOpenTab: _openTab,
          unreadCount: unreadCount,
          onOpenNotifications: () => _openNotifications(notifications, readIds),
        ),
        HistoryScreen(initialTransactions: transactions),
        BudgetScreen(initialBudgets: budgets, transactions: transactions),
        GoalsScreen(initialGoals: goals, transactions: transactions),
        MoreScreen(
          profile: _profile,
          transactions: transactions,
          budgets: budgets,
          goals: goals,
          unreadCount: unreadCount,
          onOpenNotifications: () => _openNotifications(notifications, readIds),
          onProfileChanged: (profile) {
            Formatters.setCurrency(profile.currency);
            setState(() => _profile = profile);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: StreamBuilder<Set<String>>(
        stream: _readIdsStream,
        builder: (context, readSnapshot) {
          // Read marks are extra: if they fail to load, every notification just shows as unread.
          if (readSnapshot.hasError) debugPrint('MainShell read notifications failed: ${readSnapshot.error}');
          final Set<String> readIds = readSnapshot.data ?? {};

          return StreamBuilder<List<SavingsGoal>>(
            stream: _goalStream,
            builder: (context, goalSnapshot) {
              return StreamBuilder<List<Budget>>(
                stream: _budgetStream,
                builder: (context, budgetSnapshot) {
                  return StreamBuilder<List<TransactionRecord>>(
                    stream: _transactionStream,
                    builder: (context, transactionSnapshot) {
                      final Object? error = transactionSnapshot.error ?? budgetSnapshot.error ?? goalSnapshot.error;
                      if (error != null) {
                        debugPrint('MainShell data failed: $error');
                        return SafeArea(child: ErrorState(onRetry: _reloadData));
                      }
                      if (!transactionSnapshot.hasData || !budgetSnapshot.hasData || !goalSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return _buildTabs(transactionSnapshot.data!, budgetSnapshot.data!, goalSnapshot.data!, readIds);
                    },
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: _openTab,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.mintSoft,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: l10n.navHome),
          NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), selectedIcon: const Icon(Icons.receipt_long), label: l10n.navTransactions),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet),
            label: l10n.navBudget,
          ),
          NavigationDestination(icon: const Icon(Icons.flag_outlined), selectedIcon: const Icon(Icons.flag), label: l10n.navGoals),
          NavigationDestination(icon: const Icon(Icons.grid_view_outlined), selectedIcon: const Icon(Icons.grid_view), label: l10n.navMore),
        ],
      ),
    );
  }
}
