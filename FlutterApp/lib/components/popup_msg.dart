import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

// display error message to user
void displayMessageToUser(String message, BuildContext context) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.SNACKBAR,
    backgroundColor: Colors.black54,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
