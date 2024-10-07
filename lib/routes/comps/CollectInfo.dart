import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
/*
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
*/
import '../../utils/utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import '../comps/core.dart';
import '../../common/globalController.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../comps/MyAppBar.dart';
import '../../common/apiService.dart';
import '../../common/firebaseApi.dart';
import '../../config.dart';

class CollectInfo extends StatefulWidget {
  CollectInfo({Key? key, required this.onClose}) : super(key: key);
  final Function onClose;
  @override
  State<CollectInfo> createState() => _CollectInfoState();
}

class _CollectInfoState extends State<CollectInfo> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isWaiting = false;
  String errorMsg = '';
  Set grades = {};
  Set langs = {};

  List<Map> allLangs = [
    {'label': 'Hindi', 'id': 'hi'},
    {'label': 'Marathi', 'id': 'mr'},
    {'label': 'Tamil', 'id': 'ta'},
    {'label': 'Telugu', 'id': 'te'},
    {'label': 'Kannada', 'id': 'kn'},
    {'label': 'Malayalam', 'id': 'ml'},
    {'label': 'Bengali', 'id': 'bn'},
    {'label': 'Gujarati', 'id': 'gu'},
    {'label': 'Punjabi', 'id': 'pa'},
    {'label': 'Odia', 'id': 'or'},
    {'label': 'Assamese', 'id': 'as'},
  ];

  List<Map> allGrades = [
    {'id': 'kg', 'label': 'Kindergarten'},
    {'id': 'g1', 'label': 'Class 1'},
    {'id': 'g2', 'label': 'Class 2'},
    {'id': 'g3', 'label': 'Class 3'},
    {'id': 'g4', 'label': 'Class 4'},
    {'id': 'g5', 'label': 'Class 5'},
    {'id': 'g6', 'label': 'Class 6'},
    {'id': 'g7', 'label': 'Class 7'},
    {'id': 'g8', 'label': 'Class 8'}
  ];

  Future<void> handleSubmit(controller) async {
    if (isWaiting) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      isWaiting = true;
      errorMsg = '';
    });
    String res = await controller.login(email.toLowerCase(), password);
    if (res == 'success') {
      Navigator.pushNamed(
        context,
        '/member/details',
      );
    } else {
      setState(() {
        errorMsg = res;
        isWaiting = false;
      });
    }
  }

  void changeGrade(grade) {
    Set g = {...grades};
    setState(() {
      if (grades.contains(grade)) {
        g.remove(grade);
      } else {
        g.add(grade);
      }
      grades = g;
    });
  }

  void changeLang(lang) {
    Set g = {...langs};
    print('lang = $lang');
    setState(() {
      if (langs.contains(lang)) {
        g.remove(lang);
      } else {
        g.add(lang);
      }
      langs = g;
      print('langs = $langs');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(),
        body: Consumer<GlobalController>(builder: (context, controller, child) {
          return SingleChildScrollView(
              child: Column(children: [
            SizedBox(height: 20),
            PTitle(title: 'Choose Class/Grade'),
            Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xff1b75b7)),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Wrap(alignment: WrapAlignment.spaceAround, children: [
                  for (int i = 0; i < allGrades.length; i++)
                    InkWell(
                        onTap: () {
                          changeGrade(allGrades[i]['id']);
                        },
                        child: SizedBox(
                            width: 110,
                            height: 35,
                            //padding: const EdgeInsets.only(right: 15, bottom: 10),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                SizedBox(
                                    width: 24.0,
                                    height: 24.0,
                                    child: Checkbox(
                                        value:
                                            grades.contains(allGrades[i]['id']),
                                        onChanged: (value) {
                                          changeGrade(allGrades[i]['id']);
                                        })),
                                Text(allGrades[i]['label'])
                              ],
                            )))
                ])),
            SizedBox(height: 20),
            /*
            PTitle(title: 'Your mother tongue?'),
            Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xff1b75b7)),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (int i = 0; i < allLangs.length; i++)
                        InkWell(
                            onTap: () {
                              changeLang(allLangs[i]['id']);
                            },
                            child: SizedBox(
                                width: 110,
                                height: 35,
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 24.0,
                                        height: 24.0,
                                        child: Checkbox(
                                            value: langs
                                                .contains(allLangs[i]['id']),
                                            onChanged: (value) {
                                              changeLang(allLangs[i]['id']);
                                            })),
                                    Text(allLangs[i]['label'])
                                  ],
                                )))
                    ])),
            
            */
            Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                    'This information helps us to show relevant content in future.')),
            if (grades.isNotEmpty)
              Button(
                  label: 'Update',
                  onClick: () async {
                    if (controller.user['notification'] == null) {
                      print('notification null');
                    } else {
                      print('notification not null');
                    }
                    String? fCMToken = await FirebaseApi().getToken();
                    if (fCMToken != null) {
                      Map note = {
                        'token': fCMToken,
                        'grades': grades.join(','),
                        'langs': langs.join(','),
                        //'app': 'com.gotowisdom.pschool',
                        //'app': 'app.pschool.math',
                        'app': config['appId'],
                        'time': DateTime.now().microsecondsSinceEpoch
                      };
                      if (controller.user['profile'] != null) {
                        note['user'] = controller.user['profile']['id'];
                      }

                      Map? res = await ApiService.post(
                          'notification/registerApp', null, note, {});
                      print('submit notification $res');
                      controller.addUserProps({'notification': note});
                    }
                    widget.onClose();
                  })
          ]));
        }));
  }
}
