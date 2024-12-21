part of 'sign_up_bloc.dart';

// The SignUpState class is the base class for all states related to sign-up actions.
sealed class SignUpState extends Equatable {
  const SignUpState();

  // Equatable is used to compare instances of states.
  @override
  List<Object> get props => [];
}

// SignUpInitial state represents the initial state of the sign-up process.
final class SignUpInitial extends SignUpState {}

// SignUpSuccess state represents a successful sign-up attempt.
class SignUpSuccess extends SignUpState {}

// SignUpFailure state represents a failed sign-up attempt.
class SignUpFailure extends SignUpState {}

// SignUpProcess state represents the ongoing sign-up process.
class SignUpProcess extends SignUpState {}