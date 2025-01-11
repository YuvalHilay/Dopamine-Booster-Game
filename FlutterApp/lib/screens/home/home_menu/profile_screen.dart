import 'package:Dopamine_Booster/components/my_textfield.dart';
import 'package:Dopamine_Booster/utils/validators/form_validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  final String email; // User's unique identifier.
  final String userName; // User's name.

  ProfileScreen({Key? key, required this.email, required this.userName})
      : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers for the password fields
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Boolean flags to obscure password fields
  bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  // Icons for the password visibility toggles
  IconData iconCurrentPassword = CupertinoIcons.eye_fill;
  IconData iconNewPassword = CupertinoIcons.eye_fill;
  IconData iconConfirmPassword = CupertinoIcons.eye_fill;

  // Dispose of controllers to avoid memory leaks when the screen is removed from the widget tree
  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // SliverAppBar to provide a custom app bar with a flexible space
            SliverAppBar(
              expandedHeight: 90,
              floating: false, // Keeps the app bar visible while scrolling
              pinned: true, // Keeps the app bar pinned at the top of the screen
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  AppLocalizations.of(context)!.profile,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 30, // Larger font size for better readability
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 143, 62, 230),
                        Color.fromARGB(255, 81, 145, 255),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ), // Add rounded corners for a modern look
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildUserAvatar(),
                    const SizedBox(height: 20),
                    _buildUserInfo(),
                    const SizedBox(height: 40),
                    _buildChangePasswordButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds the user's avatar with an option to change it
  Widget _buildUserAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          child: Icon(
            Icons.person,
            size: 80,
            color: Colors.grey[600],
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              // TODO: Implement change avatar functionality
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // Displays the user's name and email
  Widget _buildUserInfo() {
    return Column(
      children: [
        Text(
          widget.userName,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inversePrimary),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.email,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
                fontSize: 17,
                color: Theme.of(context).colorScheme.inversePrimary),
          ),
        ),
      ],
    );
  }

  // Builds the button to change the password
  Widget _buildChangePasswordButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // Show the change password dialog
        _showChangePasswordDialog(context);
      },
      icon: Icon(Icons.lock_outline),
      label: Text(
        AppLocalizations.of(context)!.changePassword,
        style: GoogleFonts.poppins(
          textStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  // Displays the change password dialog with three password fields
  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.changePassword,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyTextField(
                      controller: currentPasswordController,
                      hintText: AppLocalizations.of(context)!.currentPassword,
                      obscureText: obscureCurrentPassword,
                      keyboardType: TextInputType.visiblePassword,
                      prefixIcon: const Icon(CupertinoIcons.lock_fill),
                      validator: FormValidators.validatePassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureCurrentPassword = !obscureCurrentPassword;
                            iconCurrentPassword = obscureCurrentPassword
                                ? CupertinoIcons.eye_fill
                                : CupertinoIcons.eye_slash_fill;
                          });
                        },
                        icon: Icon(iconCurrentPassword),
                      ),
                    ),
                    const SizedBox(height: 16),
                    MyTextField(
                      controller: newPasswordController,
                      hintText: AppLocalizations.of(context)!.newPassword,
                      obscureText: obscureNewPassword,
                      keyboardType: TextInputType.visiblePassword,
                      prefixIcon: const Icon(CupertinoIcons.lock_fill),
                      validator: FormValidators.validatePassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureNewPassword = !obscureNewPassword;
                            iconNewPassword = obscureNewPassword
                                ? CupertinoIcons.eye_fill
                                : CupertinoIcons.eye_slash_fill;
                          });
                        },
                        icon: Icon(iconNewPassword),
                      ),
                    ),
                    const SizedBox(height: 16),
                    MyTextField(
                      controller: confirmPasswordController,
                      hintText: AppLocalizations.of(context)!.confirmPass,
                      obscureText: obscureConfirmPassword,
                      keyboardType: TextInputType.visiblePassword,
                      prefixIcon: const Icon(CupertinoIcons.lock_fill),
                      validator: (value) {
                        if (value != newPasswordController.text) {
                          return AppLocalizations.of(context)!.passwordMismatch;
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                            iconConfirmPassword = obscureConfirmPassword
                                ? CupertinoIcons.eye_fill
                                : CupertinoIcons.eye_slash_fill;
                          });
                        },
                        icon: Icon(iconConfirmPassword),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // cancel button
                ElevatedButton(
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    // Clear the controllers' text when the cancel button is pressed
                    currentPasswordController.clear();
                    newPasswordController.clear();
                    confirmPasswordController.clear();
                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                // Change password button
                ElevatedButton(
                  child: Text(
                    AppLocalizations.of(context)!.changePassword,
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    //padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () {
                    // TODO: Implement password change logic
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
