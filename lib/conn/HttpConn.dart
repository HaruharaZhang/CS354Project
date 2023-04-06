import 'dart:io';

import 'package:http/http.dart' as http;

class HttpConn {

  static String getDefaultUrl() {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8080/webapi/event_server";
    } else {
      return "http://127.0.0.1:8080/webapi/event_server";
    }
  }

  static Future<bool> sendUserToken(String userToken) async {
    String url = '${getDefaultUrl()}/user/setUserToken/$userToken';
    try {
      final response = await http.get(Uri.parse(url));
      if(response.statusCode==200){
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }
}
