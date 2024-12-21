part of 'authentication_bloc.dart';

// The AuthenticationEvent class is the base class for all authentication-related events.
sealed class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  // Equatable is used to compare instances of events.
  @override
  List<Object> get props => [];
}

// AuthenticationUserChanged event is triggered when the current user changes.
class AuthenticationUserChanged extends AuthenticationEvent {
  final MyUser? user; // The user object that represents the current user, or null if no user is authenticated

  // Constructor to initialize the event with the user object.
  const AuthenticationUserChanged(this.user);
}