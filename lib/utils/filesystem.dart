import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'dart:math' as Math;
import '../../common/apiService.dart';
import '../config.dart';

int offset = 0;

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'progress.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
CREATE TABLE playlistProg(
  id TEXT PRIMARY KEY,
  payload TEXT,
  date INTEGER
)
''');
  }

  Future<List<PlaylistProg>> getPlaylistProgressList() async {
    Database db = await instance.database;
    var playlistprog = await db.query('playlistProg', orderBy: 'date');
    List<PlaylistProg> playlistProgList = playlistprog.isNotEmpty
        ? playlistprog.map((c) => PlaylistProg.fromMap(c)).toList()
        : [];
    return playlistProgList;
  }

  Future<Map> getPlaylistProgress(String id) async {
    Database db = await instance.database;
    List<Map> playlistprog =
        await db.query('playlistProg', where: 'id = ?', whereArgs: [id]);
    /*
    List<PlaylistProg> playlistProgList = playlistprog.isNotEmpty
        ? playlistprog.map((c) => PlaylistProg.fromMap(c)).toList()
        : [];
    return playlistProgList;
    */
    return playlistprog.isEmpty ? {} : playlistprog[0];
  }

  Future<int> removeResponse(String payload, String playlistId) async {
    try {
      Database db = await instance.database;
      var result = await db.update(
          'playlistProg',
          {
            'id': playlistId,
            'payload': payload,
            'date': DateTime.now().millisecondsSinceEpoch
          },
          where: "id = ?",
          whereArgs: [playlistId]);
      print(' removeResponse $result');
      return result;
    } catch (e) {
      print('Error removeResponse $e');
      return 0;
    }
  }

  Future<int> removePlaylistResponse(String playlistId) async {
    try {
      Database db = await instance.database;
      var result = await db
          .delete('playlistProg', where: "id = ?", whereArgs: [playlistId]);
      return result;
    } catch (e) {
      print('Error removePlaylistResponse $e');
      return 0;
    }
  }

  Future<String> addResponse(response, String playlistId, String activityId,
      score, actsCount, startTime, user) async {
    bool present = false;
    Map payload;
    String actId = activityId;
    String resultStr = '';
    int? position = null;
    if (actId.indexOf('_') != -1) {
      actId = actId.substring(0, activityId.indexOf('_'));
      position = int.parse(activityId.substring(activityId.indexOf('_') + 1));
    }
    Database db = await instance.database;
    try {
      List<Map> playlistprog = await db
          .query('playlistProg', where: 'id = ?', whereArgs: [playlistId]);

      if (playlistprog.isNotEmpty) {
        present = true;
        payload = json.decode(playlistprog[0]['payload']);
        if (position == null && payload[actId] != null) {
          return resultStr;
        } else if (payload[actId] != null && payload[actId][position] != null) {
          return resultStr;
        }
      } else {
        payload = {};
      }
    } catch (e) {
      print("ERROR Fetch $e");
      return resultStr;
    }

    var obj = {};
    obj['response'] = response;
    if (score != null) {
      obj['score'] = score;
    }

    if (position == null) {
      payload[actId] = obj;
    } else {
      if (!payload.containsKey(actId)) {
        payload[actId] = {};
      }
      payload[actId][position.toString()] = obj;
    }
    Map<String, dynamic> record = {
      'id': playlistId,
      'payload': json.encode(payload),
      "date": DateTime.now().millisecondsSinceEpoch
    };
    var result = 0;
    try {
      if (present == false) {
        result = await db.insert('playlistProg', record);
      } else {
        result = await db.update('playlistProg', record,
            where: "id = ?", whereArgs: [playlistId]);
      }
    } catch (e) {
      print('ERROR WRITING $e');
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;

    Future<bool> updateMasterProg() async {
      num count = 0;
      num score = 0;
      num scoreCount = 0;
      for (var k in payload.keys) {
        if (payload[k]['response'] != null) {
          if (payload[k]['score'] != null) {
            score += payload[k]['score'];
            scoreCount += 1;
          }
          count++;
        } else {
          for (var m in payload[k].keys) {
            if (payload[k][m] != null && payload[k][m]['score'] != null) {
              score += payload[k][m]['score'];
              scoreCount += 1;
            }
            count++;
          }
        }
      }

      File file = File('$path/masterProg.json');
      bool exists = await file.exists();
      Map content = {};
      if (exists) {
        final contentStr = await file.readAsString();
        content = json.decode(contentStr) as Map;
      }
      try {
        content[playlistId] = {
          'score': (score / scoreCount).round(),
          'progress': (count / actsCount * 100).round()
        };
        await file.writeAsString(json.encode(content));
        return true;
      } catch (e) {
        return false;
      }
    }

    Future<bool> updateAnalytics() async {
      File file = File('$path/analytics.json');
      bool exists = await file.exists();
      Map data = {};
      print('paidUser exists = $exists');
      if (exists) {
        final contentStr = await file.readAsString();
        data = json.decode(contentStr) as Map;
      } else {
        data = getInitAnalytics();
      }
      int LIMIT = 300;
      DateTime dateNow = DateTime.now();
      int duration =
          ((dateNow.millisecondsSinceEpoch - startTime) / 1000).round();
      if (duration > 300) {
        duration = 300;
      }
      print('paidUser before = ${data['offset']}');
      data['offset'] += duration;
      String? email = user['profile']?['id'];
      //bool? paidUser = user['paidUser'];
      bool paidUser = true;
      print('paidUser = $paidUser ${data['offset']}');

      if (data['offset'] >= LIMIT) {
        data['offset'] = 0;
        if (paidUser != true) {
          resultStr = 'askToSubscribe';
        }
      }
      /*
      if (user['notification'] == null &&
          config['appId'] == 'com.gotowisdom.pschool') {
        resultStr = 'collectInfo';
      }
      */
      String dateStr = formatDate(dateNow);
      if (data['savePending'].indexOf(dateStr) == -1) {
        data['savePending'].add(dateStr);
      }
      if (!data['map'].containsKey(dateStr)) {
        data['map'][dateStr] = [];
      }

      Map analyticObj = {
        'url': '${playlistId}/${activityId}',
        'score': score,
        'duration': duration,
        'time': dateNow.millisecondsSinceEpoch
      };
      int pos =
          data['dailyUsage'].indexWhere((item) => item['date'] == dateStr);
      if (pos == -1) {
        data['dailyUsage'].add({
          'date': dateStr,
          'duration': Math.min(180, duration),
          'score': score ?? 0,
          'count': score == 0 ? 0 : 1
        });
      } else {
        data['dailyUsage'][pos]['duration'] += Math.min(180, duration);
        data['dailyUsage'][pos]['score'] += score ?? 0;
        data['dailyUsage'][pos]['count'] += score == 0 ? 0 : 1;
      }
      data['map'][dateStr].add(analyticObj);
      if (!user.containsKey('token')) {
        await file.writeAsString(json.encode(data));
        return false;
      }
      List forSave =
          data['savePending'].where((item) => item != dateStr).toList();
      if (forSave.isNotEmpty) {
        bool status =
            await updateProgressToServer(data, forSave, email, user['token']);
        if (status == true) {
          data['savePending'] =
              data['savePending'].where((date) => date != dateStr);
          forSave.forEach((element) {
            data['map'].remove(element);
          });
        }
      }
      await file.writeAsString(json.encode(data));

      return false;
    }

    bool res = await updateMasterProg();
    res = await updateAnalytics();
    return resultStr;
  }

  Future<int> add(PlaylistProg playlistProg, String playlistId) async {
    Database db = await instance.database;

    (await db.query('sqlite_master', columns: ['type', 'name']))
        .forEach((row) {});

    var playlistprog = await db.query('playlistProg', orderBy: 'date');
    List<PlaylistProg> playlistProgList = playlistprog.isNotEmpty
        ? playlistprog.map((c) => PlaylistProg.fromMap(c)).toList()
        : [];
    var obj = await getPlaylistProgress(playlistProg.id);
    var res;

    try {
      if (obj['payload'] == null) {
        res = await db.insert('playlistProg', playlistProg.toMap());
      } else {
        res = await db.update('playlistProg', playlistProg.toMap(),
            where: "id = ?", whereArgs: [playlistProg.id]);
      }
    } catch (e) {
      print('ERROR WRITING $e');
    }
    return res;
  }

  void deleteDB() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      await databaseFactory
          .deleteDatabase(join(documentsDirectory.path, 'progress.db'));
    } catch (e) {
      print('ERROR!! $e');
    }
  }
}

class PlaylistProg {
  final String id;
  final String payload;
  final int? date;
  PlaylistProg({required this.id, required this.payload, this.date});

  factory PlaylistProg.fromMap(Map<String, dynamic> json) => PlaylistProg(
      id: json['id'], payload: json['payload'], date: json['date']);

  Map<String, dynamic> toMap() {
    return {'id': id, 'payload': payload, 'date': date};
  }
}

Future<bool> writeFile(String str, [String type = 'response']) async {
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  File file = File('$path/${type}.json');
  try {
    await file.writeAsString(str);
    return true;
  } catch (e) {
    return false;
  }
}

Future<Map?> readFile([String type = 'response']) async {
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  File file = File('$path/$type.json');
  bool exists = await file.exists();
  if (exists) {
    final contents = await file.readAsString();
    return json.decode(contents) as Map;
  } else {
    return null;
  }
}

Future<bool> deleteFile([String type = 'response']) async {
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  File file = File('$path/$type.json');
  bool exists = await file.exists();
  if (exists) {
    await file.delete();
    return true;
  } else {
    return false;
  }
}

Map getInitAnalytics() {
  List temp_id = 'abcdefghijklmnopqrstuvwxyz'.split('');
  Math.Random rand = Math.Random();
  temp_id.sort((a, b) => (rand.nextDouble() > 0.5 ? -1 : 1));
  return {
    'temp_id': temp_id.join(''),
    'offset': 0,
    'dailyUsage': [],
    'savePending': [],
    'map': {}
  };
}

String formatDate(DateTime d) {
  return '${d.year}-${d.month < 10 ? '0' : ''}${d.month}-${d.day < 10 ? '0' : ''}${d.day}';
}

Future<bool> updateProgressToServer(data, saveDates, ownerId, token) async {
  List dataArr = [];
  for (int i = 0; i < saveDates.length; i++) {
    if (data['map'].containsKey(saveDates[i])) {
      dataArr.add({'date': saveDates[i], 'list': data['map'][saveDates[i]]});
    }
  }
  Map payload = {'owner_id': ownerId, 'dataArr': dataArr, 'cv': 'pschoolApp'};
  Map? res = await ApiService.post('', token, payload,
      {'url': 'https://c7rpn9er0d.execute-api.ap-south-1.amazonaws.com'});
  if (res == null || res['error'] != null) {
    return false;
  } else {
    return true;
  }
}
