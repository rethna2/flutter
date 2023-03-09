import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/globalController.dart';

class MyAppBar extends StatelessWidget with PreferredSizeWidget {
  MyAppBar({Key? key, this.title}) : super(key: key);
  String? title;
  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/',
              );
            },
            child: Text(title ?? 'PSchool Math ',
                style:
                    GoogleFonts.girassol(textStyle: TextStyle(fontSize: 24)))),
        actions: [_MainMenu()]);
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _MainMenu extends StatelessWidget {
  const _MainMenu({Key? key}) : super(key: key);

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
        } else if (item == 'All Playlists') {
          Navigator.pushNamed(context, '/allPlaylists',
              arguments: RootID('math-more'));
        }
      },
      child: Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: Icon(
            Icons.menu,
            size: 36.0,
          )),
      itemBuilder: (BuildContext context) {
        return {'Home Page', 'Member', 'About Us', 'All Playlists'}
            .map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
    );
  }
}
