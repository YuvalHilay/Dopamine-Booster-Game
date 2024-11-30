import 'package:demo/components/external_login.dart';
import 'package:demo/components/my_button.dart';
import 'package:demo/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 810),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                _buildTopSection(context),
                _buildMiddleSection(),
                _buildBottomSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Top section widget
  Widget _buildTopSection(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        color: Colors.blueAccent.withOpacity(0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 80.r,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            Text(
              "Dopamine Booster",
              style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Middle section widget
  Widget _buildMiddleSection() {
    return Expanded(
      flex: 4,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.0.w),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: 400.h, // Limit the height to avoid overflow
              ),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8.r,
                    spreadRadius: 2.r,
                    offset: Offset(0, 4.r),
                  ),
                ],
              ),
              child: _buildLoginForm(),
            ),
          ),
        ),
      ),
    );
  }

  // Bottom section widget
  Widget _buildBottomSection(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Expanded(
                  child: Divider(color: Colors.black26, thickness: 1.r),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(AppLocalizations.of(context)!.signupWith),
                ),
                Expanded(
                  child: Divider(color: Colors.black26, thickness: 1.r),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            // Including ExternalLogin
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: const ExternalLogin(),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.noAcc,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text(
                    AppLocalizations.of(context)!.regsHere,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Email field
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email),
              hintText: AppLocalizations.of(context)!.email,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17.r),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.errEmail;
              }
              return null;
            },
          ),
          SizedBox(height: 10.h),

          // Password field
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock),
              hintText: AppLocalizations.of(context)!.password,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17.r),
              ),
            ),
            validator: (value) {
              if (value == null || value.length < 6) {
                return AppLocalizations.of(context)!.errPassword;
              }
              return null;
            },
          ),
          SizedBox(height: 10.h),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              AppLocalizations.of(context)!.forgotPass,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Login button
          MyButton(
            text: AppLocalizations.of(context)!.loginBtn,
            onTap: () {
              if (_formKey.currentState!.validate()) {
                AuthService.login(
                  context: context,
                  email: emailController.text,
                  password: passwordController.text,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
