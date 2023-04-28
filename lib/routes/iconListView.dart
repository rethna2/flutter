import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'comps/MyAppBar.dart';
import '../common/globalController.dart';

/*
class IconListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'PSchool';

    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(appTitle),
        ),
        body: SingleChildScrollView(child: ReadJson()),
      ),
    );
  }
}
*/
class IconListView extends StatelessWidget {
  const IconListView({Key? key, required this.data}) : super(key: key);
  final Map data;

  @override
  Widget build(BuildContext context) {
    //if (data['grades']) {}
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: MyAppBar(),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(child: Center(child:
            Consumer<GlobalController>(builder: (context, controller, child) {
          List items;
          String grade = 'g4';
          if (data['grades'] != null) {
            grade = controller.user['userPref']?['grade'];
            if (grade == 'all') {
              grade = 'g4';
            }
            items = data['list'].where((item) {
              List range =
                  item['grade'].split('-').map((no) => int.parse(no)).toList();
              bool b;
              RegExp exp = RegExp(r'(\d+)');
              RegExpMatch? matches = exp.firstMatch(grade);
              var gradeNo = int.parse(matches?.group(0) ?? '0');
              if (range.length == 1) {
                b = range[0] == gradeNo;
              } else {
                b = range[0] <= gradeNo && range[1] >= gradeNo;
              }
              return b;
              //return item['grade'].toString().indexOf(grade) != -1;
            }).toList();
          } else {
            items = data['list'].toList();
          }

          /*
          final List items = data['list']
              .where((item) => item['grade'].toString().indexOf(grade) != -1)
              .toList();*/

          return Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(children: [
                Container(
                    width: double.infinity,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        size.width > 500
                            ? (Center(
                                child: Text(data['label'],
                                    style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                        decorationStyle:
                                            TextDecorationStyle.double,
                                        fontSize: 25))))
                            : (Text(data['label'],
                                style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    decorationStyle: TextDecorationStyle.double,
                                    fontSize: 25))),
                        if (data['grades'] != null)
                          Positioned(
                              right: 10,
                              top: -10,
                              child: DropdownButton(
                                value: grade,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: data['grades']
                                    .map<DropdownMenuItem<String>>((item) {
                                  return DropdownMenuItem<String>(
                                    value: item['id'],
                                    child: Text(item['label']),
                                  );
                                }).toList(),
                                // After selecting the desired option,it will
                                // change button value to selected value
                                onChanged: (newValue) {
                                  print('gradeChange = $newValue');
                                  controller.updateUserPref(
                                      'grade', newValue.toString());
                                },
                              ))
                      ],
                    )),
                const SizedBox(height: 30),
                Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: items
                        .mapIndexed((i, item) => SizedBox(
                            width: 140,
                            height: 120,
                            child: Center(
                                child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/playlist',
                                          arguments: RootID(item["id"]));
                                    },
                                    child: Column(children: [
                                      Image.asset(
                                          'assets/icons/${item["img"]}.png',
                                          fit: BoxFit.contain,
                                          width: 80,
                                          height: 80),
                                      const SizedBox(height: 10),
                                      Text(item["label"])
                                    ])))))
                        .toList()),
                if (data['moreActivities'] != null)
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/allPlaylists',
                            arguments: RootID(data['moreActivities']));
                      },
                      child: const Text("More Activities",
                          style: TextStyle(fontSize: 24)),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.purple,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 60, vertical: 15))),
              ]));
        }))));
  }
}
