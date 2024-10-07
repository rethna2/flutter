import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/gestures.dart';
import '../comps/MyAppBar.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatelessWidget {
  AboutUs({Key? key}) : super(key: key);
  final List<String> langApps = [
    'Hindi',
    'Tamil',
    'Malayalam',
    'Marathi',
    'Bengali'
  ];
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
                  "This Math app is part of PSchool Learning Apps. We have made this Math app as a completely free app. You can access all content.  You don't have to login or signup. So we have removed the 'Member' page form the main menu.",
                  style: paraStyle),
            ),
            Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                    "PSchool stands for Practice School. Our apps help students practice what they learn in the classroom. We don't directly teach.",
                    style: paraStyle)),
            Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                    "Please play the content present in the home (Showcase) page. Also please check the 'All Playlist' page from the top menu, and explore the different content we have.",
                    style: paraStyle)),
            Padding(
                padding: EdgeInsets.all(15),
                child: RichText(
                    text: TextSpan(style: paraStyle, children: [
                  TextSpan(
                      text:
                          'We also have a web app, and it has all the activities. Kindly use '),
                  TextSpan(
                    text: 'www.pschool.in',
                    style: new TextStyle(color: Colors.blue),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse('https://pschool.in'),
                            mode: LaunchMode.externalApplication);
                      },
                  ),
                  TextSpan(text: ' and it works in all devices.')
                ]))),
            Padding(
                padding: EdgeInsets.all(15),
                child: RichText(
                    text: TextSpan(style: paraStyle, children: [
                  TextSpan(
                      text:
                          'To know more about us, kindly explore our official website '),
                  TextSpan(
                    text: 'www.pschool.app  ',
                    style: new TextStyle(color: Colors.blue),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse('https://pschool.app'),
                            mode: LaunchMode.externalApplication);
                      },
                  ),
                ]))),
            Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                    'If you find any issues or mistakes in the content, kindly share with us. You can reach us by email (info@pschool.in) or whatsapp (91-790-444-6058).',
                    style: paraStyle)),
            Padding(
                padding: EdgeInsets.all(15),
                child: RichText(
                    text: TextSpan(style: paraStyle, children: [
                  TextSpan(
                      text:
                          'PSchool team is taking affordable online Math tuition for class 3 to 8. For more info '),
                  TextSpan(
                    text: 'click here.',
                    style: new TextStyle(color: Colors.blue),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse('https://pschool.app/tuition'),
                            mode: LaunchMode.externalApplication);
                      },
                  ),
                ]))),
            Padding(
              padding: EdgeInsets.all(15),
              child: Text('Free Language Apps',
                  style: paraStyle.copyWith(
                      fontSize: 30, color: Color.fromARGB(255, 8, 100, 107))),
            ),
            Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                    'Select the below language and install the app from playstore.',
                    style: paraStyle)),
            Wrap(alignment: WrapAlignment.center, children: [
              for (int i = 0; i < langApps.length; i++)
                GestureDetector(
                    onTap: () async {
                      Uri uri = Uri.parse(
                          'https://play.google.com/store/apps/details?id=app.pschool.${langApps[i].toLowerCase()}');
                      bool canLaunch = await canLaunchUrl(uri);
                      bool success = await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    },
                    child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: const Color(0xffbcdbf7),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Text(langApps[i],
                            style: paraStyle.copyWith(fontSize: 18))))
            ])
          ],
        ))));
  }
}
