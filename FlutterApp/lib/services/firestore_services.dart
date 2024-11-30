import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  //Create new registered user in DB
  static Future<void> createUserDocument({
    required String email,
    required String userName,
  }) async {
    await FirebaseFirestore.instance.collection("Users").doc(email).set({
      'email': email,
      'userName': userName,
    });
  }
}
