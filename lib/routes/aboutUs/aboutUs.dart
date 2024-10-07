import 'package:flutter/material.dart';
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
                  'PSchool app has 10000+ learning, practice and fun activities for kg to 8th standard. Our goal is to provide affordable education technology for everyone.',
                  style: paraStyle),
            ),
            Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                    "PSchool stands for Practice School. Our apps help students practice what they learn in the classroom. We don't directly teach. ",
                    style: paraStyle)),
            Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                    "Please play the content present in the home (Showcase) page. Also please check the 'All Playlist' page from the top menu. You can pick the class and subject and check all the contents.",
                    style: paraStyle)),
            Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                    "If you like our app, support us by paying a nominal fee of ₹ 500 per year. By becoming a member, you get access to all locked content present in all classes and subjects. ",
                    style: paraStyle)),
            Padding(
                padding: EdgeInsets.all(15),
                child: RichText(
                    text: TextSpan(style: paraStyle, children: [
                  TextSpan(
                      text:
                          'We also have a web app, and it has all the activities. Some android phones have issues in playing sound and other content. Kindly use '),
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
              child: Text('Free Language Apps',
                  style: paraStyle.copyWith(
                      fontSize: 30, color: Color.fromARGB(255, 1, 65, 118))),
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
                      //bool canLaunch = await canLaunchUrl(uri);
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
