import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

// The SignInBloc class handles the authentication process and emits states based on the events
class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final UserRepository _userRepository;

  // Constructor initializes the bloc with the user repository and sets the initial state.
  SignInBloc(this._userRepository) : super(SignInInitial()) {
    // Handles the SignInRequired event to initiate the sign-in process.
    on<SignInRequired>((event, emit) async {
      emit(SignInProcess());
      try {
        // Attempt to sign in using the provided email and password.
        await _userRepository.signIn(event.email, event.password);
      } catch (e) {
        emit(SignInFailure()); // Error occurs, failure statee.
      }
    });
    // Handles the SignOutRequired event to initiate the sign-out process.
    on<SignOutRequired>((event, emit) async => await _userRepository.logOut());
  }
}
