import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'comps/MainMenu.dart';

import '../comps/MyAppBar.dart';

class Social extends StatelessWidget {
  const Social({Key? key}) : super(key: key);

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
        padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
        child: Column(children: [
          const Divider(color: Colors.grey),
          Text('Follow Us'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: const FaIcon(FontAwesomeIcons.whatsapp,
                      color: Color(0xff075E54)),
                  onPressed: () {
                    launchSocial(
                        'https://whatsapp.com/channel/0029VaBmyyHHAdNPF7fUPe03');
                  }),
              IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: const FaIcon(FontAwesomeIcons.squareFacebook,
                      color: Color(0xff3B5998)),
                  onPressed: () {
                    launchSocial('https://www.facebook.com/pschool.in');
                  }),
              IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: const FaIcon(FontAwesomeIcons.instagram,
                      color: Color(0xffDD2A7B)),
                  onPressed: () {
                    launchSocial('https://www.instagram.com/pschool.in');
                  }),
              IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: const FaIcon(FontAwesomeIcons.youtube,
                      color: Color(0xffE62117)),
                  onPressed: () async {
                    launchSocial(
                        'https://www.youtube.com/channel/UCEAHgV0Qp2x3oEFbAoAdVyg');
                  }),
              IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: const FaIcon(FontAwesomeIcons.twitter,
                      color: Color(0xff08a0e9)),
                  onPressed: () {
                    launchSocial('https://twitter.com/pschool_app');
                  }),
              IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: const FaIcon(FontAwesomeIcons.pinterest,
                      color: Color(0xffBD081C)),
                  onPressed: () {
                    launchSocial('https://www.pinterest.com/pschool_in/');
                  }),
              IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: const FaIcon(FontAwesomeIcons.linkedin,
                      color: Color(0xff0077B5)),
                  onPressed: () {
                    launchSocial('https://www.linkedin.com/company/pschool-in');
                  }),
              IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: const FaIcon(FontAwesomeIcons.github,
                      color: Color(0xff00405d)),
                  onPressed: () {
                    launchSocial('https://github.com/pschool-in/curriculum');
                  }),
            ],
          )
        ]));
  }
}
