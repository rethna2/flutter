import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../common/globalController.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pschool_math/utils/filesystem.dart';
import 'dart:convert';
import '../routes/comps/core.dart';

class NotificationTest extends StatefulWidget {
  const NotificationTest({Key? key}) : super(key: key);
  @override
  _NotificationTestState createState() => _NotificationTestState();
}

class _NotificationTestState extends State {
  late int _totalNotifications;
  Map? analytics;
  late final FirebaseMessaging _messaging;
  PushNotification? _notificationInfo;

  @override
  void initState() {
    _totalNotifications = 0;
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    List<PlaylistProg> data =
        await DatabaseHelper.instance.getPlaylistProgressList();
    Map? user = await readFile('analytics');
    setState(() {
      analytics = user;
    });
    print('loadData = ${data.length}');
    int i = 1;
    data.forEach((PlaylistProg element) {
      print('${i++}. ${element.payload}\n\n');
    });
  }

  void registerNotification() async {
    print('registerNotification');
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;

    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    print('settings = $settings');
    final fCMToken = await _messaging.getToken();
    print('fCMToken = $fCMToken');
    setState(() {
      analytics = {'id': fCMToken};
    });
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );

        setState(() {
          _notificationInfo = notification;
          _totalNotifications++;
        });
        if (_notificationInfo != null) {
          // For displaying the notification as an overlay
          showSimpleNotification(
            Text(_notificationInfo!.title!),
            leading: NotificationBadge(totalNotifications: _totalNotifications),
            subtitle: Text(_notificationInfo!.body!),
            background: Colors.cyan.shade700,
            duration: Duration(seconds: 2),
          );
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notify'),
        //  brightness: Brightness.dark,
      ),
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Button(label: 'Request Notification', onClick: registerNotification),
          Button(
              label: 'Clear Work File',
              onClick: () async {
                bool res = await deleteFile('work');
                print('Delete work file $res');
              }),
          Button(
              label: 'Launch Playlist',
              onClick: () async {
                /*
                try {
                  print('Launch Playlist Click');
                  print(
                      ' navigatorKey.currentState = ${navigatorKey.currentState}');
                  navigatorKey.currentState?.pushNamed('/playlist',
                      arguments: RouteArgs(id: 'ratio-7', prevRoute: 'menu'));
                } catch (e) {
                  print('Error $e');
                }
                */
                navigatorKey.currentState?.pushNamed('/playlist',
                    arguments: RouteArgs(id: 'fraction', prevRoute: 'menu'));
/*
                Navigator.pushNamed(context, '/playlist',
                    arguments: RouteArgs(id: 'ratio-7', prevRoute: 'menu'));*/
              }),
          Text(
            'App for capturing Firebase Push Notifications',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 16.0),
          NotificationBadge(totalNotifications: _totalNotifications),
          SizedBox(height: 16.0),
          _notificationInfo != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TITLE: ${_notificationInfo!.title}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'BODY: ${_notificationInfo!.body}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                )
              : Container(),
          SelectableText(json.encode(analytics))
        ],
      )),
    );
  }
}

class NotificationBadge extends StatelessWidget {
  final int totalNotifications;

  const NotificationBadge({required this.totalNotifications});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: new BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$totalNotifications',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}

class PushNotification {
  PushNotification({
    this.title,
    this.body,
  });
  String? title;
  String? body;
}

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}
