import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  final Function(Locale) setLocale;
  final Function(bool) toggleTheme;

  const SettingsScreen({
    Key? key,
    required this.setLocale,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'en';
  bool _isDarkMode = false;
  bool _isNotificationEnabled = true;
  bool _isSoundEnabled = true;

  void _changeLanguage(String? languageCode) {
    if (languageCode == null) return;
    setState(() {
      _selectedLanguage = languageCode;
    });
    widget.setLocale(Locale(languageCode));
  }

  void _handleThemeToggle(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    widget.toggleTheme(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[50]!, Colors.purple[50]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildSettingCard(
                title: AppLocalizations.of(context)!.language,
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  items: _buildLanguageItems(context),
                  onChanged: _changeLanguage,
                  underline: Container(),
                ),
              ),
              _buildSettingCard(
                title: AppLocalizations.of(context)!.darkMode,
                child: Switch(
                  value: _isDarkMode,
                  onChanged: _handleThemeToggle,
                ),
              ),
              _buildSettingCard(
                title: AppLocalizations.of(context)!.enableNotifications,
                child: Switch(
                  value: _isNotificationEnabled,
                  onChanged: (value) => setState(() => _isNotificationEnabled = value),
                ),
              ),
              _buildSettingCard(
                title: AppLocalizations.of(context)!.soundEffects,
                child: Switch(
                  value: _isSoundEnabled,
                  onChanged: (value) => setState(() => _isSoundEnabled = value),
                ),
              ),
              _buildSettingCard(
                title: AppLocalizations.of(context)!.appVers,
                child: Text(
                  AppLocalizations.of(context)!.vers1,
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Reset settings logic goes here
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary, 
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.defSettings,
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildLanguageItems(BuildContext context) {
    return [
      DropdownMenuItem(
        value: 'en',
        child: Row(
          children: [
            Image.asset('assets/flags/usa_flag.png', width: 24, height: 24),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.english, style: GoogleFonts.poppins()),
          ],
        ),
      ),
      DropdownMenuItem(
        value: 'he',
        child: Row(
          children: [
            Image.asset('assets/flags/il_flag.png', width: 24, height: 24),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.hebrew, style: GoogleFonts.poppins()),
          ],
        ),
      ),
    ];
  }
}

