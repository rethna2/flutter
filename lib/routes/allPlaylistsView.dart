import '../common/globalController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'dart:convert';
import 'activityView.dart';
import 'comps/MyAppBar.dart';
import '../utils/filesystem.dart';

Map sample = {
  'ta-sound': {'progress': 50, 'score': 50},
  'ta-sound-2': {'progress': 75, 'score': 75},
};

class AllPlaylistsView extends StatefulWidget {
  const AllPlaylistsView({Key? key}) : super(key: key);
  @override
  _AllPlaylistsViewState createState() => _AllPlaylistsViewState();
}

class _AllPlaylistsViewState extends State<AllPlaylistsView> {
  List _items = [];
  var _data = new Map();
  late Map _masterProg;
  late List _topics;
  late List _grades;
  bool _onlyFav = false;
  bool _showSearchText = false;
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
    Map masterProg = {};

    String str = await readFile("masterProg");
    if (str != '') {
      masterProg = json.decode(str);
    }
    List topics = data["list"]
        .map((item) => {'id': item['id'], 'label': item['label']})
        .toList();
    List grades = data["grades"];
    setState(() {
      // _items = data["list"][0]["list"];
      _items = data["list"];
      _data = data as Map;
      _masterProg = masterProg;
      if (topics.length > 1) {
        _topics = [
          {'id': 'all', 'label': 'All Subject'},
          ...topics
        ];
        _grades = [
          {'id': 'all', 'label': 'All Classes'},
          ...grades
        ];
      }
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
      return Scaffold(
          appBar: MyAppBar(),
          body: const Padding(
              padding: EdgeInsets.all(15), child: Text('Loading...')));
    }

    return Scaffold(
        appBar: MyAppBar(),
        body: SingleChildScrollView(child:
            Consumer<GlobalController>(builder: (context, controller, child) {
          String grade = controller.user['userPref']?['grade'] ?? 'all';
          String subject = controller.user['userPref']?['subject'] ?? 'all';
          print('grade = $grade');
          String fav = controller.user['userPref']?['favorites'] ?? '';
          Set favorites = fav.split(',').toSet();
          List filtered = _items.toList();

          if (searchTxt.length >= 3) {
            filtered = filtered.map((subject) {
              List list2 = subject['list'].where((item) {
                if (item['label'].toLowerCase().indexOf(searchTxt) != -1) {
                  return true;
                }
                return false;
              }).toList();
              return {...subject, 'list': list2};
            }).toList();
          } else if (_onlyFav) {
            filtered = filtered.map((subject) {
              List list2 = subject['list'].where((item) {
                return favorites.contains(item["id"]);
              }).toList();
              return {...subject, 'list': list2};
            }).toList();
          } else {
            if (subject != 'all') {
              filtered = filtered.where((sub) {
                return sub['id'] == subject;
              }).toList();
            }
            if (grade != 'all') {
              filtered = filtered.map((subject) {
                List list2 = subject['list'].where((item) {
                  List range = item['grade']
                      .split('-')
                      .map((no) => int.parse(no))
                      .toList();
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
                return {...subject, 'list': list2};
              }).toList();
            }
          }
          filtered = filtered.where((item) {
            return item['list'].length > 0;
          }).toList();

          /*
          List filtered = _items;

          if (searchTxt.length >= 3) {
            filtered = _items.where((item) {
              if (item['label'].toLowerCase().indexOf(searchTxt) != -1) {
                return true;
              }
              return false;
            }).toList();
          } else if (_onlyFav) {
            filtered = _items.where((item) {
              return favorites.contains(item["id"]);
            }).toList();
          } else if (grade != 'all') {
            filtered = _items.where((item) {
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
          }
          */
          Map res = controller.responses;
          return Container(
              child: Column(children: [
            if (controller.config['freeApp'] != true)
              Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration:
                      const BoxDecoration(color: const Color(0xffbcdbf7)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(children: [
                          const Text("Choose Grade/Class"),
                          DropdownButton(
                            value: grade,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items:
                                _grades.map<DropdownMenuItem<String>>((item) {
                              return DropdownMenuItem<String>(
                                value: item['id'],
                                child: Text(item['label']),
                              );
                            }).toList(),
                            // After selecting the desired option,it will
                            // change button value to selected value
                            onChanged: (newValue) {
                              controller.updateUserPref(
                                  'grade', newValue.toString());
                              setState(() {
                                searchTxt = '';
                              });
                              txtCtrl.text = '';
                            },
                          ),
                        ]),
                        if (_topics != null && _showSearchText == false)
                          Container(
                              margin: EdgeInsets.only(left: 20),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Subject"),
                                    DropdownButton(
                                      value: subject,
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      items: _topics
                                          .map<DropdownMenuItem<String>>(
                                              (item) {
                                        return DropdownMenuItem<String>(
                                          value: item['id'],
                                          child: Text(item['label']),
                                        );
                                      }).toList(),
                                      // After selecting the desired option,it will
                                      // change button value to selected value
                                      onChanged: (newValue) {
                                        controller.updateUserPref(
                                            'subject', newValue.toString());
                                        setState(() {
                                          searchTxt = '';
                                        });
                                        txtCtrl.text = '';
                                      },
                                    ),
                                  ])),
                        Row(
                          children: [
                            if (_showSearchText)
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
                                        hintText: 'search keyword',
                                        isDense: true),
                                  )),
                            IconButton(
                              icon: Icon(_showSearchText == true
                                  ? Icons.close
                                  : Icons.search),
                              tooltip: 'Search',
                              onPressed: () {
                                setState(() {
                                  _showSearchText = !_showSearchText;
                                });
                              },
                            )
                          ],
                        ),
                      ])),
            Padding(
                padding: EdgeInsets.only(top: 5),
                child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _onlyFav = !_onlyFav;
                          });
                        },
                        child: Text(_onlyFav ? 'Show All' : 'Show Favorites',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ))))),
            Column(
                children: filtered
                    .mapIndexed((index, subject) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (filtered.length > 1 && searchTxt.length < 3)
                                Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text(subject['label'],
                                        style: TextStyle(
                                            color: const Color(0xff0d3756),
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold))),
                              Column(
                                  children: (subject['list'] as List)
                                      .mapIndexed((i, item) => Container(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(children: [
                                              Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Container(
                                                        child: Center(
                                                            child: Text(
                                                                (i + 1)
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white))),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        25),
                                                            color: Theme.of(
                                                                    context)
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
                                                                  context,
                                                                  '/playlist',
                                                                  arguments:
                                                                      RootID(item[
                                                                          "id"]));
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          0),
                                                              child: Text(
                                                                item["label"],
                                                              ),
                                                            ))),
                                                    GestureDetector(
                                                        onTap: () {
                                                          Set a = favorites;
                                                          if (a.contains(
                                                              item["id"])) {
                                                            a.remove(
                                                                item["id"]);
                                                          } else {
                                                            a.add(item["id"]);
                                                          }

                                                          controller
                                                              .updateUserPref(
                                                                  'favorites',
                                                                  a.join(','));
                                                        },
                                                        child: Icon(
                                                          Icons.star,
                                                          color: favorites
                                                                  .contains(
                                                                      item[
                                                                          "id"])
                                                              ? Colors.orange
                                                              : Colors.grey,
                                                          size: 24.0,
                                                          semanticLabel:
                                                              'Text to announce in accessibility modes',
                                                        )),
                                                  ]),
                                              if (_masterProg
                                                  .containsKey(item["id"]))
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 70),
                                                        child: Row(children: [
                                                          Stack(
                                                            children: [
                                                              Container(
                                                                width: 100,
                                                                height: 7,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .blueAccent)),
                                                              ),
                                                              Container(
                                                                width: _masterProg[
                                                                            item['id']]
                                                                        [
                                                                        'progress'] +
                                                                    0.0,
                                                                height: 7,
                                                                color:
                                                                    Colors.blue,
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 10),
                                                              child: Text(
                                                                  '${_masterProg[item['id']]['progress']} %'))
                                                        ])),
                                                    Text(
                                                        'Score: ${_masterProg[item['id']]['score']} %')
                                                  ],
                                                )
                                            ]),
                                            // padding:
                                            //     EdgeInsets.symmetric(vertical: 9, horizontal: 9),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                    width: 1,
                                                    color: Colors
                                                        .lightBlue.shade900),
                                              ),
                                            ),
                                          ))
                                      .toList())
                            ]))
                    .toList())
          ]));

          if (_onlyFav && filtered.length == 0)
            Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'Your playlist favorites is empty. Click on the star in playlists to make them your favorites.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ));
        })));
  }
}
