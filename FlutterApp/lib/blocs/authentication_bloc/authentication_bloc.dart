import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

// The AuthenticationBloc class manages authentication-related events and states.
class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;
  late final StreamSubscription<MyUser?> _userSubscription;  // Subscription to listen for user changes.

  // Constructor initializes the bloc with the user repository.
  AuthenticationBloc({
    required this.userRepository
  }) : super(const AuthenticationState.unknown()) {
    _userSubscription = userRepository.user.listen((user) {
      add(AuthenticationUserChanged(user));   // Add the AuthenticationUserChanged event when the user changes
    });

    // Handle the AuthenticationUserChanged event to update the state based on user status.
    on<AuthenticationUserChanged>((event, emit) {
      if(event.user != MyUser.empty) {
        emit(AuthenticationState.authenticated(event.user!));
      } else {
        emit(const AuthenticationState.unauthenticated());
      }
    });
  }

  // Close the subscription when the bloc is closed.
  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}