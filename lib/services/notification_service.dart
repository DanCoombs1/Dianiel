import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/calendar_event.dart';

DateTime? reminderTime(CalendarEvent e) {
  final lead = e.reminder.leadTime;
  if (lead == null) return null;
  return e.startsAt.subtract(lead);
}

int notificationIdFor(String eventId) => eventId.hashCode & 0x7fffffff;

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        iOS: DarwinInitializationSettings(),
      ),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleForEvent(CalendarEvent e) async {
    await cancelForEvent(e.id);
    final when = reminderTime(e);
    if (when == null || when.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(
      id: notificationIdFor(e.id),
      title: e.title,
      body: e.owner.isTogether ? '❤️ Together' : e.owner.label,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: const NotificationDetails(
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelForEvent(String id) =>
      _plugin.cancel(id: notificationIdFor(id));
}
