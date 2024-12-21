part of 'sign_up_bloc.dart';

// The SignUpEvent class is the base class for all events related to sign-up actions.
sealed class SignUpEvent extends Equatable {
  const SignUpEvent();

  // Equatable is used to compare instances of events.
  @override
  List<Object> get props => [];
}
// SignUpRequired event is triggered when a user attempts to sign up.
class SignUpRequired extends SignUpEvent {
  final MyUser user;
  final String password;

  // Constructor to initialize the event with a user object and password.
  const SignUpRequired(this.user, this.password);

  @override
  List<Object> get props => [user, password];
}
