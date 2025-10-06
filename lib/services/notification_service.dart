import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationService._privateConstructor() : flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static final NotificationService instance = NotificationService._privateConstructor();

  // Initialize the notification plugin
  Future<void> initialize() async {
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');  // Your app icon goes here
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Function to show a simple notification
  Future<void> showNotification(String title, String body) async {
    var androidDetails = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'This is the channel for your notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    var generalNotificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,  // Notification ID
      title,  // Title
      body,  // Body text
      generalNotificationDetails,
    );
  }

  // Function to show a scheduled notification
  Future<void> showScheduledNotification(String title, String body, DateTime scheduledTime) async {
    var androidDetails = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'This is the channel for your notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    var generalNotificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.schedule(
      0,  // Notification ID
      title,  // Title
      body,  // Body text
      scheduledTime,  // Time when notification will appear
      generalNotificationDetails,
    );
  }

  // Function to cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
