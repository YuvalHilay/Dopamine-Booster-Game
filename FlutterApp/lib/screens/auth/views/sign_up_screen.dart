import 'package:Dopamine_Booster/components/popup_msg.dart';
import 'package:Dopamine_Booster/screens/auth/blocs/sign_up_bloc/bloc/sign_up_bloc.dart';
import 'package:Dopamine_Booster/utils/validators/form_validators.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../components/my_textfield.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // User attributes
  String gender = 'M'; // Default value for gender
  String userType = 'Student'; // Default value for userType
  // Form states
  final _formKey = GlobalKey<FormState>();
  int currentStep = 0;
  bool isChecked = false;
  // Password validation state
  bool obscurePassword = true;
  IconData iconPassword = CupertinoIcons.eye_fill;
  bool containsUpperCase = false;
  bool containsLowerCase = false;
  bool containsNumber = false;
  bool contains8Length = false;
  bool signUpRequired = false;
  static const BoxShadow kBoxShadow = BoxShadow(
    color: Colors.grey, // Shadow color
    blurRadius: 8, // Blurriness of the shadow
    spreadRadius: 2, // How far the shadow spreads
    offset: Offset(0, 4), // Position offset of the shadow
  );

  @override
  // Clean up controllers
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          setState(() {
            displayMessageToUser('Sign in successful', context);
            signUpRequired = false;
          });
        } else if (state is SignUpProcess) {
          setState(() {
            signUpRequired = true;
          });
        } else if (state is SignUpFailure) {
          displayMessageToUser(AppLocalizations.of(context)!.invalidEmailOrPassword,context);
          return;
        }
      },
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
                maxHeight: 420, // Limit the height to avoid overflow
                maxWidth: 440),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [kBoxShadow],
            ),
            child: Form(
              key: _formKey,
              child: Center(
                  child: Column(children: [
                const SizedBox(height: 20),
                // Display Form step
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: currentStep == 0
                      ? _buildFormStepOne(context, width, height)
                      : _buildFormStepTwo(context, width, height),
                ),
              ])),
            ),
          ),
        ),
      ),
    );
  }

  /// Step 1: User Information
  Widget _buildFormStepOne(BuildContext context, double width, double height) {
    return Column(children: [
      // First Name field
      SizedBox(
        width: width * 0.9,
        child: MyTextField(
            controller: firstNameController,
            hintText: AppLocalizations.of(context)!.firstName,
            obscureText: false,
            keyboardType: TextInputType.name,
            prefixIcon: const Icon(CupertinoIcons.person_fill),
            validator: (value) =>
                FormValidators.validateName(value, maxLength: 30)),
      ),
      const SizedBox(height: 10),
      // Last Name field
      SizedBox(
          width: width * 0.9,
          child: MyTextField(
              controller: lastNameController,
              hintText: AppLocalizations.of(context)!.lastName,
              obscureText: false,
              keyboardType: TextInputType.name,
              prefixIcon: const Icon(CupertinoIcons.person_fill),
              validator: (value) =>
                  FormValidators.validateName(value, maxLength: 30))),
      const SizedBox(height: 10),
      // Gender Toggle
      _buildGenderToggle(),
      const SizedBox(height: 20),
      // "Next" button
      SizedBox(
        width: width * 0.9,
        child: _buildTextButton(
          context: context,
          label: AppLocalizations.of(context)!.nextBtn,
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              setState(() {
                currentStep = 1; // Move to Step 1 of sign up form
              });
            }
          },
        ),
      ),
    ]);
  }

  /// Step 2: Account Information
  Widget _buildFormStepTwo(BuildContext context, double width, double height) {
    return Column(children: [
      // email field
      SizedBox(
        width: width * 0.9,
        child: MyTextField(
            controller: emailController,
            hintText: AppLocalizations.of(context)!.email,
            obscureText: false,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(CupertinoIcons.mail_solid),
            validator: FormValidators.validateEmail),
      ),
      const SizedBox(height: 10),
      // password field
      SizedBox(
        width: width * 0.9,
        child: MyTextField(
            controller: passwordController,
            hintText: AppLocalizations.of(context)!.password,
            obscureText: obscurePassword,
            keyboardType: TextInputType.visiblePassword,
            prefixIcon: const Icon(CupertinoIcons.lock_fill),
            onChanged: _onPasswordChanged,
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
            validator: FormValidators.validatePassword),
      ),
      const SizedBox(height: 10),
      // password rules check indicators
      _buildPasswordRules(),
      const SizedBox(height: 10),
      // User Role Toggle
      _buildUserRoleToggle(),
      const SizedBox(height: 2),
      // Checkbox terms
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: isChecked,
            onChanged: (value) {
              setState(() {
                isChecked = value ?? false;
              });
            },
            activeColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          Flexible(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isChecked = !isChecked;
                });
              },
              child: RichText(
                text: TextSpan(
                  text: AppLocalizations.of(context)!.agreeTo,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!.termsAndC,
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      //recognizer: TapGestureRecognizer()..onTap = () {
                      // Navigate to terms and conditions
                      // },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 2),
      // Step 2 form buttons
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        // Back Button
        Expanded(
          flex: 1,
          child: Padding(
            // Added padding for spacing between buttons
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildTextButton(
              context: context,
              label: AppLocalizations.of(context)!.backBtn,
              onPressed: () {
                setState(() {
                  currentStep = 0; // Move to Step 1
                });
              },
            ),
          ),
        ),
        !signUpRequired
            ? Expanded( // Changed from SizedBox to Expanded
        flex: 1, // Flex for equal distribution of space
        child: Padding( // Added padding for spacing between buttons
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildTextButton(
                  context: context,
                  label: AppLocalizations.of(context)!.registerBtn,
                  onPressed: () {
                    if (_formKey.currentState!.validate() && isChecked) {
                      MyUser myUser = MyUser.empty;
                      myUser.email = emailController.text;
                      myUser.firstName = firstNameController.text;
                      myUser.lastName = lastNameController.text;
                      myUser.gender = gender;
                      myUser.userRole = userType;
                      setState(() {
                        context.read<SignUpBloc>().add(
                            SignUpRequired(myUser, passwordController.text));
                      });
                    } else {
                      displayMessageToUser(
                          'Please fill all fields and accept the terms.',
                          context);
                    }
                  },
                ),
        
                ),
              )
            : const CircularProgressIndicator()
      ]),
    ]);
  }

  /// Generic Text Button Builder
  Widget _buildTextButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
            elevation: 3.0,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 4),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 17,
                fontWeight: FontWeight.w600),
          ),
        ));
  }

  // Gender Toggle
  Widget _buildUserRoleToggle() {
    return ToggleSwitch(
        minWidth: double.infinity,
        initialLabelIndex: 0,
        cornerRadius: 20.0,
        activeFgColor: Colors.white,
        inactiveBgColor: Colors.grey,
        inactiveFgColor: Colors.white,
        totalSwitches: 3,
        labels: [
          AppLocalizations.of(context)!.student,
          AppLocalizations.of(context)!.teacher,
          AppLocalizations.of(context)!.parent,
        ],
        icons: const [IonIcons.male, IonIcons.female, IonIcons.female],
        activeBgColors: const [
          [Colors.blue], // For Student
          [Colors.green], // For Teacher
          [Colors.red] // For Parent
        ],
        onToggle: (index) {
          if (index == 0) {
          } else if (index == 1) {
            userType = 'Teacher';
          } else if (index == 2) {
            userType = 'Parent';
          }
          ;
        });
  }

  // User Role Toggle
  Widget _buildGenderToggle() {
    return ToggleSwitch(
      minWidth: double.infinity,
      initialLabelIndex: 0,
      cornerRadius: 20.0,
      activeFgColor: Colors.white,
      inactiveBgColor: Colors.grey,
      inactiveFgColor: Colors.white,
      totalSwitches: 2,
      labels: [
        AppLocalizations.of(context)!.male,
        AppLocalizations.of(context)!.female,
      ],
      icons: const [IonIcons.male, IonIcons.female],
      activeBgColors: const [
        [Colors.blue], // For Male
        [Colors.pink] // For Female
      ],
      onToggle: (index) {
        // Update gender based on toggle
        gender = index == 0 ? 'M' : 'F';
      },
    );
  }

  // Password Rules
  Widget _buildPasswordRules() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildPasswordRule(
              AppLocalizations.of(context)!.upperCase, containsUpperCase),
          _buildPasswordRule(
              AppLocalizations.of(context)!.lowerCase, containsLowerCase),
        ]),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPasswordRule(
                AppLocalizations.of(context)!.oneNum, containsNumber),
            _buildPasswordRule(
                AppLocalizations.of(context)!.minCharPass, contains8Length),
          ],
        ),
      ],
    );
  }

  // Helper: Password Rule Indicator
  Widget _buildPasswordRule(String label, bool isValid) {
    return Text(
      "⚈  $label",
      style: TextStyle(color: isValid ? Colors.green : Colors.red),
    );
  }

  // Password Change Handler
  String? _onPasswordChanged(String? value) {
    if (value == null) return null;

    setState(() {
      containsUpperCase = RegExp(r'[A-Z]').hasMatch(value);
      containsLowerCase = RegExp(r'[a-z]').hasMatch(value);
      containsNumber = RegExp(r'[0-9]').hasMatch(value);
      contains8Length = value.length >= 8;
    });

    return null; // Ensure the function returns a String?
  }
}
