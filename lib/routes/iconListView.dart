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
    //if (data['gradeFilter']) {}
    Size size = MediaQuery.of(context).size;
    print('size = $size');
    return Scaffold(
        appBar: MyAppBar(),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(child: Center(child:
            Consumer<GlobalController>(builder: (context, controller, child) {
          String grade = controller.user['grade'] ?? 'g4';
          if (grade == 'all') {
            grade = 'g4';
          }
          final List items = data['list']
              .where((item) => item['grade'].toString().indexOf(grade) != -1)
              .toList();
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
                        if (data['gradeFilter'] != null)
                          Positioned(
                              right: 10,
                              top: -10,
                              child: DropdownButton(
                                value: grade,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: data['gradeFilter']
                                    .map<DropdownMenuItem<String>>((item) {
                                  return DropdownMenuItem<String>(
                                    value: item['id'],
                                    child: Text(item['label']),
                                  );
                                }).toList(),
                                // After selecting the desired option,it will
                                // change button value to selected value
                                onChanged: (newValue) {
                                  print('onChanged $newValue');
                                  controller.updateUser(newValue.toString());
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
                                      print('item id = ${item["id"]}');
                                      Navigator.pushNamed(context, '/playlist',
                                          arguments: RootID(item["id"]));
                                    },
                                    child: Column(children: [
                                      Image.asset(
                                          'assets/icons/${item["img"]}.jpg',
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
