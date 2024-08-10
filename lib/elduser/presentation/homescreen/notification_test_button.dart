import 'package:flutter/material.dart';
import 'package:eldcare/elduser/presentation/homescreen/notification_service.dart';

class NotificationTestButton extends StatelessWidget {
  final NotificationService notificationService;

  const NotificationTestButton({Key? key, required this.notificationService})
      : super(key: key);

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
            final now = TimeOfDay.now();
            final scheduleTime = TimeOfDay(
              hour: now.hour,
              minute: now.minute + 1,
            );
            await notificationService.scheduleNotification(
              999,
              'Test Scheduled Notification',
              'This is a test scheduled notification',
              scheduleTime,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Notification scheduled for ${scheduleTime.format(context)}')),
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
