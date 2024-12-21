part of 'authentication_bloc.dart';

// Enum to represent the different authentication states
enum AuthenticationStatus { 
  authenticated,   // User is authenticated (logged in)
  unauthenticated, // User is unauthenticated (logged out)
  unknown          // User status is unknown (initial state or waiting for data)
}

// The AuthenticationState class represents the current state of authentication.
class AuthenticationState extends Equatable {
  // Private named constructor for creating the state with a given status and optional user
  const AuthenticationState._({
    this.status = AuthenticationStatus.unknown,
    this.user
  });

  final AuthenticationStatus status;
  final MyUser? user;

  // Factory constructor for the 'unknown' state (initial state or waiting state)
  const AuthenticationState.unknown() : this._();

  // Factory constructor for the 'authenticated' state (when a user is logged in)
  const AuthenticationState.authenticated(MyUser myUser) : 
    this._(status: AuthenticationStatus.authenticated, user: myUser);

  // Factory constructor for the 'unauthenticated' state (when a user is logged out)
  const AuthenticationState.unauthenticated() :
    this._(status: AuthenticationStatus.unauthenticated);

// Equatable comparison.
  @override
  List<Object?> get props => [status, user];
}