import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/app_notification.dart';
import '../../utils/app_theme.dart';
import '../../utils/notification_display.dart';
import '../../widgets/empty_state.dart';
import '../support/support_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final List<AppNotification> notifications;
  final ValueChanged<List<AppNotification>> onChanged;
  final ValueChanged<int> onOpenTab;

  const NotificationsScreen({
    super.key,
    required this.notifications,
    required this.onChanged,
    required this.onOpenTab,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final List<AppNotification> _notifications = [...widget.notifications]
    ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));

  void _update() {
    setState(() {});
    widget.onChanged([..._notifications]);
  }

  void _markAllRead() {
    for (int index = 0; index < _notifications.length; index++) {
      _notifications[index] = NotificationDisplay.markRead(_notifications[index]);
    }
    _update();
  }

  void _open(AppNotification notification) {
    final int index = _notifications.indexOf(notification);
    _notifications[index] = NotificationDisplay.markRead(notification);
    _update();

    final int? tab = NotificationDisplay.targetTab(notification.type);
    if (tab != null) {
      Navigator.of(context).pop();
      widget.onOpenTab(tab);
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SupportScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final int unread = NotificationDisplay.unreadCount(_notifications);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.dashNotifications, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: _notifications.isEmpty
          ? EmptyState(icon: Icons.notifications_none, message: l10n.inboxEmpty)
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.inboxUnread(unread),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        backgroundColor: AppColors.mintSoft,
                        foregroundColor: AppColors.primary,
                      ),
                      onPressed: unread == 0 ? null : _markAllRead,
                      icon: const Icon(Icons.check),
                      label: Text(l10n.inboxMarkAllRead),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (int index = 0; index < _notifications.length; index++) ...[
                        if (index > 0) const Divider(height: 1, color: AppColors.border),
                        _NotificationTile(notification: _notifications[index], onTap: () => _open(_notifications[index])),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isUnread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isUnread ? AppColors.background : null,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: NotificationDisplay.softColor(notification.type),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(NotificationDisplay.icon(notification.type), color: NotificationDisplay.color(notification.type)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(NotificationDisplay.title(l10n, notification), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    NotificationDisplay.message(l10n, notification),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w400,
                      color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NotificationDisplay.timeLabel(l10n, notification.createdAt),
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (isUnread)
              Semantics(
                label: l10n.inboxUnread(1),
                child: Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
