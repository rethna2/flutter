import 'package:flutter/material.dart';
import './globalService.dart';
import '../../utils/filesystem.dart';
import '../../utils/utils.dart';
import 'dart:convert';
import './cognitoService.dart';
import './apiService.dart';

import 'package:http/http.dart' as http;

class RootID {
  final String id;
  String? lastAct;
  bool? paidUser;
  bool? isBack;
  RootID(this.id, [this.lastAct, this.paidUser, this.isBack]);
}

class GlobalController with ChangeNotifier {
  GlobalController(this._globalService, context, appConfig) {
    responses = {};
    config = appConfig;
    user = {
      'userPref': {'grade': 'all', 'clapSound': true},
      'paidUser': config['freeApp'] ?? false
    };
    loadSettings();
    // In freeApp all users are considered as paidUser
  }

  final GlobalService _globalService;

  late ThemeMode _themeMode;

  late Map responses;
  late Map user;
  late Map config;
  String version = "1.0.0";

  ThemeMode get themeMode => _themeMode;

  Future<void> loadSettings() async {
    _themeMode = await _globalService.themeMode();

    String userStr = await readFile('user');
    if (userStr != '') {
      user = json.decode(userStr) as Map;
    }
    String str = await readFile("response");
    Map res = {};
    if (str != '') {
      res = json.decode(str) as Map;
      // res = res[id] ?? {};
    }
    responses = res;
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    notifyListeners();
    // Persist the changes to a local database or the internet
    await _globalService.updateThemeMode(newThemeMode);
  }

  Future<void> updateResponse(response, playlistId, activityId, score) async {
    responses = {...responses};
    if (!responses.containsKey(playlistId)) {
      responses[playlistId] = {};
    }
    if (responses[playlistId][activityId] != null) {
      return;
    }
    var obj = {};
    /*
    if (response is List) {
      obj['score'] =
          response.where((item) => item['right'] == true).toList().length /
              response.length;
      obj['score'] = (obj['score'] * 100).round();
    }
    */
    if (score != null) {
      obj['score'] = score;
    }
    obj['response'] = response;
    if (activityId.indexOf('_') == -1) {
      responses[playlistId][activityId] = obj;
    } else {
      String actId = activityId.substring(0, activityId.indexOf('_'));
      int position =
          int.parse(activityId.substring(activityId.indexOf('_') + 1));
      if (!responses[playlistId].containsKey(actId)) {
        responses[playlistId][actId] = {};
      }
      responses[playlistId][actId][position] = obj;
    }
    try {
      bool success = false; //await writeFile(json.encode(responses));
      print('success $success $obj');
      PlaylistProg playlistProg = PlaylistProg(
          id: playlistId,
          payload: json.encode(obj),
          date: DateTime.now().millisecondsSinceEpoch);

      print('beforeSave ${playlistProg.toMap()}');
      await DatabaseHelper.instance.add(playlistProg, playlistId);
    } catch (e) {
      print('Error!! write failed : $e');
    }
    notifyListeners();
  }

  Future<void> clearActivity(playlistId, activityId, [activityIndex]) async {
    responses = {...responses};
    if (activityIndex == null) {
      responses[playlistId].remove(activityId);
    }
    try {
      bool success = await writeFile(json.encode(responses));
    } catch (e) {
      print('Erroring writing file: ${e.toString()}');
    }

    notifyListeners();
  }

  Future<void> clearLocalData() async {
    responses = {};
    bool success = await writeFile(json.encode(responses));
  }

  Future<void> clearPlaylistData(playlistId) async {
    responses = {...responses};
    if (playlistId == null) {
      responses.remove(playlistId);
    }
    bool success = await writeFile(json.encode(responses));
  }

  void updateVersion() {
    version += '.9';
    notifyListeners();
  }

  Future<void> updateUserPref(String key, dynamic value) async {
    Map userPref = {};
    if (user['userPref'] != null) {
      userPref = user['userPref'];
    }
    userPref = {
      ...userPref,
    };
    userPref[key] = value;
    print('updateUserPref = $userPref');
    user = {...user, 'userPref': userPref};
    await writeFile(json.encode(user), 'user');
    notifyListeners();
  }

  Future<void> clearUserPref() async {
    user = {...user, 'userPref': {}};
    await writeFile(json.encode(user), 'user');
    notifyListeners();
  }

  Future<String> login(String email, String password) async {
    Map response = await CognitoService.login(email, password);
    if (response['error']) {
      return response['message'];
    }

    Map apiRes = await ApiService.getProfile(response['token'], user);
    if (apiRes['error']) {
      return apiRes['message'];
    }

    user = apiRes['user'];
    bool success = await writeFile(json.encode(user), 'user');
    if (success) {
      return 'success';
    } else {
      return 'Something Went Wrong!';
    }
  }

  Future<void> logout() async {
    user.remove('profile');
    user.remove('token');
    user.remove('tokenDate');
    user.remove('paidUser');
    user.remove('everSubscribed');
    user.remove('subscribedTill');
    bool success = await writeFile(json.encode(user), 'user');
    notifyListeners();
  }

  Future<String> signup(String email, String password) async {
    return await CognitoService.signup(email, password);
  }

  Future<String> resendConfirmationCode(String email) async {
    return await CognitoService.resendConfirmationCode(email);
  }

  Future<String> confirmRegistration(
      String otp, String email, String password) async {
    String res = await CognitoService.confirmRegistration(otp, email, password);
    if (res == 'success') {
      return await login(email, password);
    } else {
      return res;
    }
  }

  Future<String> forgetPassword(String email) async {
    return await CognitoService.forgetPassword(email);
  }

  Future<String> confirmPassword(
      String otp, String email, String password) async {
    String res = await CognitoService.confirmPassword(otp, email, password);
    if (res == 'success') {
      return await login(email, password);
    } else {
      return res;
    }
  }

  Future<bool> updateSession() async {
    int now = DateTime.now().millisecondsSinceEpoch;

    // 28 * 24 * 60 * 60 * 1000 - 28 days;
    if (user['tokenDate'] + 2419200000 < now) {
      Map res = await CognitoService.updateSession();
      if (res['error']) {
        await logout();
        return false;
      }
      user = {...user, 'token': res['token'], 'tokenDate': now};
      bool success = await writeFile(json.encode(user), 'user');
      return success;
    }
    return true;
  }

  Future<Map> getPaymentInfo() async {
    await updateSession();
    return await ApiService.getPaymentInfo(user['token']);
  }

  Future<void> getProfile() async {
    Map apiRes = await ApiService.getProfile(user['token'], user);
    if (!apiRes['error']) {
      user = apiRes['user'];
      bool success = await writeFile(json.encode(user), 'user');
      notifyListeners();
    }
  }

  Future<void> testApi() async {
    await updateSession();
  }
}
