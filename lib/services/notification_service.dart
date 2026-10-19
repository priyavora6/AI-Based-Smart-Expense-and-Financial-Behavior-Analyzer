import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_constants.dart';
import '../models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';
import 'local_notification_service.dart';

/// Manages in-app notifications (budget alerts, unusual spending, etc.).
class NotificationService {
  final FirebaseFirestore _db = FirebaseService.firestore;
  final String _col = AppConstants.colNotifications;

  // ── Create Notification ───────────────────────

  Future<void> createNotification({
    required String title,
    required String body,
    required String type,
    String? relatedId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('notifications') ?? true)) return;

    final notification = NotificationModel(
      id: '',
      userId: FirebaseService.currentUserId,
      title: title,
      body: body,
      type: type,
      relatedId: relatedId,
      createdAt: DateTime.now(),
    );

    await _db.collection(_col).add(notification.toFirestore());
    await LocalNotificationService.instance.show(
      title: title,
      body: body,
      type: type,
    );
  }

  // ── Get All Notifications ─────────────────────

  Future<List<NotificationModel>> getNotifications({
    int limit = 20,
  }) async {
    final snapshot = await FirebaseService.notificationsCol
        .where('userId', isEqualTo: FirebaseService.currentUserId)
        .get();

    return snapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt))
      ..removeRange(
        limit < snapshot.docs.length ? limit : snapshot.docs.length,
        snapshot.docs.length,
      );
  }

  // ── Get Unread Count ──────────────────────────

  Future<int> getUnreadCount() async {
    final snapshot = await FirebaseService.notificationsCol
        .where('userId', isEqualTo: FirebaseService.currentUserId)
        .get();
    return snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['isRead'] != true;
    }).length;
  }

  // ── Mark as Read ──────────────────────────────

  Future<void> markAsRead(String notificationId) async {
    await _db.collection(_col).doc(notificationId).update({
      'isRead': true,
    });
  }

  // ── Mark All as Read ──────────────────────────

  Future<void> markAllAsRead() async {
    final unread = await FirebaseService.notificationsCol
        .where('userId', isEqualTo: FirebaseService.currentUserId)
        .get();

    final batch = _db.batch();
    for (final doc in unread.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['isRead'] != true) {
        batch.update(doc.reference, {'isRead': true});
      }
    }
    await batch.commit();
  }

  // ── Delete Notification ───────────────────────

  Future<void> deleteNotification(String notificationId) async {
    await _db.collection(_col).doc(notificationId).delete();
  }

  // ── Auto-Create Budget Alert ──────────────────

  Future<void> createBudgetAlert({
    required String categoryName,
    required double spent,
    required double limit,
  }) async {
    if (limit <= 0) return;
    final percentage = ((spent / limit) * 100).toStringAsFixed(0);

    await createNotification(
      title: 'Budget Alert: $categoryName',
      body: 'You have used $percentage% of your $categoryName budget '
          '(₹${spent.toStringAsFixed(0)} / ₹${limit.toStringAsFixed(0)}).',
      type: 'budget_alert',
    );
  }

  // ── Auto-Create Unusual Spending Alert ────────

  Future<void> createUnusualSpendingAlert({
    required String description,
    required double amount,
    required String category,
  }) async {
    await createNotification(
      title: 'Unusual Spending Detected',
      body: '₹${amount.toStringAsFixed(0)} spent on "$description" '
          '($category) is higher than your usual spending.',
      type: 'unusual_spending',
    );
  }

  Future<void> createAIInsightNotification(String summary) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'ai_insight_notification_${DateTime.now().year}_'
        '${DateTime.now().month}_${DateTime.now().day}';
    if (prefs.getBool(key) ?? false) return;
    await prefs.setBool(key, true);
    await createNotification(
      title: 'New AI insight',
      body: summary,
      type: 'ai_insight',
    );
  }
}
