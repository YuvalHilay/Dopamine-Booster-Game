import 'package:Dopamine_Booster/components/popup_msg.dart';
import 'package:Dopamine_Booster/screens/auth/blocs/sign_in_bloc/bloc/sign_in_bloc.dart';
import 'package:Dopamine_Booster/utils/validators/form_validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../components/my_textfield.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool signInRequired = false;
  IconData iconPassword = CupertinoIcons.eye_fill;
  bool obscurePassword = true;
  String? _errorMsg;

  static const BoxShadow kBoxShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 8,
    spreadRadius: 2,
    offset: Offset(0, 4),
  );

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController resetEmailController =
            TextEditingController();
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.forgotPassword),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.enterEmailForReset),
              const SizedBox(height: 16),
              MyTextField(
                controller: resetEmailController,
                hintText: AppLocalizations.of(context)!.email,
                obscureText: false,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(CupertinoIcons.mail_solid),
                validator: FormValidators.validateEmail,
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: Text(AppLocalizations.of(context)!.cancel),
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                    foregroundColor: Theme.of(context)
                        .colorScheme
                        .primary, // Set the text color for the Cancel button
                  ),
                ),
                ElevatedButton(
                  child: Text(AppLocalizations.of(context)!.resetPassword),
                  onPressed: () {
                    if (FormValidators.validateEmail(resetEmailController.text) == null) {
                      //context.read<SignInBloc>().add(RestPasswordRequired(resetEmailController.text));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(AppLocalizations.of(context)!
                                .passwordResetEmailSent)),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
//  _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      child: BlocListener<SignInBloc, SignInState>(
        listener: (context, state) {
          if (state is SignInSuccess) {
            displayMessageToUser('Sign in successful', context);
            setState(() => signInRequired = false);
          } else if (state is SignInProcess) {
            setState(() => signInRequired = true);
          } else if (state is SignInFailure) {
            setState(() {
              displayMessageToUser(
                  AppLocalizations.of(context)!.invalidEmailOrPassword,
                  context);
              signInRequired = false;
              _errorMsg = AppLocalizations.of(context)!.invalidEmailOrPassword;
            });
          }
        },
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 410, maxWidth: 440),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [kBoxShadow],
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: emailController,
                      hintText: AppLocalizations.of(context)!.email,
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(CupertinoIcons.mail_solid),
                      errorMsg: _errorMsg,
                      validator: FormValidators.validateEmail,
                    ),
                    const SizedBox(height: 20),
                    MyTextField(
                      controller: passwordController,
                      hintText: AppLocalizations.of(context)!.password,
                      obscureText: obscurePassword,
                      keyboardType: TextInputType.visiblePassword,
                      prefixIcon: const Icon(CupertinoIcons.lock_fill),
                      errorMsg: _errorMsg,
                      validator: FormValidators.validatePassword,
                      suffixIcon: IconButton(
                        onPressed: () => setState(() {
                          obscurePassword = !obscurePassword;
                          iconPassword = obscurePassword
                              ? CupertinoIcons.eye_fill
                              : CupertinoIcons.eye_slash_fill;
                        }),
                        icon: Icon(iconPassword),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Directionality.of(context) == TextDirection.rtl
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: Text(
                          AppLocalizations.of(context)!.forgotPassword,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue, // Set the text color to blue
                            fontWeight: FontWeight.bold, // Make the text bold
                            decoration:
                                TextDecoration.underline, // Underline the text
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: width * 0.9,
                      child: ElevatedButton(
                        onPressed: signInRequired
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<SignInBloc>().add(SignInRequired(
                                      emailController.text,
                                      passwordController.text));
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.inversePrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: signInRequired
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                AppLocalizations.of(context)!.loginBtn,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
