import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // ─── Initialization ───────────────────────────────────────

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap — navigate to relevant screen
    print('Notification tapped: ${response.payload}');
  }

  // ─── Permissions ──────────────────────────────────────────

  Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _notifications.resolvePlatformSpecificImplementation
        IOSFlutterLocalNotificationsPlugin>();

    bool? androidGranted = await android?.requestNotificationsPermission();
    bool? iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return androidGranted ?? iosGranted ?? false;
  }

  // ─── Notification Details ─────────────────────────────────

  NotificationDetails _buildNotificationDetails({
    String channelId = 'habit_reminders',
    String channelName = 'Habit Reminders',
    String channelDescription = 'Daily reminders to complete your habits',
  }) {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF7F77DD),
      enableLights: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  // ─── Immediate Notification ───────────────────────────────

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      _buildNotificationDetails(),
      payload: payload,
    );
  }

  // ─── Daily Scheduled Notification ────────────────────────

  Future<void> scheduleDailyHabitReminder({
    required int id,
    required String habitName,
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      id,
      'Time for your habit!',
      'Don\'t forget to complete: $habitName',
      _nextInstanceOfTime(hour, minute),
      _buildNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: habitName,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ─── Streak Notification ──────────────────────────────────

  Future<void> showStreakNotification({
    required String habitName,
    required int streakCount,
  }) async {
    await showInstantNotification(
      id: habitName.hashCode,
      title: 'Streak milestone! 🔥',
      body: 'You\'ve kept up $habitName for $streakCount days in a row!',
      payload: habitName,
    );
  }

  // ─── Completion Notification ──────────────────────────────

  Future<void> showCompletionNotification({
    required String habitName,
  }) async {
    await showInstantNotification(
      id: habitName.hashCode + 1,
      title: 'Great job! ✓',
      body: 'You completed $habitName today. Keep it up!',
      payload: habitName,
    );
  }

  // ─── Cancel Notifications ─────────────────────────────────

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // ─── Pending Notifications ────────────────────────────────

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
