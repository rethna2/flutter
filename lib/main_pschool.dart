import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'routes/member/member.dart';

import 'routes/iconListView.dart';
import 'routes/activityView.dart';
import 'routes/playlistView.dart';
import 'routes/allPlaylistsView.dart';

//import 'routes/aboutUs/aboutUsTamil.dart';
//import 'routes/aboutUs/aboutUs.dart';
import 'routes/aboutUs/aboutUsMath.dart';

import 'routes/askToSubscribe.dart';
import 'common/theme.dart';
import 'common/globalController.dart';
import 'common/firebaseApi.dart';
import 'common/globalService.dart';

import 'common/notificationTest.dart';
import 'package:overlay_support/overlay_support.dart';

import 'dart:convert';

import 'package:provider/provider.dart';

import 'config.dart';

//import 'routes/paint.dart';

Future<void> main() async {
  /*
  runApp(MaterialApp(   
      title: 'PSchool App',
      home: new Container(child: const Text("Dummy App"))));
 */
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotifications();
  final String showcase =
      await rootBundle.loadString(config['showcaseFile'] as String);
  final data = await json.decode(showcase);

  runApp(ChangeNotifierProvider(
      create: (context) => GlobalController(GlobalService(), context),
      child: OverlaySupport(
          child: MaterialApp(
        title: config['appBarTitle'] as String, theme: appTheme,
        initialRoute: '/',
        navigatorKey: navigatorKey,
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
                case '/test2':
                  return const NotificationTest();
                case '/allPlaylists':
                  return const AllPlaylistsView();
                case '/about':
                  // return const AboutUs(appName: appName);
                  return AboutUs();
                case '/asktosubscribe':
                  return AskToSubscribe();
                case '/member':
                default:
                  return MemberPage();
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
}
