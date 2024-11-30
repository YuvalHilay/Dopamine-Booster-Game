import 'package:demo/components/popup_msg.dart';
import 'package:demo/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  //login method
  static Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    // Show loading indicator
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // ignore: use_build_context_synchronously
      if (Navigator.canPop(context)) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        displayMessageToUser(e.code, context);
      }
    }
  }

  //register method
  static Future<void> registerUser({
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController confirmPdController,
    required TextEditingController userNameController,
    required BuildContext context,
  }) async {
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    if (passwordController.text != confirmPdController.text) {
      navigator.pop();
      displayMessageToUser("Passwords don't match!", context);
      return;
    }

    try {
      UserCredential? userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      await FirestoreService.createUserDocument(
        email: userCredential.user!.email!,
        userName: userNameController.text,
      );
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      displayMessageToUser(e.code, context);
    } finally {
      if (navigator.mounted) navigator.pop(); // Safely pop if mounted
    }
  }

  //login with Google auth
  static Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      //displayMessageToUser("oogle sign-in failed");
    }
  }

  //login with Facebook auth
  static Future<void> signInWithFacebook(BuildContext context) async {
    // TODO: Implement Facebook login logic.
  }
  //login with Twitter auth
  static Future<void> signInWithTwitter(BuildContext context) async {
    // TODO: Implement Twitter login logic.
  }
  //login with Apple auth
  static Future<void> signInWithApple(BuildContext context) async {
    // TODO: Implement Apple login logic.
  }
}
