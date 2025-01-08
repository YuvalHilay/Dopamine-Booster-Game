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
  // Sends a password reset email to the user with the provided [email].
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
}


