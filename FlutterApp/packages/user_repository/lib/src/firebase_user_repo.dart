import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:user_repository/user_repository.dart';

// Firebase implementation of the [UserRepository], uses Firebase Authentication and Firestore for user data storage and retrieval.
class FirebaseUserRepo implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final usersCollection = FirebaseFirestore.instance.collection('users');

  // Constructor for initializing the repository with an optional FirebaseAuth instance.
  FirebaseUserRepo({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  // Stream of the currently authenticated user.
  Stream<MyUser> get user {
    return _firebaseAuth.authStateChanges().asyncMap((User? firebaseUser) async {
      if (firebaseUser == null) {
        return MyUser.empty;
      } else {
        return await usersCollection
          .doc(firebaseUser.uid)
          .get()
          .then((value) => MyUser.fromEntity(MyUserEntity.fromDocument(value.data()!)));
      }
    }).handleError((error) {
      print('Error in user stream: $error');
      return MyUser.empty;
    });
  }

  @override
  // Signs in the user with the provided [email] and [password].
  Future<void> signIn(String email, String password) async {
  try {
    // Attempt to sign in using Firebase Auth
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  } on FirebaseAuthException catch (e) {
    log('FirebaseAuthException: ${e.code} - ${e.message}');
    // Handle Firebase-specific errors with meaningful messages
    switch (e.code) {
      case 'invalid-email':
        throw Exception('The email address is not valid.');
      case 'user-not-found':
        throw Exception('No user found for the provided email.');
      case 'wrong-password':
        throw Exception('The password is incorrect.');
      case 'user-disabled':
        throw Exception('This user account has been disabled.');
      default:
        throw Exception('Authentication error: ${e.message}');
    }
  } catch (e) {
    // Catch any unexpected errors
    log('Unknown error in signIn: $e');
    throw Exception('An unknown error occurred: $e');
  }
}

  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
              email: myUser.email, password: password);
      // Assign the generated Firebase user ID to the MyUser object.
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        log('Error: Firebase user is null after sign-up.');
        throw Exception('Failed to create user or retrieve userId.');
      }

      myUser.userId = firebaseUser.uid; // Assign the UID
      log('User signed up successfully. userId: ${myUser.userId}');
      return myUser;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase sign-up errors for better debugging and user feedback.
      if (e.code == 'email-already-in-use') {
        log('Email is already in use: ${myUser.email}');
        throw Exception('The email address is already registered.');
      } else if (e.code == 'weak-password') {
        log('Weak password error');
        throw Exception('The password is too weak.');
      } else {
        log('FirebaseAuthException: ${e.code}');
        throw Exception('Sign-up failed. Error code: ${e.code}');
      }
    } catch (e) {
      // Handle other generic errors.
      log('Unexpected error during sign-up: $e');
      throw Exception('An unexpected error occurred during sign-up.');
    }
  }

  @override
  // Logs out the currently signed-in user.
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  // Saves or updates the user's data in the Firestore "users" collection.
  Future<void> setUserData(MyUser myUser) async {
    try {
      await usersCollection
          .doc(myUser.userId)
          .set(myUser.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  // Signs in the user using their Google account.
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Generate Firebase credentials using Google tokens.
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase using the Google credentials.
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      log(e.toString());
      //displayMessageToUser("google sign-in failed");
    }
  }

  @override
  // Method to change the user's password
  Future<void> changePassword({
  required String currentPassword,
  required String newPassword,
}) async {
  print("Changing password...");
  print("Current password: $currentPassword");
  try {
    // Get the currently logged-in user
    User? user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception("User is not logged in.");
    }

    // Check if the new password is the same as the current password
    if (currentPassword == newPassword) {
      throw Exception("The new password cannot be the same as the current password.");
    }

    // Re-authenticate the user with their current password
    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    // Re-authenticate to ensure the user is verified
    await user.reauthenticateWithCredential(credential);

    // Update the user's password
    await user.updatePassword(newPassword);

    // sign the user out and ask them to log in again
    await _firebaseAuth.signOut();

    print("Password changed successfully. Please log in again.");
  } on FirebaseAuthException catch (e) {
    // Handle specific FirebaseAuth errors
    if (e.code == 'wrong-password') {
      throw Exception("The current password is incorrect.");
    } else if (e.code == 'weak-password') {
      throw Exception("The new password is too weak. Please choose a stronger password.");
    } else if (e.code == 'requires-recent-login') {
      throw Exception("This operation requires recent login. Please log in again and try.");
    } else {
      throw Exception(e.message ?? "An unexpected error occurred. Please try again.");
    }
  } catch (e) {
    // Handle other generic errors
    throw Exception("Failed to change password: ${e.toString()}");
  }
}

  @override
  Future<String> getStudentCount() async {
    try {
      final querySnapshot = await usersCollection
          .where('userRole', isEqualTo: 'Student')
          .get();

      final int count = querySnapshot.docs.length;

      return count.toString();
    } catch (e) {
      print("Error fetching student count: $e");
      return "0"; // Return "0" or an error message in case of failure
    }
  }

  @override
  // New method to update first name and last name
  Future<void> updateUserName(String firstName, String lastName) async {
    try {
      // Get the current logged-in user
      User? user = _firebaseAuth.currentUser;

      if (user == null) {
        throw Exception("User is not logged in.");
      }

      // Update the user's name fields in Firestore
      await usersCollection.doc(user.uid).update({
        'firstName': firstName,
        'lastName': lastName,
      });

      // Sign the user out and ask them to log in again
    await _firebaseAuth.signOut();
    } catch (e) {
      log("Error updating user name: $e");
      throw Exception("Failed to update user name: $e");
    }
  }

  @override
  // Sends a password reset email to the user with the provided [email].
  Future<void> sendPasswordResetEmail(String email) async {
    try {

      // Send the password reset email
      await _firebaseAuth.sendPasswordResetEmail(email: email);

      print("Password reset email sent successfully to $email.");
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuth errors
      if (e.code == 'invalid-email') {
        throw Exception("The email address is not valid. Please check and try again.");
      } else if (e.code == 'user-not-found') {
        throw Exception("No user found with this email address. Please check and try again.");
      } else {
        throw Exception(e.message ?? "An unexpected error occurred. Please try again.");
      }
    } catch (e) {
      // Handle generic errors
      throw Exception("Failed to send password reset email: ${e.toString()}");
    }
  }

}


