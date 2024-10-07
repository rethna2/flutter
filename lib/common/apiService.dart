import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/utils.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ApiService {
  static String url =
      'https://pavinzsivc.execute-api.ap-south-1.amazonaws.com/dev/';
  //'https://v25einw5z1.execute-api.ap-south-1.amazonaws.com/dev/';
  //Fetches profile data from DB and update user
  static Future<Map> getProfile(token, user) async {
    try {
      http.Response res = await http.get(Uri.parse('${url}profile'), headers: {
        'Authorization': token,
        'Content-Type': 'application/json'
      });
      if (res.statusCode.toString()[0] == '2') {
        Map data = jsonDecode(res.body);

        int subDate = getPaymentMap(data['profile']);
        int tillDate = subDate + 31536000000; // plus one year;
        int now = DateTime.now().millisecondsSinceEpoch;
        user = {
          ...user,
          'profile': data['profile'],
          'token': token,
          'tokenDate': now,
          'paidUser': now < tillDate,
          'everSubscribed': subDate != 0,
          'subscribedTill': getDate(tillDate)
        };
        return {'error': false, 'user': user};
      } else {
        return {'error': true, 'message': res.body.toString()};
      }
    } catch (e) {
      return {'error': true, 'message': e.toString()};
    }
  }

  static Future<Map?> get(String route, token) async {
    bool result = await InternetConnection().hasInternetAccess;
    if (!result) {
      return {'error': true, 'message': 'Network Unavailable'};
    }
    try {
      http.Response res = await http.get(Uri.parse('${url}${route}'), headers: {
        'Authorization': token,
        'Content-Type': 'application/json'
      });
      if (res.statusCode.toString()[0] == '2') {
        Map data = jsonDecode(res.body);
        return data;
      } else {
        return {'error': true, 'message': res.body.toString()};
      }
    } catch (e) {
      return {'error': true, 'message': e.toString()};
    }
  }

  static Future<Map?> post(String route, token, Map body, Map config) async {
    String _url = config['url'] ?? url;
    bool result = await InternetConnection().hasInternetAccess;
    if (!result) {
      return {'error': true, 'message': 'Network Unavailable'};
    }
    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = token;
    }
    try {
      http.Response res = await http.post(Uri.parse('${_url}${route}'),
          body: jsonEncode(body), headers: headers);
      if (res.statusCode.toString()[0] == '2') {
        Map data = jsonDecode(res.body);
        return data;
      } else {
        return {'error': true, 'message': res.body.toString()};
      }
    } catch (e) {
      return {'error': true, 'message': e.toString()};
    }
  }

  static Future<Map> getPaymentInfo(token) async {
    try {
      var res = await http.post(Uri.parse('${url}profile/payment'),
          headers: {'Authorization': token, 'Content-Type': 'application/json'},
          body: jsonEncode({
            'isTest': false,
            'clientVersion': 'Android PSchool',
            'newApp': true
          }));
      if (res.statusCode.toString()[0] == '2') {
        Map data = jsonDecode(res.body);
        return {'error': false, 'data': data};
      } else {
        return {'error': true, 'message': res.body.toString()};
      }
    } catch (e) {
      return {'error': true, 'message': e.toString()};
    }
  }
}

//https://medium.com/flutter-community/handling-network-calls-like-a-pro-in-flutter-31bd30c86be1
/*
dynamic _returnResponse(http.Response response) {
  switch (response.statusCode) {
    case 200:
      //var responseJson = json.decode(response.body.toString());
      final parsed = jsonDecode(response.body);
    
      return parsed;
    case 400:
      throw BadRequestException(response.body.toString());
    case 401:
    case 403:
      throw UnauthorisedException(response.body.toString());
    case 500:
    default:
      throw FetchDataException(
          'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
  }
  */