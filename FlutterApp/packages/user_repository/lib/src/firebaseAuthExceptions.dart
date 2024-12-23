import 'package:firebase_auth/firebase_auth.dart';

// Utility to map FirebaseAuthException codes to user-friendly messages
String getFirebaseAuthErrorMessage(FirebaseAuthException exception) {
  switch (exception.code) {
    case 'invalid-email':
      return 'The email address is not valid.';
    case 'user-disabled':
      return 'The user account has been disabled.';
    case 'user-not-found':
      return 'No user found for the provided email.';
    case 'wrong-password':
      return 'The password is invalid for the provided email.';
    case 'email-already-in-use':
      return 'The email address is already registered.';
    case 'weak-password':
      return 'The password is too weak.';
    case 'operation-not-allowed':
      return 'Email/password accounts are not enabled.';
    case 'invalid-credential':
      return 'The credential provided is malformed or expired.';
    case 'account-exists-with-different-credential':
      return 'An account already exists with a different credential.';
    default:
      return 'An unexpected authentication error occurred.';
  }
}
