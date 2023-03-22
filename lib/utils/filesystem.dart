import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

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
    print('_onCreate');
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
    print('playlistprog = $id, $playlistprog');
    return playlistprog.isEmpty ? {} : playlistprog[0];
  }

  Future<int> removeResponse(String payload, String playlistId) async {
    try {
      print('removeResponse');
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

  Future<int> addResponse(
      response, String playlistId, String activityId, score) async {
    print('addResponse $playlistId $activityId $score $response');

    bool present = false;
    Map payload;
    String actId = activityId;
    int? position = null;
    if (actId.indexOf('_') != -1) {
      actId = actId.substring(0, activityId.indexOf('_'));
      position = int.parse(activityId.substring(activityId.indexOf('_') + 1));
    }
    Database db = await instance.database;
    try {
      List<Map> playlistprog = await db
          .query('playlistProg', where: 'id = ?', whereArgs: [playlistId]);
      print('playlistprog $playlistprog');

      if (!playlistprog.isEmpty) {
        present = true;
        payload = json.decode(playlistprog[0]['payload']);
        if (position == null && payload[actId] != null) {
          return 0;
        } else if (payload[actId] != null && payload[actId][position] != null) {
          return 0;
        }
      } else {
        payload = {};
      }
    } catch (e) {
      print("ERROR Fetch $e");
      return 0;
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
    print('payload $payload');
    Map<String, dynamic> record = {
      'id': playlistId,
      'payload': json.encode(payload),
      "date": DateTime.now().millisecondsSinceEpoch
    };
    print('recort $record');
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
    return result;
  }

  Future<int> add(PlaylistProg playlistProg, String playlistId) async {
    print('add');
    Database db = await instance.database;

    (await db.query('sqlite_master', columns: ['type', 'name'])).forEach((row) {
      print(row.values);
    });

    var playlistprog = await db.query('playlistProg', orderBy: 'date');
    List<PlaylistProg> playlistProgList = playlistprog.isNotEmpty
        ? playlistprog.map((c) => PlaylistProg.fromMap(c)).toList()
        : [];
    var obj = await getPlaylistProgress(playlistProg.id);
    var res;
    print('obj = ${obj['payload']}');
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

    print('res = $res');
    return res;
  }

  void deleteDB() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      await databaseFactory
          .deleteDatabase(join(documentsDirectory.path, 'progress.db'));
      print('deleteDB');
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
  File file = File('$path/$type.json');
  try {
    await file.writeAsString(str);
    return true;
  } catch (e) {
    return false;
  }
}

Future<String> readFile([String type = 'response']) async {
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  File file = File('$path/$type.json');
  bool exists = await file.exists();
  if (exists) {
    final contents = await file.readAsString();
    return contents;
  } else {
    return '';
  }
}
