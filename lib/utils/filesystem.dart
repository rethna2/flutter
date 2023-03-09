import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
