import 'package:shared_preferences/shared_preferences.dart';
// only works in web:
import 'package:web/web.dart' as web;
// The issue is that SharedPreferences in Flutter Web uses a different storage mechanism than browser LocalStorage.
//Flutter Web's SharedPreferences uses IndexedDB, not the browser's LocalStorage API. They don't share the same storage space.

class StorageService {
  // Private constructor
  StorageService._privateConstructor();
  
  // Singleton instance
  static final StorageService _instance = StorageService._privateConstructor();
  
  // Factory constructor to return the same instance
  factory StorageService() {
    return _instance;
  }

  // Read string value
  Future<String?> readString(String key) async {
    try {
      // final prefs = await SharedPreferences.getInstance();
      // return prefs.getString(key);
      // quick fix to only use web:
      return web.window.localStorage.getItem(key);
    } catch (e) {
      throw 'Error reading string for key $key: $e';
    }
  }

  // Read int value
  Future<int?> readInt(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(key);
    } catch (e) {
      throw 'Error reading int for key $key: $e';
    }
  }

  // Read bool value
  Future<bool?> readBool(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key);
    } catch (e) {
      throw 'Error reading bool for key $key: $e';
    }
  }

  // Read double value
  Future<double?> readDouble(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(key);
    } catch (e) {
      throw 'Error reading double for key $key: $e';
    }
  }

  // Read string list
  Future<List<String>?> readStringList(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(key);
    } catch (e) {
      throw 'Error reading string list for key $key: $e';
    }
  }

  // Generic read method that detects type automatically
  Future<dynamic> read(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.get(key);
    } catch (e) {
      throw 'Error reading dynamic key $key: $e';
    }
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(key);
    } catch (e) {
      return false;
    }
  }
}