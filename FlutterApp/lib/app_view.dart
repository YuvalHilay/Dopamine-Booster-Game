import 'package:Dopamine_Booster/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:Dopamine_Booster/screens/auth/blocs/sign_in_bloc/bloc/sign_in_bloc.dart';
import 'package:Dopamine_Booster/screens/home/home_screen_controller.dart';
import 'package:Dopamine_Booster/theme/dark_mode.dart';
import 'package:Dopamine_Booster/theme/light_mode.dart';
import 'package:Dopamine_Booster/utils/PreferencesService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'screens/auth/views/welcome_screen.dart';
import 'screens/home/home_menu/contact_screen.dart';
import 'screens/home/home_menu/help_screen.dart';
import 'screens/home/home_menu/settings_screen.dart';

class MyAppView extends StatefulWidget {
  const MyAppView({super.key});

  @override
  _MyAppViewState createState() => _MyAppViewState();
}

class _MyAppViewState extends State<MyAppView> with WidgetsBindingObserver {
  // PreferencesService instance
  final PreferencesService _preferencesService = PreferencesService();
  // Default values for locale and theme
  Locale _locale = const Locale('en');
  bool _isDarkMode = false; // Default theme is Light Mode
  bool _isSoundEnabled = true; // Default  sound is enabled 
  bool _isNotificationsEnabled = true; // Default notifications are enabled


  @override
  void initState() {
    super.initState();
    // Add this widget as a lifecycle observer
    WidgetsBinding.instance.addObserver(this);
    // Load user preferences
    _loadPreferences();
  }

  @override
  void dispose() {
    // Remove this widget as a lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Detect app closure
    if (state == AppLifecycleState.detached || state == AppLifecycleState.inactive) {
      _logOut();
    }
    super.didChangeAppLifecycleState(state);
  }

  void _logOut() {
    final authBloc = context.read<AuthenticationBloc>();
    if (authBloc.state.status == AuthenticationStatus.authenticated) {
      authBloc.userRepository.logOut();
    }
  }

  Future<void> _loadPreferences() async {
    _locale = Locale(await _preferencesService.getLanguage());
    _isDarkMode = await _preferencesService.isDarkMode();
    _isSoundEnabled = await _preferencesService.isSoundEnabled();
    _isNotificationsEnabled = await _preferencesService.isNotificationsEnabled();
    setState(() {});
  }

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    _preferencesService.setLanguage(locale.languageCode); // Save preference
  }

  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _isDarkMode = isDarkMode;
    });
    _preferencesService.setDarkMode(isDarkMode); // Save preference
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dopamine Booster',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('he'), // Hebrew
      ],
      locale: _locale, // Dynamically set locale
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light, // Set theme dynamically
      initialRoute: '/',
      routes: {
        '/help': (context) => const HelpScreen(),
        '/contact': (context) => const ContactScreen(),
        '/settings': (context) => SettingsScreen(setLocale: _setLocale, toggleTheme: _toggleTheme),
      },
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state.status == AuthenticationStatus.authenticated) {
            return BlocProvider(
              create: (context) => SignInBloc(
                  context.read<AuthenticationBloc>().userRepository),
              child: HomeScreenController.getHomeScreen(state.user),
            );
          } else {
            return const WelcomeScreen();
          }
        },
      ),
    );
  }
}
