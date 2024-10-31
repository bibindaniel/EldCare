import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:eldcare/elduser/presentation/homescreen/notification_service.dart';

class TTSTestPage extends StatefulWidget {
  const TTSTestPage({super.key});

  @override
  TTSTestPageState createState() => TTSTestPageState();
}

class TTSTestPageState extends State<TTSTestPage> {
  final FlutterTts flutterTts = FlutterTts();
  final NotificationService notificationService = NotificationService();
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _checkNotificationPermissions();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _checkNotificationPermissions() async {
    bool permissionsGranted =
        await notificationService.areNotificationsEnabled();
    print('Notification permissions granted: $permissionsGranted');
    if (!permissionsGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification permissions not granted')),
      );
    }
  }

  Future<void> _speak(String text) async {
    if (!isSpeaking) {
      var result = await flutterTts.speak(text);
      if (result == 1) {
        setState(() {
          isSpeaking = true;
        });
      }
    }
  }

  Future<void> _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) {
      setState(() {
        isSpeaking = false;
      });
    }
  }

  Future<void> _scheduleNotification() async {
    try {
      final DateTime scheduleTime =
          DateTime.now().add(const Duration(seconds: 60));
      await notificationService.scheduleNotification(
        0,
        'Medicine Reminder',
        "It's time to take your medicine. The dosage is two pills.",
        scheduleTime,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Notification scheduled for 10 seconds from now')),
      );
      // Check pending notifications after scheduling
      await _checkPendingNotifications();
    } catch (e) {
      print('Error scheduling notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to schedule notification: $e')),
      );
    }
  }

  Future<void> _showImmediateNotification() async {
    try {
      await notificationService.showImmediateNotification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Immediate notification sent')),
      );
    } catch (e) {
      print('Error sending immediate notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send immediate notification: $e')),
      );
    }
  }

  Future<void> _checkPendingNotifications() async {
    await notificationService.checkPendingNotifications();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TTS Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _speak(
                    "It's time to take your medicine. The dosage is two pills.");
              },
              child: const Text('Test TTS'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stop,
              child: const Text('Stop TTS'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scheduleNotification,
              child: const Text('Schedule Notification (10 seconds)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showImmediateNotification,
              child: const Text('Show Immediate Notification'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkPendingNotifications,
              child: const Text('Check Pending Notifications'),
            ),
          ],
        ),
      ),
    );
  }
}
