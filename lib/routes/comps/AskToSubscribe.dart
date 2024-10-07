import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/gestures.dart';
import '../comps/MyAppBar.dart';
import '../comps/core.dart';

class AskToSubscribe extends StatelessWidget {
  AskToSubscribe({Key? key, required this.onClose}) : super(key: key);
  Function onClose;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle =
        const TextStyle(fontSize: 21, color: Color(0xffbb00bb), height: 2);

    TextStyle textStyle2 =
        const TextStyle(fontSize: 18, color: Color(0xff0d3756), height: 1.3);

    return Scaffold(
        appBar: MyAppBar(),
        body: Container(
            color: Color(0xffbcdbf7),
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                      onTap: () {
                        onClose();
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color(0xffff0000),
                          ),
                          width: 40,
                          height: 40,
                          child: Text('×',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                                height: 1,
                              ))))),
              Text('Support', style: textStyle),
              PTitle(title: 'PSchool'),
              Text('by becoming a Member', style: textStyle),
              PTitle(title: '₹ 500 / YEAR'),
              Text(
                  "Get access to all locked activities and thousands of activities present in 'All Playlists' by becoming a member.",
                  style: textStyle2),
              const SizedBox(height: 20),
              Text(
                  "This subscription is not just for the existing content but also for the content you are going to receive around the year.",
                  style: textStyle2),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Button(
                      label: 'Later',
                      onClick: onClose,
                      bgColor: Colors.blueAccent),
                  Button(
                      label: 'Login/Subscribe',
                      onClick: () {
                        Navigator.pushNamed(
                          context,
                          '/member',
                        );
                      })
                ],
              )
            ])));
  }
}
