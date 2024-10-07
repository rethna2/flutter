import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../common/globalController.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('message title : ${message.notification?.title}');
  print('message body : ${message.notification?.body}');
  print('message payload : ${message.data}');
  print('A bg message just showed up :  ${message.messageId}');
  print('playlist id = ${message.data['playlistId']}');
  navigatorKey.currentState?.pushNamed('/playlist',
      arguments: RouteArgs(id: message.data['playlistId'], prevRoute: 'menu'));
}

class FirebaseApi {
  final _messaging = FirebaseMessaging.instance;

  static final FirebaseApi _singleton = FirebaseApi._internal();

  FirebaseApi._internal();

  final _localNotifications = FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
      playSound: true);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory FirebaseApi() {
    return _singleton;
  }

  Future<void> initNotifications() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    String? fCMToken = await _messaging.getToken();
    print('fCMToken = $fCMToken');
    initPushNotifications();
    //return fCMToken;
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /*
  Future initLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _localNotifications.initialize(settings, onDidReceiveNotificationResponse: (payload){
     // final message = RemoteMessage.fromMap(jsonDecode(payload));
      handleMessage(payload);
    });
  }
  */
  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
    FirebaseMessaging.instance
        .getInitialMessage()
        .then(handleMessage); //closed state
    FirebaseMessaging.onMessageOpenedApp
        .listen(handleMessage); //background state
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      /*
      final notification = message.notification;
      if(notification == null) return;
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(android: AndroidNotificationDetails(_androidChannel.id, _androidChannel.name, channelDescription: _androidChannel.description, icon: '@drawable/ic_launcher')),
        payload: jsonEncode(message.toMap())
      );*/
    });
  }

  void handleMessage(RemoteMessage? message) {
    print('handleMessage message = ${message}');
    print('playlistId = ${message?.data['playlistId']}');
    if (message == null) return;
    navigatorKey.currentState?.pushNamed('/playlist',
        arguments:
            RouteArgs(id: message.data['playlistId'], prevRoute: 'menu'));
  }
}
