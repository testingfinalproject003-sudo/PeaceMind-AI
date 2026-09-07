import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/routine_model.dart';

/// Routine reminders ke liye local notifications service.
/// User ke set kiye routine time par weekly repeating reminders fire
/// karta hai (flutter_local_notifications + timezone).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _prefsKey = 'peacemind_notifications_enabled';
  static const _channelId = 'routine_reminders';

  bool _initialized = false;
  bool _enabled = true; // default: on
  AndroidScheduleMode? _cachedMode;

  bool get enabled => _enabled;

  /// App start par ek baar call hota hai (web par no-op).
  Future<void> init() async {
    if (kIsWeb) return;
    if (_initialized) return;
    try {
      tzdata.initializeTimeZones();
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            _channelId,
            'Routine Reminders',
            description: 'Reminders for your daily routines',
            importance: Importance.high,
          ));
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(_prefsKey) ?? true;
      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  /// Android 13+ / iOS runtime permission request.
  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;
    var granted = true;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (android != null) {
        granted = await android.requestNotificationsPermission() ?? true;
        // Exact timing ke liye best-effort — na mile to inexact fallback.
        await android.requestExactAlarmsPermission();
      }
      if (ios != null) {
        granted = await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            granted;
      }
    } catch (e) {
      debugPrint('NotificationService permission error: $e');
    }
    return granted;
  }

  /// Settings switch se call hota hai. Permission grant ke baad hi on hota hai.
  /// Returns: effective enabled state after toggle.
  Future<bool> toggle(bool value) async {
    if (kIsWeb) {
      _enabled = value;
      return value;
    }
    if (value) {
      final granted = await requestPermissions();
      if (!granted) return false;
    } else {
      await _cancelAll();
    }
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
    return value;
  }

  /// Saare pending routine reminders cancel + current routines ke hisaab
  /// se dobara schedule karta hai (enabled ho to).
  Future<void> syncWith(List<Routine> routines) async {
    if (kIsWeb) return;
    await init();
    await _cancelAll();
    if (!_enabled) return;

    var id = 0;
    for (final r in routines) {
      final parts = r.time.split(':');
      for (int i = 0; i < 7; i++) {
        if (!r.days[i]) continue;
        final next = _nextOccurrence(
          i + 1, // days index 0=Monday → DateTime.weekday 1=Monday
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
        try {
          await _plugin.zonedSchedule(
            id: id++,
            title: 'Routine Reminder 🌿',
            body: 'Time for ${r.title}',
            scheduledDate: tz.TZDateTime.from(next, tz.UTC),
            notificationDetails: NotificationDetails(
              android: const AndroidNotificationDetails(
                _channelId,
                'Routine Reminders',
                importance: Importance.high,
                priority: Priority.high,
                category: AndroidNotificationCategory.reminder,
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: await _resolveScheduleMode(),
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            payload: r.id,
          );
        } catch (e) {
          debugPrint('NotificationService schedule error (${r.title}): $e');
        }
      }
    }
  }

  /// Next occurrence of [weekday] (DateTime.weekday format) at hh:mm, local time.
  DateTime _nextOccurrence(int weekday, int hour, int minute) {
    final now = DateTime.now();
    final daysAhead = (weekday - now.weekday + 7) % 7;
    var date = DateTime(now.year, now.month, now.day, hour, minute)
        .add(Duration(days: daysAhead));
    if (date.isBefore(now)) date = date.add(const Duration(days: 7));
    return date;
  }

  Future<AndroidScheduleMode> _resolveScheduleMode() async {
    if (_cachedMode != null) return _cachedMode!;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final canExact = await android?.canScheduleExactNotifications() ?? false;
      _cachedMode = canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;
    } catch (_) {
      _cachedMode = AndroidScheduleMode.inexactAllowWhileIdle;
    }
    return _cachedMode!;
  }

  Future<void> _cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('NotificationService cancel error: $e');
    }
  }
}
