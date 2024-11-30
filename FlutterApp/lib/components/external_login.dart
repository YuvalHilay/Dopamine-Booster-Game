import 'package:demo/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';

class ExternalLogin extends StatelessWidget {
  const ExternalLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Brand(Brands.facebook, size: 55.r),
              onPressed: () async {
                await AuthService.signInWithFacebook(context);
              },
            ),
            IconButton(
              icon: Brand(Brands.twitter, size: 55.r),
              onPressed: () async {
                await AuthService.signInWithTwitter(context);
              },
            ),
            IconButton(
              icon: Brand(Brands.google, size: 55.r),
              onPressed: () => AuthService.signInWithGoogle(),
            ),
            IconButton(
              icon: Brand(Brands.apple_logo, size: 55.r),
              onPressed: () async {
                await AuthService.signInWithApple(context);
              },
            ),
          ],
        ),
      ],
    );
  }
}
