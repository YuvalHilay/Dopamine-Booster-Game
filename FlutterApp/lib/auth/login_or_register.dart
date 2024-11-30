import 'package:demo/pages/login_page.dart';
import 'package:demo/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegister();
}

class _LoginOrRegister extends State<LoginOrRegister> {
  // init with login page
  bool showLoginPage = true;
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if (showLoginPage) {
      return ScreenUtilInit(
          designSize: Size(screenWidth, screenHeight),
          builder: (context, child) => LoginPage(onTap: togglePages));
    } else {
      return ScreenUtilInit(
          designSize: Size(screenWidth, screenHeight),
          builder: (context, child) => RegisterPage(onTap: togglePages));
    }
  }
}
