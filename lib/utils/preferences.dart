import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static final PreferencesManager _instance = PreferencesManager._internal();
  late SharedPreferences _prefs;

  factory PreferencesManager() {
    return _instance;
  }

  PreferencesManager._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String getString(String key) {
    return _prefs.getString(key) ?? '';
  }

  Future<bool> setString(String key, String value) {
    return _prefs.setString(key, value);
  }

  int getInt(String key) {
    return _prefs.getInt(key) ?? 0;
  }

  Future<bool> setInt(String key, int value) {
    return _prefs.setInt(key, value);
  }

  bool getBool(String key) {
    return _prefs.getBool(key) ?? false;
  }

  Future<bool> setBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }
}