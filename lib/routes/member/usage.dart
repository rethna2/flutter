import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as Math;
import '../../utils/filesystem.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../../common/globalController.dart';
import '../comps/core.dart';
import '../../common/apiService.dart';

class Usage extends StatefulWidget {
  const Usage({Key? key}) : super(key: key);

  @override
  State<Usage> createState() => _UsageState();
}

class _UsageState extends State<Usage> {
  TextStyle tStyle = const TextStyle(
    color: Color(0xffffffff),
    fontSize: 22,
    height: 1.6,
  );
  TextStyle tStyle2 = const TextStyle(
    fontSize: 16,
    height: 1.6,
  );

  TextStyle tStyle3 = const TextStyle(
    fontSize: 26,
    height: 1.6,
  );

  Map? _data;
  late Map _analytics;
  bool _checkedWork = false;
  @override
  void initState() {
    loadData(false);
    super.initState();
  }

  void loadData(late) async {
    Map analytics = await readFile('analytics') ?? {};
    Map? work = await readFile('work');
    Map data =
        mergeUsage(analytics['dailyUsage'] ?? [], work?['dailyUsage'] ?? []);
    data['updateProgressState'] = (analytics?['savePending'] != null &&
            analytics['savePending'].length > 0)
        ? 'on'
        : 'off'; // 3 states are on, off, done
    setState(() {
      _data = data;
      _analytics = analytics;
      if (late == true) {
        _checkedWork = true;
      }
    });
  }

  Future<void> updateWorkAtBackend(controller) async {
    Map work = await readFile('work') ?? {};
    DateTime now = DateTime.now();
    if (work['date'] != null) {
      DateTime ref = DateTime.fromMillisecondsSinceEpoch(work['date']);
      ref = DateTime(ref.year, ref.month, ref.day + 7);
      if (now.isBefore(ref)) {
        setState(() {
          _checkedWork = true;
        });
        return;
      }
    }
    Map? apiRes =
        await ApiService.get('profile/analytics', controller.user['token']);
    if (apiRes != null && apiRes['error'] != true) {
      List list = apiRes['Items'];
      List dailyUsage = [];
      for (int i = 0; i < list.length; i++) {
        num dur = list[i]['list']
            .toList()
            .fold(0, (accu, item) => accu + item['duration']);
        dailyUsage.add({'date': list[i]['date'], 'duration': dur});
      }
      Map work = {
        'date': DateTime.now().millisecondsSinceEpoch,
        'dailyUsage': dailyUsage
      };
      await writeFile(json.encode(work), 'work');
      loadData(true);
    }
  }

