import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'app_view.dart';
import 'blocs/authentication_bloc/authentication_bloc.dart';

// The main application class which acts as the root of the Flutter app.
class MyApp extends StatelessWidget {
  // A repository to handle user-related operations, injected into the app.
  final UserRepository userRepository;

  // Constructor to initialize the app with the UserRepository instance.
  const MyApp(this.userRepository, {super.key});

  @override
  Widget build(BuildContext context) {
    // Provides the AuthenticationBloc to the widget tree, enabling state management
    // for authentication throughout the app.
    return RepositoryProvider<AuthenticationBloc>(
      // Creates an instance of AuthenticationBloc using the provided UserRepository.
      create: (context) => AuthenticationBloc(userRepository: userRepository),
      // Builds the main view of the application.
      child: const MyAppView(),
    );
  }
}
