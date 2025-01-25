import 'package:Dopamine_Booster/components/popup_msg.dart';
import 'package:Dopamine_Booster/screens/auth/blocs/sign_in_bloc/bloc/sign_in_bloc.dart';
import 'package:Dopamine_Booster/utils/PreferencesService.dart';
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
  final PreferencesService preferencesService = PreferencesService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool signInRequired = false;
  IconData iconPassword = CupertinoIcons.eye_fill;
  bool obscurePassword = true;
  String? _errorMsg;
  bool saveEmail = false; // Track the checkbox state

  static const BoxShadow kBoxShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 8,
    spreadRadius: 2,
    offset: Offset(0, 4),
  );

  // Load saved email when the screen is loaded
  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  // Load the saved email from PreferencesService
  _loadEmail() async {
    String? savedEmail = await preferencesService.getSavedEmail();
    if (savedEmail != null  && savedEmail != 'false') {
      emailController.text = savedEmail; // Pre-fill email if saved
      setState(() {
        saveEmail = true; // Mark checkbox as checked
      });
    }
  }

   // Save email to PreferencesService
  _saveEmail(String email) async {
    await preferencesService.saveEmail(email); // Save email using PreferencesService
  }

  // Show the forgot password dialog
  void _showForgotPasswordDialog() {
    final signInBloc = context.read<SignInBloc>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController resetEmailController = TextEditingController();
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
                    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                ElevatedButton(
                  child: Text(AppLocalizations.of(context)!.resetPassword),
                  onPressed: () {
                    if (FormValidators.validateEmail(resetEmailController.text) == null) {
                      signInBloc.add(RestPasswordRequired(resetEmailController.text));
                      displayMessageToUser(AppLocalizations.of(context)!.passwordResetEmailSent(resetEmailController.text), context);
                      Navigator.of(context).pop();
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
              displayMessageToUser(AppLocalizations.of(context)!.invalidEmailOrPassword, context);
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
                    // Email text fields
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
                    // Password text fields
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
                    //  Checkbox and remember me text and forget password button
                    Row(
                      children: [
                        //Checkbox + Text widget
                        Checkbox(
                          checkColor: Theme.of(context).colorScheme.inversePrimary,
                          value: saveEmail,
                          onChanged: (bool? newValue) async {
                            setState(() {
                              saveEmail = newValue ?? false;
                            });
                            // Save or remove the email based on the checkbox state
                            if (saveEmail) {
                              // Save the current email from the text field
                              await _saveEmail(emailController.text);
                            } else {
                              // Remove the saved email
                              await preferencesService.removeSavedEmail();
                            }
                          },
                        ),
                        Text(AppLocalizations.of(context)!.rememberMe,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        Spacer(), // Add a Spacer widget here
                        // Forgot password button
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
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Sign in button
                    SizedBox(
                      width: width * 0.9,
                      child: ElevatedButton(
                        onPressed: signInRequired
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  if (saveEmail) {
                                    _saveEmail(emailController.text); // Save email if checkbox is checked
                                  }
                                  context.read<SignInBloc>().add(SignInRequired(
                                      emailController.text,
                                      passwordController.text));
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: signInRequired
                            ? const CircularProgressIndicator(color: Colors.white)
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
