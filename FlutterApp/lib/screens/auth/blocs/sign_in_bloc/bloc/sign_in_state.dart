part of 'sign_in_bloc.dart';

// The SignInState class is the base class for all states related to sign-in actions.
sealed class SignInState extends Equatable {
  const SignInState();

  // Equatable is used to compare instances of states.
  @override
  List<Object> get props => [];
}

// SignInInitial state represents the initial state of the sign-in process.
final class SignInInitial extends SignInState {}

// SignInFailure state represents a failed sign-in attempt.
final class SignInFailure extends SignInState {}

// SignInProcess state represents the ongoing sign-in process.
final class SignInProcess extends SignInState {}

// SignInSuccess state represents a successful sign-in attempt.
final class SignInSuccess extends SignInState {}


