import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/globalController.dart';
import 'package:provider/provider.dart';
import '../../config.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  MyAppBar({Key? key, this.title}) : super(key: key);
  String? title;
  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalController>(builder: (context, controller, child) {
      return AppBar(
          automaticallyImplyLeading: false,
          title: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/',
                );
              },
              child: Text(title ?? config['appBarTitle'] as String,
                  style: GoogleFonts.girassol(
                      textStyle: TextStyle(fontSize: 24)))),
          actions: [_MainMenu()]);
    });
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _MainMenu extends StatelessWidget {
  _MainMenu({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var route = ModalRoute.of(context)!.settings.name;

    /*
     if (route == '/about') {
      return SizedBox.shrink();
    }
    return Padding(
        padding: EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/about',
            );
          },
          child: Text('About Us'),
        ));
    */

    return PopupMenuButton<String>(
      onSelected: (item) {
        if (item == 'Home Page') {
          Navigator.pushNamed(
            context,
            '/',
          );
        } else if (item == 'Member') {
          Navigator.pushNamed(
            context,
            '/member',
          );
        } else if (item == 'About Us') {
          Navigator.pushNamed(
            context,
            '/about',
          );
        } else if (item == 'Donate Us') {
          launchUrl(Uri.parse('https://pschool.app/donate'),
              mode: LaunchMode.externalApplication);
        } else if (item == 'Test') {
          Navigator.pushNamed(
            context,
            '/test2',
          );
        } else if (item == 'All Playlists') {
          Navigator.pushNamed(context, '/allPlaylists',
              arguments: RouteArgs(id: config['allPlaylistId'] as String));
        }
      },
      child: Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: Icon(
            Icons.menu,
            size: 36.0,
          )),
      itemBuilder: (BuildContext context) {
        if (config['freeApp'] == true) {
          return {'Home Page', 'About Us', 'Donate Us', 'All Playlists'}
              .map((String choice) {
            return PopupMenuItem<String>(
              value: choice,
              child: Text(choice),
            );
          }).toList();
        } else {
          return {
            'Home Page',
            'All Playlists',
            // 'Member',
            'About Us',
            'Donate Us',

            /*, 'Test'*/
          }.map((String choice) {
            return PopupMenuItem<String>(
              value: choice,
              child: Text(choice),
            );
          }).toList();
        }
      },
    );
  }
}
