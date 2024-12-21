import 'dart:developer';
import 'package:bloc/bloc.dart';

// Custom BlocObserver to track and log events, changes, transitions, errors, and closure of BLoC  Design Pattern (Business Logic Component).
class SimpleBlocObserver extends BlocObserver {
  @override
  // Called when a new Bloc is created.
	void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    log('onCreate -- bloc: ${bloc.runtimeType}');
  }

  @override
  // Called when a new event is added to a Bloc.
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    log('onEvent -- bloc: ${bloc.runtimeType}, event: $event');
  }

  @override
  // Called when a Bloc's state changes.
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log('onChange -- bloc: ${bloc.runtimeType}, change: $change');
  }

  @override
  // Called when a Bloc transitions from one state to another.
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log('onTransition -- bloc: ${bloc.runtimeType}, transition: $transition');
  }

  @override
  // Called when an error occurs in a Bloc.
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log('onError -- bloc: ${bloc.runtimeType}, error: $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  // Called when a Bloc is closed.
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    log('onClose -- bloc: ${bloc.runtimeType}');
  }
}