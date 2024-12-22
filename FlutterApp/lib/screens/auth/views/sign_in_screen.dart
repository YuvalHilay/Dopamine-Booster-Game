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
  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // Form states
  final _formKey = GlobalKey<FormState>();
  bool signInRequired = false;
  IconData iconPassword = CupertinoIcons.eye_fill;
  bool obscurePassword = true;
  String? _errorMsg;
  static const BoxShadow kBoxShadow = BoxShadow(
    color: Colors.grey, // Shadow color
    blurRadius: 8,      // Blurriness of the shadow
    spreadRadius: 2,    // How far the shadow spreads
    offset: Offset(0, 4), // Position offset of the shadow
);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return BlocListener<SignInBloc, SignInState>(
      listener: (context, state) {
        if (state is SignInSuccess) {
          setState(() {
            signInRequired = false;
          });
        } else if (state is SignInProcess) {
          setState(() {
            signInRequired = true;
          });
        } else if (state is SignInFailure) {
          setState(() {
            signInRequired = false;
            _errorMsg = 'Invalid email or password';
          });
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: 300, // Limit the height to avoid overflow
          maxWidth: 440
        ),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [kBoxShadow],
        ),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Email Field
                SizedBox(width: width * 0.9,
                    child: MyTextField(
                        controller: emailController,
                        hintText: AppLocalizations.of(context)!.email,
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(CupertinoIcons.mail_solid),
                        errorMsg: _errorMsg,
                        validator: FormValidators.validateEmail)),
                const SizedBox(height: 10),
                // Password Field
                SizedBox(width: width * 0.9,
                  child: MyTextField(
                    controller: passwordController,
                    hintText: AppLocalizations.of(context)!.password,
                    obscureText: obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    prefixIcon: const Icon(CupertinoIcons.lock_fill),
                    errorMsg: _errorMsg,
                    validator: FormValidators.validatePassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                          if (obscurePassword) {
                            iconPassword = CupertinoIcons.eye_fill;
                          } else {
                            iconPassword = CupertinoIcons.eye_slash_fill;
                          }
                        });
                      },
                      icon: Icon(iconPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                !signInRequired
                    ? SizedBox(
                        width: width * 0.9,
                        child: TextButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<SignInBloc>().add(SignInRequired(
                                    emailController.text,
                                    passwordController.text));
                              }
                            },
                            style: TextButton.styleFrom(
                                elevation: 3.0,
                                backgroundColor:Theme.of(context).colorScheme.inversePrimary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(60))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 5),
                              child: Text(
                                AppLocalizations.of(context)!.loginBtn,
                                textAlign: TextAlign.center,
                                style:  TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              ),
                            )),
                      )
                    : const CircularProgressIndicator(),
              ],
            )),
      ),
    );
  }
}
