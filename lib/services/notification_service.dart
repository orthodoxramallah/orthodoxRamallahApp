import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/foundation.dart';
import '../data/daily_verses.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

static Future<void> init() async {
  try {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jerusalem')); // Fixed
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    
    // Android permission
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
    
    // iOS permission (optional - DarwinInitializationSettings handles this)
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
    
  } catch (e) {
    debugPrint('NotificationService init error: $e');
  }
}

  static Future<void> scheduleDailyPrayerNotification() async {
    try {
      await _notifications.cancel(0);
      
      final verse = getTodayVerse();
      final androidDetails = AndroidNotificationDetails(
        'daily_prayer_channel',
        'Daily Prayer',
        channelDescription: 'Daily Bible verse at 7:00 AM',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(verse),
      );
      
      await _notifications.zonedSchedule(
        0,
        'آية اليوم 📖',
        verse,
        _nextInstanceOf7AM(),
        NotificationDetails(android: androidDetails, iOS: const DarwinNotificationDetails()),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Schedule notification error: $e');
    }
  }

  static String getTodayVerse() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final dayOfYear = now.difference(startOfYear).inDays;
    return dailyVerses[dayOfYear % dailyVerses.length];
  }

  static tz.TZDateTime _nextInstanceOf7AM() {
    final location = tz.getLocation('Asia/Jerusalem');
    final now = tz.TZDateTime.now(location);
    var scheduled = tz.TZDateTime(location, now.year, now.month, now.day, 7, 0);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}