import 'dart:ffi';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class GlobalVariable {
  static const String _globalAutoRefresh = 'globalAutoRefresh';
  static const String _userLanguage = 'userLanguage';
  static const String _userScope = 'userScope';

  static Future<bool> getAutoRefreshEnable({bool defaultValue = true}) async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_globalAutoRefresh) ?? defaultValue;
  }
  static Future<void> setAutoRefreshEnable(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_globalAutoRefresh, value);
  }

  static Future<String> getUserLanguage() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userLanguage) ?? 'en';
  }
  static Future<void> setUserLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_userLanguage, value);
  }

  static Future<num> getUserScope() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_userScope) ?? 2;
  }
  static Future<void> setUserScope(double value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(_userScope, value);
  }

}
