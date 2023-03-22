import 'package:flutter/material.dart';
import 'package:pschool_math/routes/comps/core.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/gestures.dart';
import 'comps/MyAppBar.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';
import '../utils/filesystem.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {}

  void showNotification() {
    print('showNotification');
    flutterLocalNotificationsPlugin.show(
        0,
        "Testing Notification",
        "How you doin ?",
        NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                channelDescription: channel.description,
                importance: Importance.high,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/launcher_icon')));
  }

  @override
  Widget build(BuildContext context) {
    TextStyle paraStyle =
        const TextStyle(height: 1.5, fontSize: 18, color: Colors.black);
    return Scaffold(
        appBar: MyAppBar(),
        body: Container(
            child: SingleChildScrollView(
                child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Text('About Us',
                  style: paraStyle.copyWith(fontSize: 30, color: Colors.blue)),
            ),
            Button(
                label: "Send Local Notification",
                onClick: () {
                  print('My Notification');
                  showNotification();
                }),
            Button(
                label: "Clear DB",
                onClick: () {
                  DatabaseHelper.instance.deleteDB();
                })
          ],
        ))));
  }
}
