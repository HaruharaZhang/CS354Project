import 'dart:io';
import 'package:cs354_project/showNotification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

import 'GlobalVariable.dart';

class FirebaseMessage {
  FirebaseMessage();

  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();

  Future<void> initialize() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final initializationSettingsAndroid =
        AndroidInitializationSettings('notification');
    final initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    //这里定义了当用户点击的时候，call _onSelectNotification方法
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _onSelectNotification);

    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  Future<void> _onMessage(RemoteMessage message) async {
    // 显示通知的逻辑
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  }

  Future<void> _onMessageOpenedApp(RemoteMessage message) async {
    // 用户点击通知后的逻辑
    print('A new onMessageOpenedApp event was published!');
  }

  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
    String notificationTitle = "";
    switch (await GlobalVariable.getUserLanguage()) {
      case 'en':
        notificationTitle =
            "A user just post a new event with your subscribed tags";
        break;
      case 'zh':
        notificationTitle = "一位用户刚刚上传了一个新的事件";
        break;
    }

    final notification = message.notification;
    if (notification != null) {
      final title = notification.title ?? '';

      // 创建一个FlutterLocalNotificationsPlugin实例
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      // 初始化通知插件
      final initializationSettingsAndroid = AndroidInitializationSettings('notification');
      final initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // 显示通知
      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'background_notification_channel_id',
        'Background Notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
        playSound: true
      );
      final platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(0, notificationTitle, title, platformChannelSpecifics, payload: 'payload data');
    }
  }

  void _onSelectNotification(String? payload) {
    // 用户点击通知时跳转到指定页面的逻辑
    print('A new message opened from notification');
    if(payload != null && payload.isNotEmpty){
      onNotificationClick.add(payload);
    }
  }

}
