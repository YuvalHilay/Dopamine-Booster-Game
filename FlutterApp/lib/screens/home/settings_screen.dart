import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final Function(Locale) setLocale;
  final Function(bool) toggleTheme;

  const SettingsScreen(
      {Key? key, required this.setLocale, required this.toggleTheme})
      : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'en'; // Default language is English
  bool _isDarkMode = false; // Default app theme color
  bool _isNotificationEnabled = true;
  bool _isSoundEnabled = true;

  // Function to change language
  void _changeLanguage(String? languageCode) {
    if (languageCode == null) return;

    setState(() {
      _selectedLanguage = languageCode;
    });

    // Update the locale dynamically
    widget.setLocale(
        Locale(languageCode)); // Pass the locale change to the root widget
  }

  // Function to toggle theme (Dark/Light Mode)
  void _handleThemeToggle(bool value) {
    setState(() {
      _isDarkMode = value;
    });

    // Toggle theme in the parent widget
    widget.toggleTheme(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Language Selection
            ListTile(
              title: Text(AppLocalizations.of(context)!
                  .language), // Localized text for "Language"
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                items: [
                  DropdownMenuItem(
                    value: 'en',
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/flags/usa_flag.png', // Path to the U.S. flag image
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8), // Space between flag and text
                        Text(AppLocalizations.of(context)!.english),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'he',
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/flags/il_flag.png', // Path to the Israeli flag image
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8), // Space between flag and text
                        Text(AppLocalizations.of(context)!.hebrew),
                      ],
                    ),
                  ),
                ],
                onChanged: _changeLanguage, // Language change callback
              ),
            ),
            const Divider(),

            // Dark Mode Toggle
            ListTile(
              title: Text(AppLocalizations.of(context)!
                  .darkMode), // Localized text for "Dark Mode"
              trailing: Switch(
                value: _isDarkMode,
                onChanged: _handleThemeToggle,
              ),
            ),
            const Divider(),

            // Notifications Toggle
            ListTile(
              title: Text(AppLocalizations.of(context)!
                  .enableNotifications), // Localized text for "Enable Notifications"
              trailing: Switch(
                value: _isNotificationEnabled,
                onChanged: (value) {
                  setState(() {
                    _isNotificationEnabled = value;
                  });
                },
              ),
            ),
            const Divider(),

            // Sound Effects Toggle
            ListTile(
              title: Text(AppLocalizations.of(context)!
                  .soundEffects), // Localized text for "Sound Effects"
              trailing: Switch(
                value: _isSoundEnabled,
                onChanged: (value) {
                  setState(() {
                    _isSoundEnabled = value;
                  });
                },
              ),
            ),
            const Divider(),

            // App Version Info
            ListTile(
              title: Text(AppLocalizations.of(context)!
                  .appVers), // Localized text for "App Version"
              subtitle: Text(AppLocalizations.of(context)!
                  .vers1), // You can fetch version dynamically
            ),
            const Divider(),

            // Reset Settings Button 
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                      // Reset settings logic goes here
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.defSettings,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
