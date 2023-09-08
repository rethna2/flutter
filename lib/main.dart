import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'routes/member/member.dart';

import 'routes/iconListView.dart';
import 'routes/activityView.dart';
import 'routes/playlistView.dart';
import 'routes/allPlaylistsView.dart';
import 'routes/aboutUs/aboutUsTamil.dart';

import 'common/theme.dart';
import 'common/globalController.dart';
import 'common/globalService.dart';

import 'common/notificationTest.dart';
import 'package:overlay_support/overlay_support.dart';

import 'dart:convert';

import 'package:provider/provider.dart';

//import 'routes/paint.dart';

Future<void> main() async {
  /*
  runApp(MaterialApp(   
      title: 'PSchool App',
      home: new Container(child: const Text("Dummy App"))));
 */
  WidgetsFlutterBinding.ensureInitialized();
  /*
  String showcaseFile = 'assets/playlists/tamil.pschool';
   const appName = "Tamil";
  const config = {
    'appBarTitle': 'பழகுதமிழ்',
    'freeApp': true,
    'allPlaylistId': 'tamil-more'
  };
  */

/*
  String showcaseFile = 'assets/playlists/hindi.pschool';
  const appName = "Hindi";
  const config = {
    'appBarTitle': 'PSchool Hindi',
    'freeApp': true,
    'allPlaylistId': 'hindi-more'
  };
  */

  String showcaseFile = 'assets/playlists/marathi.pschool';
  const appName = "Marathi";
  const config = {
    'appBarTitle': 'PSchool Marathi',
    'freeApp': true,
    'allPlaylistId': 'marathi-more'
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
}
