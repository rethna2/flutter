import 'package:provider/provider.dart';
import '../common/globalController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'dart:convert';
import 'activityView.dart';
import 'comps/MyAppBar.dart';
import '../utils/filesystem.dart';

/*
class PlaylistView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Playlist';

    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(appTitle),
        ),
        body: SingleChildScrollView(child: ReadPlaylistJson()),
      ),
    );
  }
}
*/
class PlaylistView extends StatefulWidget {
  const PlaylistView({Key? key}) : super(key: key);
  @override
  _ReadPlaylistJsonState createState() => _ReadPlaylistJsonState();
}

class _ReadPlaylistJsonState extends State<PlaylistView> with RouteAware {
  List _items = [];
  var _data = new Map();
  var _res = {};
  String? _lastAct;
  void initState() {
    super.initState();
    print('playlistview initState');
    //final args = ModalRoute.of(context)!.settings.arguments as RootID;
    //print('initState = ${args}');
  }

  @override
  void didPopNext() {
    // Covering route was popped off the navigator.
  }

  Future<void> readJson(RootID args) async {
    final String response =
        await rootBundle.loadString('assets/playlists/${args.id}.pschool');
    final data = await json.decode(response);

    var res = {};
    try {
      res = await DatabaseHelper.instance.getPlaylistProgress(args.id);
      print('readJson $res ${res['payload']}');
      res = res['payload'] != null ? json.decode(res['payload']) : {};
    } catch (e) {
      print("Error in local DB : $e");
    }
    print('res = $res');
    try {
      if (args.lastAct != null && args.lastAct != _lastAct) {
        String lastAct = args.lastAct ?? '';
        if (lastAct.indexOf('_') != -1) {
          int nextIndex =
              int.parse(lastAct.substring(lastAct.indexOf('_') + 1)) + 1;
          String actId = lastAct.substring(0, lastAct.indexOf('_'));
          List list = data['list'].toList();
          Map actData = list.firstWhere((item) => item['id'] == actId);
          if (actData['data'].length >= nextIndex) {
            var data = _deriveData(actData, nextIndex - 1, res[actData['id']]);
            bool isLocked = nextIndex > (actData['data'].length / 2).ceil();
            if (!isLocked || args.paidUser == true) {
              Navigator.pushReplacementNamed(context, '/activity',
                      arguments: ActivityPageArgs(
                          data, args.id, '${actData['id']}_${(nextIndex)}'))
                  .then((_) => setState(() {
                        _res = {};
                        _items = [];
                        _data = {};
                        _lastAct = args.lastAct;
                      }));
              /*
              Navigator.popAndPushNamed(context, '/activity',
                  arguments: ActivityPageArgs(
                      data, args.id, '${actData['id']}_${(nextIndex)}'));*/
              return;
            }
          }
        }
      }
    } catch (e) {
      print('Error: playlistView $e');
    }

    setState(() {
      _items = data["list"];
      _data = data as Map;
      _res = res as Map;
    });
    return data;
  }

  showAct() {}

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as RootID;
    if (_items.length == 0) {
      readJson(args);
    }
    if (_items.length == 0) {
      return Scaffold(
          appBar: MyAppBar(title: _data['label']),
          body: const Padding(
              padding: EdgeInsets.all(15), child: Text('Loading...')));
    }

