import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'comps/MainMenu.dart';

import '../comps/MyAppBar.dart';

class Sponsor2 extends StatelessWidget {
  const Sponsor2({Key? key}) : super(key: key);

  Future<void> launchSocial(String link) async {
    bool canLaunch = await canLaunchUrl(Uri.parse(link));
    print('success canLaunch = $canLaunch');
    bool success =
        await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
    print('success = $success');
  }

  @override
  Widget build(BuildContext context) {
    TextStyle paraStyle =
        const TextStyle(height: 1.5, fontSize: 18, color: Colors.black);
    return Container(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Column(children: [
          const Divider(color: Colors.grey),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: Text('Sponsor & Partner', style: paraStyle)),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 20.0),
                  child: Row(children: [
                    Image.asset('assets/img/sponsor/comini.webp',
                        fit: BoxFit.contain, width: 80, height: 80),
                    const SizedBox(height: 10),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Text("What is a microschool?",
                                style: paraStyle))),
                    ElevatedButton(
                        onPressed: () {
                          launchSocial('https://playbook.comini.in/');
                        },
                        child: const Text("Check It",
                            style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: new Color(0xff4fa7f7),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15))),
                  ])),
              Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 20.0),
                  child: Row(children: [
                    Image.asset('assets/img/sponsor/giffie.webp',
                        fit: BoxFit.contain, width: 80, height: 80),
                    const SizedBox(height: 10),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Text("Giffie: Play to learn English!",
                                style: paraStyle))),
                    ElevatedButton(
                        onPressed: () {
                          launchSocial(
                              'https://play.google.com/store/apps/details?id=com.kernelinsights.funphonics');
                        },
                        child: const Text("Check It",
                            style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: new Color(0xff4fa7f7),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15))),
                  ])),
              Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 20.0),
                  child: Row(children: [
                    Image.asset('assets/img/sponsor/cominilab.webp',
                        fit: BoxFit.contain, width: 80, height: 80),
                    const SizedBox(height: 10),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Text(
                                "Fun games for learning maths and more.",
                                style: paraStyle))),
                    ElevatedButton(
                        onPressed: () {
                          launchSocial(
                              'https://play.google.com/store/apps/details?id=in.comini.playlab');
                        },
                        child: const Text("Check It",
                            style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: new Color(0xff4fa7f7),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15))),
                  ]))
            ],
          )
        ]));
  }
}
