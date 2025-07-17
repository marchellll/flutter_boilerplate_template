import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

@singleton
class SharedPreferencesHelper {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // String methods
  Future<bool> setString(String key, String value) async {
    return await _prefs!.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  // Bool methods
  Future<bool> setBool(String key, bool value) async {
    return await _prefs!.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  // Int methods
  Future<bool> setInt(String key, int value) async {
    return await _prefs!.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  // Remove method
  Future<bool> remove(String key) async {
    return await _prefs!.remove(key);
  }

  // Clear all
  Future<bool> clear() async {
    return await _prefs!.clear();
  }
}
