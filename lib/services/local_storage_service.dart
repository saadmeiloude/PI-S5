import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class LocalStorageService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _appointmentsKey = 'appointments';
  static const String _notificationSettingsKey = 'notification_settings';

  static SharedPreferences? _prefs;

  // Initialize shared preferences
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Get shared preferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'LocalStorageService not initialized. Call initialize() first.',
      );
    }
    return _prefs!;
  }

  // User data persistence
  static Future<void> saveUser(User user) async {
    await prefs.setString(_userKey, user.toJson().toString());
    await prefs.setBool(_isLoggedInKey, true);
  }

  static User? getUser() {
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      try {
        // For demo purposes, we'll parse a basic JSON string
        // In a real app, you'd use proper JSON serialization
        return User(
          id: 'user_123',
          name: 'Mouna Moussa',
          email: 'mouna@gmail.com',
          phone: '+966501234567',
          birthDate: DateTime(1990, 5, 15),
        );
      } catch (e) {
        print('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

  static bool getIsLoggedIn() {
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> clearUser() async {
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Appointment data persistence
  static Future<void> saveAppointments(
    List<Map<String, dynamic>> appointments,
  ) async {
    final jsonString = appointments.toString();
    await prefs.setString(_appointmentsKey, jsonString);
  }

  static List<Map<String, dynamic>> getAppointments() {
    final appointmentsString = prefs.getString(_appointmentsKey);
    if (appointmentsString != null) {
      try {
        // For demo purposes, return empty list
        // In a real app, you'd properly deserialize JSON
        return [];
      } catch (e) {
        print('Error parsing appointments data: $e');
        return [];
      }
    }
    return [];
  }

  // Notification settings persistence
  static Future<void> saveNotificationSettings(
    Map<String, bool> settings,
  ) async {
    settings.forEach((key, value) {
      prefs.setBool(key, value);
    });
  }

  static Map<String, bool> getNotificationSettings() {
    return {
      'appointment_notifications':
          prefs.getBool('appointment_notifications') ?? true,
      'appointment_reminders': prefs.getBool('appointment_reminders') ?? true,
      'new_offers': prefs.getBool('new_offers') ?? false,
      'app_updates': prefs.getBool('app_updates') ?? true,
    };
  }

  // Generic data persistence
  static Future<void> setString(String key, String value) async {
    await prefs.setString(key, value);
  }

  static String? getString(String key) {
    return prefs.getString(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return prefs.getBool(key);
  }

  static Future<void> setInt(String key, int value) async {
    await prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return prefs.getInt(key);
  }

  static Future<void> setDouble(String key, double value) async {
    await prefs.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return prefs.getDouble(key);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await prefs.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    return prefs.getStringList(key);
  }

  static Future<void> remove(String key) async {
    await prefs.remove(key);
  }

  static Future<void> clear() async {
    await prefs.clear();
  }
}
