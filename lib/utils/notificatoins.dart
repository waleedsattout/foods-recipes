import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' as sced;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foods/constants.dart';

class Notifications {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize native android notification
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize native Ios Notifications
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  void showNotificationAndroid(String title, String value,
      {List<String>? styleInformation}) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel_id', 'Channel Name',
            channelDescription: 'Channel Description',
            importance: Importance.max,
            styleInformation: InboxStyleInformation(styleInformation!),
            priority: Priority.high,
            ticker: 'ticker');

    int notificationId = 1;
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        notificationId, title, value, notificationDetails,
        payload: 'Not present');
  }

  void showSnackBar(String content, BuildContext? context,
      {int duration = 4, SnackBarAction? action}) {
    Color bgColor;
    if (context != null) {
      bgColor = Theme.of(context).colorScheme.inverseSurface;
    } else {
      var brightness =
          sced.SchedulerBinding.instance.platformDispatcher.platformBrightness;
      bool isDarkMode = brightness == Brightness.dark;

      bgColor = isDarkMode
          ? colorScheme.surfaceContainerHigh
          : colorScheme.inverseSurface;
    }
    scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
      content: Text(content),
      duration: Duration(seconds: duration),
      action: action,
      backgroundColor: bgColor,
    ));
  }
}
