import 'package:Dopamine_Booster/app.dart';
import 'package:Dopamine_Booster/simple_bloc_observer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initializes Firebase in the application.
  await Firebase.initializeApp();
  // Sets a global Bloc observer to monitor Bloc lifecycle events.
  Bloc.observer = SimpleBlocObserver();
  // Runs the application and injects the FirebaseUserRepo as a dependency.
  runApp(MyApp(FirebaseUserRepo()));
}