    return Scaffold(
        appBar: MyAppBar(title: _data['label']),
        /*AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context)),
            title: Text(_data['label'],
                style: const TextStyle(
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.double,
                    fontSize: 25)),
            actions: []),*/
        body: SingleChildScrollView(child: Container(child:
            Consumer<GlobalController>(builder: (context, controller, child) {
          final responses = controller.responses[_data['id']] ?? {};

          return Column(
              children: _items.mapIndexed((i, item) {
            var res = _res[_items[i]['id']]; //responses[_items[i]['id']];
            final isList = _items[i]['data'][0] != null;
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border(
                  bottom:
                      BorderSide(width: 1, color: Colors.lightBlue.shade900),
                ),
              ),
              child: Column(children: [
                Row(children: [
                  Expanded(
                      child: InkWell(
                    onTap: () {
                      Map payload = _items[i] as Map;

                      if (res != null) {
                        payload = {
                          ...payload,
                          'data': {...payload['data'], 'saved': res['response']}
                        };
                      }
                      if (payload['data']['refs'] != null) {
                        String refId = payload['data']['refs'];
                        var refData;
                        if (refId.indexOf('~') != -1) {
                          int refIndex = int.parse(
                              refId.substring(refId.indexOf('~') + 1));
                          refId = refId.substring(0, refId.indexOf('~'));
                          refData = _data["defs"][refId][refIndex];
                        } else {
                          refData = _data["defs"][refId];
                        }
                        if (refData is String) {
                          refData = {'text': refData};
                        } else {
                          refData = {'arr': refData};
                        }
                        Map data = {...payload['data'], ...refData};
                        payload = {...payload, 'data': data};
                      }
                      //pushNamed is changed to popAndPushNamed
                      if (args.lastAct != null) {
                        Navigator.pushReplacementNamed(context, '/activity',
                                arguments: ActivityPageArgs(
                                    payload, _data["id"], _items[i]['id']))
                            .then((_) => setState(() {
                                  _res = {};
                                  _items = [];
                                  _data = {};
                                }));
                      } else {
                        Navigator.pushNamed(context, '/activity',
                                arguments: ActivityPageArgs(
                                    payload, _data["id"], _items[i]['id']))
                            .then((_) => setState(() {
                                  _res = {};
                                  _items = [];
                                  _data = {};
                                }));
                      }

                      ;
                    },
                    child: Text(_items[i]["label"]),
                  )),
                  if (res != null)
                    GestureDetector(
                        onTap: () {
                          /*
                          controller.clearActivity(
                              _data['id'], _items[i]['id']);
                              */
                          Map res = {..._res};
                          var value = res.remove(_items[i]['id']);
                          print('value = $value');
                          DatabaseHelper.instance
                              .removeResponse(json.encode(res), _data["id"]);
                          setState(() {
                            _res = res;
                          });
                        },
                        child: Wrap(children: [
                          Text(res?['score'] != null
                              ? (res['score'].toString() + '%')
                              : 'done'),
                          Icon(
                            Icons.refresh,
                            color: Colors.black,
                            size: 20.0,
                          )
                        ]))
                ]),
                if (isList)
                  Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            alignment: WrapAlignment.start,
                            children: (_items[i]['data'] as List)
                                .mapIndexed((j, unit) => getActBtn(
                                    item: _items[i],
                                    res: res,
                                    pos: j,
                                    playlistId: _data['id'],
                                    paidUser:
                                        controller.user['paidUser'] ?? false,
                                    args: args))
                                .toList(),
                          )))
              ])
              // padding:
              //     EdgeInsets.symmetric(vertical: 9, horizontal: 9),
              ,
            );
          }).toList());
        }))));
  }

  Widget getActBtn({item, res, pos, playlistId, paidUser, args}) {
    bool isLocked = false;
    if (!paidUser) {
      //isLocked = (item['appLockAfter'] ?? item['lockAfter'] ?? 100) < pos;
      isLocked = pos >= (item['data'].toList().length / 2);
    }

    if (isLocked) {
      return ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/asktosubscribe',
            );
          },
          style: ElevatedButton.styleFrom(
              primary: Color(0xffbcdbf7), onPrimary: Colors.black),
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text((pos + 1).toString()),
              const Padding(
                  padding: EdgeInsets.only(left: 7),
                  child: Icon(Icons.lock, color: Color(0xff1b75b7)))
            ],
          ));
    } else {
      return ElevatedButton(
          onPressed: () {
            var data = _deriveData(
              item,
              pos,
              res,
            );
            if (args.lastAct != null) {
              Navigator.pushReplacementNamed(context, '/activity',
                      arguments: ActivityPageArgs(
                          data, playlistId, '${item['id']}_${(pos + 1)}'))
                  .then((_) => setState(() {
                        _res = {};
                        _items = [];
                        _data = {};
                      }));
            } else {
              Navigator.pushNamed(context, '/activity',
                      arguments: ActivityPageArgs(
                          data, playlistId, '${item['id']}_${(pos + 1)}'))
                  .then((_) => setState(() {
                        _res = {};
                        _items = [];
                        _data = {};
                      }));
            }
          },
          style: ElevatedButton.styleFrom(
              primary: res?[(pos + 1).toString()] == null
                  ? Color(0xffbcdbf7)
                  : Color(0xffcda4fe),
              onPrimary: Colors.black),
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (res?[(pos + 1).toString()]?['score'] != null)
                Text((res?[(pos + 1).toString()]?['score'].toString() ?? '') +
                    '%')
              else
                Text((pos + 1).toString()),
            ],
          ));
    }
  }

  Map _deriveData(data, pos, responses) {
    var payload = (data['commonData'] ?? {}) as Map;
    if (data['data'][pos] is String) {
      payload['text'] = data['data'][pos];
    } else if (data['data'][pos] is List) {
      payload['arr'] = data['data'][pos];
    } else {
      if (data['data'][pos]['refs'] != null) {
        var refData;
        String refId = data['data'][pos]['refs'];
        if (refId.indexOf('~') != -1) {
          int refIndex = int.parse(refId.substring(refId.indexOf('~') + 1));
          refId = refId.substring(0, refId.indexOf('~'));
          refData = _data["defs"][refId][refIndex];
        } else {
          refData = _data["defs"][refId];
        }
        if (refData is String) {
          refData = {'text': refData};
        } else {
          refData = {'arr': refData};
        }
        payload = {...payload, ...refData};
      }
      payload = {...payload, ...data['data'][pos]};
    }
    if (responses?[(pos + 1).toString()] != null) {
      payload = {
        ...payload,
        'saved': responses[(pos + 1).toString()]['response']
      };
    }
    return {
      'id': data['id'],
      'label': data['label'],
      'type': data['type'],
      'data': payload
    };
  }
}
