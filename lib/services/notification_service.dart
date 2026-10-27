import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/task_model.dart';
import '../utils.dart';

// Deadline-এর আগে notification পাঠানোর কাজ
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));

    // Android 13+ এ notification-এর অনুমতি চাওয়া
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  static Future<void> _zoned(Task t, tz.TZDateTime date, AndroidScheduleMode mode) {
    return _plugin.zonedSchedule(
      t.id!,
      '${t.type}: ${t.title}',
      'Due ${formatDate(t.dueAt)} at ${formatTime(t.dueAt)}',
      date,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task reminders',
          channelDescription: 'Alerts before assignments, exams and classes',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: mode,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // একটা task-এর জন্য alert সেট করা (আগেরটা থাকলে মুছে নতুন সেট হয়)
  static Future<void> schedule(Task t) async {
    if (t.id == null) return;
    await _plugin.cancel(t.id!);
    if (t.done) return;

    final when = t.dueAt.subtract(Duration(minutes: t.remindBefore));
    if (when.isBefore(DateTime.now())) return; // সময় পার হয়ে গেলে alert নেই

    final date = tz.TZDateTime.from(when, tz.local);
    try {
      await _zoned(t, date, AndroidScheduleMode.exactAllowWhileIdle);
    } catch (_) {
      // exact alarm-এর অনুমতি না থাকলে একটু দেরিতে হলেও alert দেবে
      await _zoned(t, date, AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

  static Future<void> cancel(int id) => _plugin.cancel(id);

  static Future<void> cancelAll() => _plugin.cancelAll();

  static Future<void> rescheduleAll(List<Task> tasks) async {
    for (final t in tasks) {
      await schedule(t);
    }
  }
}