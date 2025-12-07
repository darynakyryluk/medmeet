import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyCurrentUserId = 'current_user_id';
  static const String _keySavedAccounts = 'saved_accounts'; 

  
  static Future<void> addAccount(int id) async {
    final prefs = await SharedPreferences.getInstance();

    
    List<String> saved = prefs.getStringList(_keySavedAccounts) ?? [];

    
    if (!saved.contains(id.toString())) {
      saved.add(id.toString());
      await prefs.setStringList(_keySavedAccounts, saved);
    }

    
    await prefs.setInt(_keyCurrentUserId, id);
  }

  
  static Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCurrentUserId);
  }

  
  static Future<List<int>> getSavedAccountIds() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList(_keySavedAccounts) ?? [];
    return saved.map((e) => int.parse(e)).toList();
  }

  
  static Future<void> switchAccount(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentUserId, id);
  }

  
  static Future<void> removeAccount(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList(_keySavedAccounts) ?? [];

    saved.remove(id.toString());
    await prefs.setStringList(_keySavedAccounts, saved);

    
    int? current = prefs.getInt(_keyCurrentUserId);
    if (current == id) {
      await prefs.remove(_keyCurrentUserId);
    }
  }

  
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}