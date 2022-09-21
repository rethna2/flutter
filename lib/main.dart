import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'routes/member/member.dart';

import 'routes/iconListView.dart';
import 'routes/activityView.dart';
import 'routes/playlistView.dart';
import 'routes/allPlaylistsView.dart';
import 'routes/aboutUsMath.dart';
import 'routes/askToSubscribe.dart';

import 'common/theme.dart';
import 'common/globalController.dart';
import 'common/globalService.dart';

import 'common/notificationTest.dart';
import 'package:overlay_support/overlay_support.dart';

import 'dart:convert';

import 'package:provider/provider.dart';

//import 'routes/paint.dart';

void main() async {
  /*
  runApp(MaterialApp(
      title: 'PSchool App',
      home: new Container(child: const Text("Dummy App"))));
 */
  WidgetsFlutterBinding.ensureInitialized();
  final String showcase =
      await rootBundle.loadString('assets/playlists/maths-sc.pschool');
  final data = await json.decode(showcase);

  runApp(ChangeNotifierProvider(
      create: (context) => GlobalController(GlobalService(), context),
      child: OverlaySupport(
          child: MaterialApp(
        title: 'PSchool Math', theme: appTheme, initialRoute: '/',
        // home: const MyHome(),
        onGenerateRoute: (RouteSettings routeSettings) {
          return MaterialPageRoute<void>(
            settings: routeSettings,
            builder: (BuildContext context) {
              switch (routeSettings.name) {
                case '/':
                  return IconListView(data: data as Map);
                case '/playlist':
                  return new PlaylistView();
                case '/activity':
                  return ActivityView();
                case '/test':
                  return NotificationTest();
                case '/allPlaylists':
                  return AllPlaylistsView();
                case '/about':
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
