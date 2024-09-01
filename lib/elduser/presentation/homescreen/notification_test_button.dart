import 'package:flutter/material.dart';
import 'package:eldcare/elduser/presentation/homescreen/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationTestButton extends StatelessWidget {
  final NotificationService notificationService;

  const NotificationTestButton({super.key, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () async {
            await notificationService.showImmediateNotification();
          },
          child: const Text('Test Immediate Notification'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            final areEnabled =
                await notificationService.areNotificationsEnabled();
            if (!areEnabled) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Please enable notifications for this app in your device settings')),
              );
              return;
            }
            final now = tz.TZDateTime.now(tz.local);
            final scheduleTime = now.add(const Duration(minutes: 1));

            debugPrint('Current time: $now');
            debugPrint('Scheduled time: $scheduleTime');
            debugPrint('Time zone: ${tz.local}');

            await notificationService.scheduleNotification(
              999,
              'Test Scheduled Notification',
              'This is a test scheduled notification',
              scheduleTime,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Notification scheduled for ${scheduleTime.toLocal()}')),
            );
          },
          child: const Text('Test Scheduled Notification (1 min)'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            await notificationService.checkPendingNotifications();
          },
          child: const Text('Check Pending Notifications'),
        ),
      ],
    );
  }
}
