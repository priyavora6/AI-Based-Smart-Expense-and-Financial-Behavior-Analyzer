import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<NotificationProvider>().loadNotifications(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (provider.hasUnread)
            TextButton(
              onPressed: provider.markAllAsRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.teal))
          : RefreshIndicator(
              onRefresh: provider.loadNotifications,
              child: provider.notifications.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 180),
                        Icon(Icons.notifications_none,
                            size: 56, color: AppColors.teal),
                        SizedBox(height: 12),
                        Center(child: Text('You’re all caught up.')),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: provider.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = provider.notifications[index];
                        return Dismissible(
                          key: ValueKey(notification.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) =>
                              provider.deleteNotification(notification.id),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            color: AppColors.expense,
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Card(
                            color: notification.isRead ? null : AppColors.mint,
                            child: ListTile(
                              leading: Icon(
                                notification.isRead
                                    ? Icons.notifications_none
                                    : Icons.notifications_active,
                                color: AppColors.teal,
                              ),
                              title: Text(notification.title),
                              subtitle: Text(notification.body),
                              onTap: () => provider.markAsRead(notification.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
