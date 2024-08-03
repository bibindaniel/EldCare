import 'package:flutter/material.dart'; // Import material for Navigator
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            macOS: initializationSettingsDarwin);

    tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse);
  }

  Future<void> _onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    // Extract the notification details
    final payload = notificationResponse.payload;

    // Check if the notification response is for a medicine schedule
    if (payload != null) {
      // Parse the payload data (if needed)
      final Map<String, dynamic> data =
          Map<String, dynamic>.from(payload as Map);

      // Extract details from the payload
      final notificationId = data['id'];
      final title = data['title'];
      final body = data['body'];

      // Navigate to the relevant screen based on the notification
      // You may need to get the context from somewhere like a global key or a service
      // This example assumes you have some method to handle navigation, adapt as needed
      Navigator.of(navigationKey.currentContext!).pushNamed(
        '/medicineDetail',
        arguments: {
          'notificationId': notificationId,
          'title': title,
          'body': body,
        },
      );
    } else {
      // Handle cases where there is no payload (if needed)
      print('Notification tapped with no payload');
    }
  }

  Future<void> showNotification(
      int id, String title, String body, DateTime scheduledDate) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_notification_channel',
          'Medicine Notifications',
          channelDescription: 'Notifications for medicine schedules',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}

// Define a global key for navigation (if not already defined)
final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();
