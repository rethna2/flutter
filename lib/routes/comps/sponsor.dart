import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'comps/MainMenu.dart';

import '../comps/MyAppBar.dart';

class Sponsor extends StatelessWidget {
  const Sponsor({Key? key}) : super(key: key);

  Future<void> launchSocial(String link) async {
    bool canLaunch = await canLaunchUrl(Uri.parse(link));
    print('success canLaunch = $canLaunch');
    bool success =
        await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
    print('success = $success');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Column(children: [
          const Divider(color: Colors.grey),
          const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: Text('Sponsor & Partner')),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                  onTap: () {
                    launchSocial('https://playbook.comini.in/');
                  },
                  child: Column(children: [
                    Image.asset('assets/img/sponsor/comini.webp',
                        fit: BoxFit.contain, width: 80, height: 80),
                    const SizedBox(height: 10),
                    Text("Micro School")
                  ])),
              InkWell(
                  onTap: () {
                    launchSocial(
                        'https://play.google.com/store/apps/details?id=com.kernelinsights.funphonics');
                  },
                  child: Column(children: [
                    Image.asset('assets/img/sponsor/giffie.webp',
                        fit: BoxFit.contain, width: 80, height: 80),
                    const SizedBox(height: 10),
                    Text("Learn English")
                  ])),
              InkWell(
                  onTap: () {
                    launchSocial(
                        'https://play.google.com/store/apps/details?id=in.comini.playlab');
                  },
                  child: Column(children: [
                    Image.asset('assets/img/sponsor/cominilab.webp',
                        fit: BoxFit.contain, width: 80, height: 80),
                    const SizedBox(height: 10),
                    Text("Math Games")
                  ]))
            ],
          )
        ]));
  }
}
