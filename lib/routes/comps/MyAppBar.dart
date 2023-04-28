import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/globalController.dart';
import 'package:provider/provider.dart';

class MyAppBar extends StatelessWidget with PreferredSizeWidget {
  MyAppBar({Key? key, this.title}) : super(key: key);
  String? title;
  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalController>(builder: (context, controller, child) {
      return AppBar(
          title: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/',
                );
              },
              child: Text(title ?? controller.config['appBarTitle'],
                  style: GoogleFonts.girassol(
                      textStyle: TextStyle(fontSize: 24)))),
          actions: [_MainMenu(config: controller.config)]);
    });
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _MainMenu extends StatelessWidget {
  _MainMenu({Key? key, required this.config}) : super(key: key);
  late Map config;

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
        } else if (item == 'Test') {
          Navigator.pushNamed(
            context,
            '/test2',
          );
        } else if (item == 'All Playlists') {
          Navigator.pushNamed(context, '/allPlaylists',
              arguments: RootID(config['allPlaylistId']));
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
          return {'Home Page', 'About Us', 'All Playlists'}
              .map((String choice) {
            return PopupMenuItem<String>(
              value: choice,
              child: Text(choice),
            );
          }).toList();
        } else {
          return {
            'Home Page',
            'Member',
            'About Us',
            'All Playlists', /*'Test'*/
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
