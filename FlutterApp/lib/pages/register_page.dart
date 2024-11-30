import 'package:flutter/material.dart';
import 'package:demo/services/auth_services.dart';
import 'package:demo/components/my_button.dart';
import 'package:demo/components/my_textfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:toggle_switch/toggle_switch.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isStepOne = true; // Track the current step
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Controllers for text inputs
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  bool isChecked = false; // Track terms checkbox state

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 810),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => Scaffold(
        resizeToAvoidBottomInset: true, // Allow resizing for keyboard
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom, // Keyboard padding
              ),
              child: Column(
                children: [
                  // Top Section
                  _buildTopSection(context),
                  10.verticalSpace,
                  // Middle Section (Form Step One or Step Two)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.0.w),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isStepOne
                          ? buildFormStepOne(context)
                          : buildFormStepTwo(context),
                    ),
                  ),
                  20.verticalSpace,
                  // Bottom Section
                  _buildBottomSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Container(
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
            style: TextStyle(fontSize: 30.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.0.r, vertical: 20.0.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.haveAcc,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              GestureDetector(
                onTap: widget.onTap,
                child: Text(
                  AppLocalizations.of(context)!.loginHere,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Method to toggle between the register form steps
  void nextStep() {
    if (isStepOne) {
      setState(() => isStepOne = false);
    }
  }

  void previousStep() {
    if (!isStepOne) {
      setState(() => isStepOne = true);
    }
  }

  // Register Form Step 1 Widget
  Widget buildFormStepOne(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
                  blurRadius: 8.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: EdgeInsets.all(20.w).r,
            child: Column(
              children: [
                // First Name
                TextFormField(
                  controller: firstNameController,
                  obscureText: false,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    hintText: AppLocalizations.of(context)!.firstName,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17.r)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a valid first name';
                    }
                    return null;
                  },
                ),

                10.verticalSpace,

                // Last Name
                TextFormField(
                  controller: lastNameController,
                  obscureText: false,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    hintText: AppLocalizations.of(context)!.lastName,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17.r)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a valid last name';
                    }
                    return null;
                  },
                ),

                10.verticalSpace,

                // Gender Toggle
                ToggleSwitch(
                  minWidth: double.infinity,
                  initialLabelIndex: 0,
                  cornerRadius: 20.0,
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.grey,
                  inactiveFgColor: Colors.white,
                  totalSwitches: 2,
                  labels: const ['Male', 'Female'],
                  icons: const [IonIcons.male, IonIcons.female],
                  activeBgColors: const [
                    [Colors.blue],
                    [Colors.pink]
                  ],
                  onToggle: (index) {
                    // Update gender based on toggle
                  },
                ),

                10.verticalSpace,

                // Next Button
                MyButton(
                  text: AppLocalizations.of(context)!.nextBtn,
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      nextStep();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Register Form Step 2 Widget
  Widget buildFormStepTwo(BuildContext context) {
    return Form(
      key: _formKey, // Define a GlobalKey for the Form
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
                  blurRadius: 8.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: EdgeInsets.all(20.w).r,
            child: Column(
              children: [
                // Email Field
                TextFormField(
                  obscureText: false,
                  controller: emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email),
                    hintText: AppLocalizations.of(context)!.email,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17.r)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),

                10.verticalSpace,

                // Password Field
                TextFormField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.key),
                    hintText: AppLocalizations.of(context)!.password,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17.r)),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                10.verticalSpace,

                // Confirm Password Field
                TextFormField(
                  obscureText: true,
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.key),
                    hintText: AppLocalizations.of(context)!.confirmPass,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17.r)),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    } else if (value != passwordController.text) {
                      return 'Password must be matched';
                    }
                    return null;
                  },
                ),

                10.verticalSpace,

                // User Role Choice
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                  child: ToggleSwitch(
                    minWidth: double.infinity,
                    initialLabelIndex: 0,
                    cornerRadius: 20.0,
                    activeFgColor: Colors.white,
                    inactiveBgColor: Colors.grey,
                    inactiveFgColor: Colors.white,
                    totalSwitches: 3,
                    labels: const ['Student', 'Teacher', 'Parent'],
                    activeBgColors: const [
                      [Colors.blue],
                      [Colors.pink],
                      [Colors.green]
                    ],
                    onToggle: (index) {
                      // Update role based on toggle
                    },
                  ),
                ),

                10.verticalSpace,

                // Checkbox for Terms and Conditions
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (value) {
                        setState(() {
                          isChecked = value ?? false; // Update checkbox state
                        });
                      },
                    ),
                    Text(AppLocalizations.of(context)!.termsCheckBox),
                  ],
                ),

                10.verticalSpace,

                // Back and Register Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyButton(
                      text: AppLocalizations.of(context)!.backBtn,
                      onTap: previousStep,
                    ),
                    MyButton(
                      text: AppLocalizations.of(context)!.registerBtn,
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          AuthService.registerUser(
                            emailController: emailController,
                            passwordController: passwordController,
                            confirmPdController: confirmPasswordController,
                            userNameController: userNameController,
                            context: context,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
