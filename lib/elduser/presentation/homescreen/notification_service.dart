import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_tts/flutter_tts.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FlutterTts flutterTts = FlutterTts();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'medicine_notification_channel',
      'Medicine Reminders',
      description: 'Reminders for medicine schedules',
      importance: Importance.high,
      playSound: true,
    );

    try {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      debugPrint('Notification channel created successfully.');
    } catch (e) {
      debugPrint('Failed to create notification channel: $e');
    }

    // Create the channel on the device
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    debugPrint('Notification channel created');
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
    tz.setLocalLocation(
        tz.getLocation('Asia/Kolkata')); // Set to Indian Standard Time

    // Initialize TTS
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

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
    if (payload != null) {
      final Map<String, dynamic> payloadData = json.decode(payload);
      final String title = payloadData['title'] ?? '';
      final String body = payloadData['body'] ?? '';

      // Speak the notification content
      await _speakNotification(title, body);

      navigatorKey.currentState
          ?.pushNamed('/medicineDetails', arguments: payload);
    }
  }

  Future<void> _speakNotification(String title, String body) async {
    String textToSpeak = "$title. $body";
    await flutterTts.speak(textToSpeak);
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
    String title,
    String body,
    DateTime scheduleTime,
  ) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime.from(scheduleTime, tz.local);

    // If the scheduled time is in the past, schedule it for 10 seconds from now
    if (scheduledDate.isBefore(now)) {
      scheduledDate = now.add(const Duration(seconds: 10));
    }

    debugPrint('Current time: $now');
    debugPrint('Scheduled time (before check): $scheduleTime');
    debugPrint('Scheduled time (after check): $scheduledDate');
    debugPrint('Time zone: ${tz.local}');

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
            playSound: true,
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
        payload: json.encode({'title': title, 'body': body}),
      );
      debugPrint('Notification scheduled successfully for $scheduledDate');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> requestExactAlarmPermission() async {
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final bool? permissionGranted =
          await androidImplementation.requestExactAlarmsPermission();
      debugPrint('Exact Alarm Permission granted: $permissionGranted');
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
      String title = 'Test Notification';
      String body = 'This is a test notification';
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: json.encode({'title': title, 'body': body}), // Add this line
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

  Future<void> scheduleTestNotification() async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime scheduledDate = now.add(const Duration(minutes: 1));

    await scheduleNotification(
      999999, // Use a unique ID for test notifications
      'Test Notification',
      'This is a test notification scheduled for 1 minute from now',
      scheduledDate,
    );
  }
}
