import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Save email to SharedPreferences
Future<void> saveEmail(String email) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('saved_email', email);
}

// Retrieve the saved email
Future<String?> getSavedEmail() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('saved_email');
}

// Remove the saved email
Future<void> removeSavedEmail() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('saved_email');
}
  // Save whether sound is enabled
  Future<void> setSoundEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', isEnabled);
  }

  // Retrieve whether sound is enabled
  Future<bool> isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('sound_enabled') ?? true; // Default is true
  }

  // Save whether notifications are enabled
  Future<void> setNotificationsEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', isEnabled);
  }

  // Retrieve whether notifications are enabled
  Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true; // Default is true
  }

  // Save selected language
  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
  }

  // Retrieve selected language
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? 'en'; // Default is English
  }

  // Save theme mode
  Future<void> setDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDarkMode);
  }

  // Retrieve theme mode
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('dark_mode') ?? false; // Default is Light Mode
  }

  // Save the timer's end timestamp
  Future<void> setTimerEndTimestamp(int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('timer_end_timestamp', timestamp);
  }

  // Retrieve the timer's end timestamp
  Future<int?> getTimerEndTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('timer_end_timestamp');
  }

  // Clear the timer's end timestamp
  Future<void> clearTimerEndTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('timer_end_timestamp');
  }

   // Retrieve the APK installation status from SharedPreferences
  Future<bool?> getAPKInstalledStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool? installed = prefs.getBool('apk_installed');
    
    // Debugging: log the status of 'apk_installed' to ensure it's set correctly
    print("APK Installed Status: $installed");
    
    return installed;
  }

  // Set the APK installation status to SharedPreferences
  Future<void> setAPKInstalledStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('apk_installed', status);

    // Debugging: log the status being saved
    print("APK Installed Status Saved: $status");
  }
}
