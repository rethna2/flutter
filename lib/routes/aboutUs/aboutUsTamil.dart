import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/gestures.dart';
//import 'comps/MainMenu.dart';
import '../comps/MyAppBar.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({Key? key, required this.appName}) : super(key: key);
  final String appName;

  @override
  Widget build(BuildContext context) {
    TextStyle paraStyle =
        const TextStyle(height: 1.5, fontSize: 18, color: Colors.black);
    return new Scaffold(
        appBar: MyAppBar(),
        body: Container(
            child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Text('About Us',
                  style: paraStyle.copyWith(fontSize: 30, color: Colors.blue)),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                  'This $appName app is part of PSchool Learning Apps. Our goal is to provide affordable education technology for everyone.',
                  style: paraStyle),
            ),
            Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                    'We are trying to keep this app FREE forever. Kindly share it with your friends, students, teachers, schools and help many students to get access to free and quality education content.',
                    style: paraStyle)),
            Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                    'If you like our app, we also provide app for Math, English, Science and Social. You can get access to them by paying a nominal fee of Rs 500 per year.',
                    style: paraStyle)),
            Padding(
                padding: EdgeInsets.all(15),
                child: RichText(
                    text: TextSpan(style: paraStyle, children: [
                  TextSpan(text: 'Kindly visit our website '),
                  TextSpan(
                    text: 'www.pschool.in',
                    style: new TextStyle(color: Colors.blue),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launchUrlString('https://pschool.in');
                      },
                  ),
                  TextSpan(text: ' and explore the lot of sample activities.')
                ])))
          ],
        )));
  }
}
