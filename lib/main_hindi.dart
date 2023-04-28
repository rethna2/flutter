import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'routes/member/member.dart';

import 'routes/iconListView.dart';
import 'routes/activityView.dart';
import 'routes/playlistView.dart';
import 'routes/allPlaylistsView.dart';
import 'routes/aboutUs/aboutUsTamil.dart';
import 'routes/askToSubscribe.dart';
import 'routes/testPage.dart';

import 'common/theme.dart';
import 'common/globalController.dart';
import 'common/globalService.dart';

import 'common/notificationTest.dart';
import 'package:overlay_support/overlay_support.dart';

import 'dart:convert';

import 'package:provider/provider.dart';

//import 'routes/paint.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up :  ${message.messageId}');
}

Future<void> main() async {
  /*
  runApp(MaterialApp(   
      title: 'PSchool App',
      home: new Container(child: const Text("Dummy App"))));
 */
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  /*
  String showcaseFile = 'assets/playlists/tamil.pschool';
   const appName = "Tamil";
  const config = {
    'appBarTitle': 'பழகுதமிழ்',
    'freeApp': true,
    'allPlaylistId': 'tamil-more'
  };
  */

  String showcaseFile = 'assets/playlists/hindi.pschool';
  const appName = "Hindi";
  const config = {
    'appBarTitle': 'PSchool Hindi',
    'freeApp': true,
    'allPlaylistId': 'hindi-more'
  };

  final String showcase = await rootBundle.loadString(showcaseFile);
  final data = await json.decode(showcase);

  runApp(ChangeNotifierProvider(
      create: (context) => GlobalController(GlobalService(), context, config),
      child: OverlaySupport(
          child: MaterialApp(
        title: config['appBarTitle'] as String, theme: appTheme,
        initialRoute: '/',
        // home: const MyHome(),
        onGenerateRoute: (RouteSettings routeSettings) {
          return MaterialPageRoute<void>(
            settings: routeSettings,
            builder: (BuildContext context) {
              print('routeSettings.name = ${routeSettings.name}');
              switch (routeSettings.name) {
                case '/':
                  return IconListView(data: data as Map);
                case '/playlist':
                  return const PlaylistView();
                case '/activity':
                  return const ActivityView();
                case '/test':
                  return const NotificationTest();
                case '/allPlaylists':
                  return const AllPlaylistsView();
                case '/about':
                  return const AboutUs(appName: appName);
                case '/test2':
                  return const TestPage();
                case '/asktosubscribe':
                  return AskToSubscribe();
                case '/member':
                default:
                  return const MemberPage();
              }
            },
          );
        },
        /*
      routes: {
        '/app': (context) => const WebApp(),
        '/login': (context) => Login(),
        //'/': (context) => new PaintPage(),
        '/': (context) => IconListView(),
        '/playlist': (context) => const PlaylistView(
            controller: const GlobalController(GlobalService())),
        '/activity': (context) => ActivityView(),
        // '/animation': (context) => MyAnimation(),
        '/animation': (context) => MyTweenAnimation()
      })
      */
      ))));

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/launcher_icon',
            ),
          ));
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      /*
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title!),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body!)],
                  ),
                ),
              );
            });

            */
    }
  });
}
