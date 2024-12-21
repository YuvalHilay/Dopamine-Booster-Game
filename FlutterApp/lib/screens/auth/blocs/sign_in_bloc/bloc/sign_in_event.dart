part of 'sign_in_bloc.dart';

// The SignInEvent class is the base class for all events related to sign-in actions.
sealed class SignInEvent extends Equatable {
  const SignInEvent();
  // Equatable is used to compare instances of events.
  @override
  List<Object> get props => [];
}

// SignInRequired event is triggered when a user attempts to sign in
class SignInRequired extends SignInEvent {
  final String email;
  final String password;

  // Constructor to initialize the event with email and password.
  const SignInRequired(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

// SignOutRequired event is triggered when a user requests to sign out, no data just event trigger.
class SignOutRequired extends SignInEvent {}
