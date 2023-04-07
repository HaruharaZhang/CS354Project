import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class FirebaseMessage {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initialize() async {
    if (Platform.isIOS) {
      // request permission for ios devices
      messaging.requestPermission();
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
      // TODO: handle the message received from server
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // TODO: handle the message received from server when the app is opened
    });
  }

  static Future<void> backgroundMessageHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('notification');
    // final IOSInitializationSettings initializationSettingsIOS =
    // IOSInitializationSettings(
    //   onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    // );
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      //iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        'com.dongyunyanjiusuo.eventForMe', 'Event For Me',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    // await flutterLocalNotificationsPlugin.show(
    //   0,
    //   message.notification!.title,
    //   message.notification!.body,
    //   platformChannelSpecifics,
    // );
    await flutterLocalNotificationsPlugin.show(
      0,
      'new_notification_title'.tr(),
      message.notification!.title,
      platformChannelSpecifics,
    );
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // your logic to handle the notification
  }

}
