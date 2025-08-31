import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
            child: SingleChildScrollView(
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
                  'This $appName app is part of PSchool Learning Apps. We provide FREE learning apps for all academic subjects like Maths, English, Science etc.',
                  style: paraStyle),
            ),
            Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                    "We don't show ads. You don't have to login or sign up. Kindly share it with your friends, students, teachers, schools and help many students to get access to free and quality education content.",
                    style: paraStyle)),
            Padding(
                padding: EdgeInsets.all(15),
                child: RichText(
                    text: TextSpan(style: paraStyle, children: [
                  TextSpan(text: 'You can explore our main learning app at '),
                  TextSpan(
                    text: 'www.pschool.in',
                    style: new TextStyle(color: Colors.blue),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse('https://pschool.in'),
                            mode: LaunchMode.externalApplication);
                      },
                  ),
                  TextSpan(
                      text:
                          '. This web app cover all subjects and has all of our content. Each activity has a unique link, so you can easily share it with others.'),
                ]))),
            Padding(
                padding: EdgeInsets.all(15),
                child: RichText(
                    text: TextSpan(style: paraStyle, children: [
                  TextSpan(
                      text:
                          'To know more about our other contents and features of PSchool, please visit our official website '),
                  TextSpan(
                    text: 'www.pschool.app',
                    style: new TextStyle(color: Colors.blue),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse('https://pschool.app'),
                            mode: LaunchMode.externalApplication);
                      },
                  )
                ]))),
            Padding(
                padding: EdgeInsets.all(15),
                child: RichText(
                    text: TextSpan(style: paraStyle, children: [
                  TextSpan(
                      text:
                          'If you like our work, please consider making a small donation through our '),
                  TextSpan(
                    text: 'Donate Us Page.',
                    style: new TextStyle(color: Colors.blue),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse('https://pschool.app/donate'),
                            mode: LaunchMode.externalApplication);
                      },
                  )
                ]))),
            Padding(
                padding: EdgeInsets.all(15),
                child: RichText(
                    text: TextSpan(style: paraStyle, children: [
                  TextSpan(
                      text:
                          'If you have expertise, and willing to contribute a few hours to make our apps better, please check our '),
                  TextSpan(
                    text: 'Contributors Page.',
                    style: new TextStyle(color: Colors.blue),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse('https://pschool.app/volunteers'),
                            mode: LaunchMode.externalApplication);
                      },
                  )
                ]))),
            const SizedBox(height: 40)
          ],
        ))));
  }
}
