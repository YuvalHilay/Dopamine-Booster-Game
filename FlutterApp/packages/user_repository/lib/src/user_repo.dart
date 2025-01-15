import 'models/models.dart';

// Abstract class Provides methods for user authentication and management of user repository.
abstract class UserRepository {
  // A stream to listen for the current user changes.
  Stream<MyUser?> get user;

  // Creates a new user with the provided details and password.
  Future<MyUser> signUp(MyUser myUser, String password);

  // Sets the user's data in the database.
  Future<void> setUserData(MyUser user);

  // Signs in the user with email and password.
  Future<void> signIn(String email, String password);

  // Logs out the currently signed-in user.
  Future<void> logOut();

  // Signs in the user using Google authentication.
  Future<void> signInWithGoogle();

  Future<String> getStudentCount();
  
// Method to change the user's password
  Future<void> changePassword({required String currentPassword, required String newPassword});

  // Sends a password reset email to the user with the provided [email].
  Future<void> sendPasswordResetEmail(String email);
}