  Widget getTime(str) {
    return RichText(
        text: TextSpan(
            style: TextStyle(fontSize: 26, height: 1.6, color: Colors.black),
            children: [
          TextSpan(
              text: 'hh',
              style:
                  const TextStyle(fontStyle: FontStyle.italic, fontSize: 11)),
          TextSpan(text: str),
          TextSpan(
              text: 'mm',
              style:
                  const TextStyle(fontStyle: FontStyle.italic, fontSize: 11)),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return Text('Loading...');
    }
    ;

    return Consumer<GlobalController>(builder: (context, controller, child) {
      if (_checkedWork == false) {
        updateWorkAtBackend(controller);
      }

      return Column(children: [
        if (_data?['updateProgressState'] == 'on')
          Button(
              label: 'Submit Daily Progress',
              onClick: () async {
                setState(() {
                  _data = {...?_data, 'updateProgressState': 'done'};
                });
                Map user = controller.user;
                String email = user['profile']?['id'];
                String token = user['token'];
                bool status = await updateProgressToServer(
                    _analytics, _analytics['savePending'], email, token);
                if (status == true) {
                  _analytics['savePending'] = [];
                  _analytics['map'] = {};
                  final directory = await getApplicationDocumentsDirectory();
                  final path = directory.path;

                  File file = File('$path/analytics.json');
                  await file.writeAsString(json.encode(_analytics));
                }
              }),
        if (_data?['updateProgressState'] == 'done')
          const Text('Progress Updated', style: TextStyle(fontSize: 20)),
        Container(
            height: 40,
            width: 300,
            decoration: BoxDecoration(
              color: Color(0xffd154ba),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Text('Time Spent Today',
                textAlign: TextAlign.center, style: tStyle)),
        Container(
          width: 260,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(color: Color(0xffbcdbf7), boxShadow: [
            BoxShadow(
              blurRadius: 5.0,
              color: Color(0xff888888),
              offset: Offset(0, 5),
            ),
          ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text('Average Score', style: tStyle2),
                  Text(_data?['score'], style: tStyle3)
                ],
              ),
              Column(
                children: [
                  Text('Time Spent', style: tStyle2),
                  getTime(_data?['duration']),
                ],
              )
            ],
          ),
        ),
        SizedBox(height: 30),
        Container(
            height: 40,
            width: 300,
            decoration: BoxDecoration(
              color: Color(0xffa846d0),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Text('Time Spent Earlier',
                textAlign: TextAlign.center, style: tStyle)),
        Container(
          width: 260,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(color: Color(0xffbcdbf7)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text('Last Week', style: tStyle2),
                  getTime(_data?['weekDuration'])
                ],
              ),
              Column(
                children: [
                  Text('Last Month', style: tStyle2),
                  getTime(_data?['monthDuration'])
                ],
              )
            ],
          ),
        ),
      ]);
    });
  }
}

String _getTimeStr(no) {
  no = (no / 60).floor();
  int hours = (no / 60).floor();
  int mins = no % 60;
  return '${hours < 10 ? '0' : ''}$hours : ${mins < 10 ? '0' : ''}$mins';
}

Map mergeUsage(List local, List server) {
  DateTime now = DateTime.now();
  DateTime weekAgo = DateTime(now.year, now.month, now.day - 7);
  DateTime monthAgo = DateTime(now.year, now.month - 1, now.day);

  List week = [];
  List month = [];
  for (int i = 0; i < server.length; i++) {
    DateTime d = DateTime.parse(server[i]['date']);
    if (d.isAfter(weekAgo)) {
      week.add(server[i]);
    } else {
      //if (d.isAfter(monthAgo)) {
      month.add(server[i]);
    }
  }
  for (int i = local.length - 2; i >= 0; i--) {
    DateTime d = DateTime.parse(local[i]['date']);
    if (d.isAfter(weekAgo)) {
      week.add(local[i]);
    } else if (d.isAfter(monthAgo)) {
      month.add(local[i]);
    }
  }
  week = removeDuplicates(week);
  month = removeDuplicates(month);
  num weekDuration = week.fold(0, (accu, item) => accu + item['duration']);
  num monthDuration = month.fold(0, (accu, item) => accu + item['duration']);
  String dateStr = formatDate(DateTime.now());
  Map? day =
      local.firstWhere((day) => day['date'] == dateStr, orElse: () => null);
  if (day != null) {
    weekDuration += day['duration'];
  }

  monthDuration += weekDuration;

  return {
    'score': (day == null || day['count'] == 0)
        ? '--'
        : '${(day['score'] / day['count']).round()} %',
    'duration': day == null ? '00:00' : _getTimeStr(day['duration']),
    'weekDuration': _getTimeStr(weekDuration),
    'monthDuration': _getTimeStr(monthDuration),
  };
}

List removeDuplicates(List list) {
  List ret = [];
  List dates = [];
  for (int i = 0; i < list.length; i++) {
    if (dates.contains(list[i]['date'])) {
      int index =
          ret.indexWhere((element) => element['date'] == list[i]['date']);
      if (list[i]['duration'] > ret[index]['duration']) {
        ret[index]['duration'] = list[i]['duration'];
      }
    } else {
      ret.add(list[i]);
      dates.add(list[i]['date']);
    }
  }
  return ret;
}
