import 'package:Dopamine_Booster/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:Dopamine_Booster/screens/auth/blocs/sign_in_bloc/bloc/sign_in_bloc.dart';
import 'package:Dopamine_Booster/screens/home/contact_screen.dart';
import 'package:Dopamine_Booster/screens/home/help_screen.dart';
import 'package:Dopamine_Booster/screens/home/home_screen_controller.dart';
import 'package:Dopamine_Booster/screens/home/settings_screen.dart';
import 'package:Dopamine_Booster/theme/dark_mode.dart';
import 'package:Dopamine_Booster/theme/light_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'screens/auth/views/welcome_screen.dart';

class MyAppView extends StatefulWidget {
  const MyAppView({super.key});

  @override
  _MyAppViewState createState() => _MyAppViewState();
}

class _MyAppViewState extends State<MyAppView> {
  // Default values for locale and theme
  Locale _locale = const Locale('en');
  bool _isDarkMode = false; // Default theme is Light Mode

  // Method to change the locale dynamically
  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  // Method to toggle the theme (Light/Dark Mode)
  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
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
