import '../common/globalController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'dart:convert';
import 'activityView.dart';
import 'comps/MyAppBar.dart';
import '../../common/globalController.dart';

class AllPlaylistsView extends StatefulWidget {
  const AllPlaylistsView({Key? key}) : super(key: key);
  @override
  _AllPlaylistsViewState createState() => _AllPlaylistsViewState();
}

class _AllPlaylistsViewState extends State<AllPlaylistsView> {
  List _items = [];
  var _data = new Map();
  String searchTxt = '';
  TextEditingController txtCtrl = TextEditingController();
  /*
  void initState() {
    
    super.initState();
  }
  */
  Future<void> readJson(id) async {
    final String response =
        await rootBundle.loadString('assets/playlists/${id}.pschool');
    final data = await json.decode(response);
    setState(() {
      _items = data["list"][0]["list"];
      _data = data as Map;
    });
    return data;
  }

  @override
  Widget build(BuildContext context) {
    if (_items.length == 0) {
      final args = ModalRoute.of(context)!.settings.arguments as RootID;
      readJson(args.id);
    }
    if (_items.length == 0) {
      return Text('Loading...');
    }
    return Scaffold(
        appBar: MyAppBar(),
        body: SingleChildScrollView(child:
            Consumer<GlobalController>(builder: (context, controller, child) {
          String grade = controller.user['grade'] ?? 'all';
          List filtered = _items;
          if (searchTxt.length >= 3) {
            filtered = _items.where((item) {
              if (item['label'].toLowerCase().indexOf(searchTxt) != -1) {
                return true;
              }
              return false;
            }).toList();
          } else if (grade != 'all') {
            filtered = _items
                .where((item) => item['grade'].toString().indexOf(grade) != -1)
                .toList();
          }

          return Container(
              child: Column(children: [
            Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: const BoxDecoration(color: const Color(0xffbcdbf7)),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(children: [
                        const Text("Choose Grade/Class"),
                        DropdownButton(
                          value: grade,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: _data['gradeFilter']
                              .map<DropdownMenuItem<String>>((item) {
                            return DropdownMenuItem<String>(
                              value: item['id'],
                              child: Text(item['label']),
                            );
                          }).toList(),
                          // After selecting the desired option,it will
                          // change button value to selected value
                          onChanged: (newValue) {
                            controller.updateUser(newValue.toString());
                            setState(() {
                              searchTxt = '';
                            });
                            txtCtrl.text = '';
                          },
                        ),
                      ]),
                      Row(
                        children: [
                          SizedBox(
                              width: 150,
                              child: TextField(
                                controller: txtCtrl,
                                onChanged: (value) {
                                  if (value.length >= 3) {
                                    setState(() {
                                      searchTxt = value;
                                    });
                                  } else {
                                    searchTxt = value;
                                  }
                                },
                                decoration: InputDecoration(
                                    hintText: 'search keyword', isDense: true),
                              )),
                          IconButton(
                            icon: const Icon(Icons.search),
                            tooltip: 'Search',
                            onPressed: () {},
                          )
                        ],
                      ),
                    ])),
            Column(
                children: filtered
                    .mapIndexed((i, item) => Container(
                          padding: const EdgeInsets.all(10),
                          child: Column(children: [
                            Row(mainAxisSize: MainAxisSize.max, children: [
                              Container(
                                  child: Center(
                                      child: Text((i + 1).toString(),
                                          style:
                                              TextStyle(color: Colors.white))),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                  height: 40,
                                  width: 40),
                              const SizedBox(
                                width: 30,
                              ),
                              Expanded(
                                  child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/playlist',
                                            arguments: RootID(item["id"]));
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 0),
                                        child: Text(
                                          item["label"],
                                        ),
                                      ))),
                            ]),
                          ]),
                          // padding:
                          //     EdgeInsets.symmetric(vertical: 9, horizontal: 9),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 1, color: Colors.lightBlue.shade900),
                            ),
                          ),
                        ))
                    .toList())
          ]));
        })));
  }
}
