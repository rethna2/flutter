import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/gestures.dart';
import 'comps/MyAppBar.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle paraStyle =
        const TextStyle(height: 1.5, fontSize: 18, color: Colors.black);
    return Scaffold(
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
                  'The Math app is part of PSchool Learning Apps. Our goal is to provide affordable education technology for everyone.',
                  style: paraStyle),
            ),
            Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                    'P in PSchool stands for Practice. We have thousands of Math activities that students love to do. ',
                    style: paraStyle)),
            Padding(
                padding: EdgeInsets.all(15),
                child: RichText(
                    text: TextSpan(style: paraStyle, children: [
                  TextSpan(
                      text:
                          'If you like our app, support us by paying a nominal fee of Rs 500 per year. There is no recurring fees. We also provide learning content for English, Science and Social. You can get access to them with this one subscription. Please check our web app '),
                  TextSpan(
                    text: 'www.pschool.in',
                    style: new TextStyle(color: Colors.blue),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launchUrlString('https://pschool.in');
                      },
                  ),
                  TextSpan(text: ' and explore the lot of sample activities.')
                ]))),
            Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                    'If you find any issues or mistakes in the content, kindly share with us. You can reach us by email (info@pschool.in) or whatsapp (91-790-444-6058).',
                    style: paraStyle)),
          ],
        ))));
  }
}
