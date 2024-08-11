import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        debugPrint(
            'Received iOS notification: id=$id, title=$title, body=$body, payload=$payload');
      },
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
    debugPrint('NotificationService initialized');
    requestExactAlarmPermission();
  }

  Future<void> _onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    debugPrint('Notification tapped: payload=$payload');
    if (payload != null) {
      navigatorKey.currentState
          ?.pushNamed('/medicineDetails', arguments: payload);
    }
  }

  Future<bool> areNotificationsEnabled() async {
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    debugPrint('Are notifications enabled: $result');
    return result ?? false;
  }

  Future<void> scheduleNotification(
    int id,
    String medicineName,
    String dosage,
    TimeOfDay scheduleTime,
  ) async {
    tz.initializeTimeZones(); // Ensure this is called
    final String timeZoneName = tz.local.name;
    debugPrint('Local time zone: $timeZoneName');

    final now = tz.TZDateTime.now(tz.getLocation(timeZoneName));
    var scheduledDate = tz.TZDateTime(
      tz.getLocation(timeZoneName),
      now.year,
      now.month,
      now.day,
      scheduleTime.hour,
      scheduleTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    final String formattedTime =
        '${scheduleTime.hour.toString().padLeft(2, '0')}:${scheduleTime.minute.toString().padLeft(2, '0')}';
    final String title = 'Time to take $medicineName';
    final String body = 'Take $dosage at $formattedTime';

    debugPrint(
        'Scheduling notification: id=$id, title=$title, body=$body, scheduledDate=$scheduledDate, localTime=${scheduledDate.toLocal()}');

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medicine_notification_channel',
            'Medicine Reminders',
            channelDescription: 'Reminders for medicine schedules',
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker',
            visibility: NotificationVisibility.public,
            fullScreenIntent: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Notification scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> requestExactAlarmPermission() async {
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  Future<void> cancelNotifications(int medicineId) async {
    for (int i = 0; i < 24; i++) {
      await flutterLocalNotificationsPlugin.cancel(medicineId + i.hashCode);
    }
    debugPrint('Notifications cancelled for medicineId=$medicineId');
  }

  Future<bool> _checkNotificationPermission() async {
    // For Android
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted =
          await androidImplementation.areNotificationsEnabled();
      if (granted != null && !granted) {
        // Optionally, you can request permission here
        // final bool? requestResult = await androidImplementation.requestPermission();
        // return requestResult ?? false;
        return false;
      }
    }

    // For iOS
    final IOSFlutterLocalNotificationsPlugin? iOSImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iOSImplementation != null) {
      final bool? result = await iOSImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }

    // If we can't determine the permission status, assume it's granted
    return true;
  }

  Future<void> showImmediateNotification() async {
    // Check notification permission
    final bool permissionGranted = await _checkNotificationPermission();
    if (!permissionGranted) {
      debugPrint('Notification permission not granted');
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'medicine_notification_channel',
      'Medicine Reminders',
      channelDescription: 'Reminders for medicine schedules',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      await flutterLocalNotificationsPlugin.show(
        0,
        'Test Notification',
        'This is a test notification',
        platformChannelSpecifics,
        payload: 'test',
      );
      debugPrint('Immediate notification sent');
    } catch (e) {
      debugPrint('Error sending immediate notification: $e');
    }
  }

  Future<void> checkPendingNotifications() async {
    final List<PendingNotificationRequest> pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    debugPrint('Pending notifications: ${pendingNotifications.length}');
    for (var notification in pendingNotifications) {
      debugPrint(
          'Pending notification: id=${notification.id}, title=${notification.title}, body=${notification.body}');
    }
  }
}
