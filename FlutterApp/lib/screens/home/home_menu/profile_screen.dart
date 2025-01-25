import 'package:Dopamine_Booster/components/my_textfield.dart';
import 'package:Dopamine_Booster/utils/validators/form_validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_repository/user_repository.dart';

class ProfileScreen extends StatefulWidget {
  final String email;
  final String userName;

  ProfileScreen({
    Key? key,
    required this.email,
    required this.userName,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserRepository _userRepository = FirebaseUserRepo();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  IconData iconCurrentPassword = CupertinoIcons.eye_fill;
  IconData iconNewPassword = CupertinoIcons.eye_fill;
  IconData iconConfirmPassword = CupertinoIcons.eye_fill;

  @override
  void initState() {
    super.initState();
    firstNameController.text = widget.userName;
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 90,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  AppLocalizations.of(context)!.profile,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
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
                    ),
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
                    _buildChangeNameButton(context),
                    const SizedBox(height: 20),
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

  Widget _buildUserInfo() {
    return Column(
      children: [
        Text(
          "${widget.userName}",
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

  Widget _buildChangeNameButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        _showChangeNameDialog(context);
      },
      icon: Icon(Icons.edit),
      label: Text(
        AppLocalizations.of(context)!.changeName,
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

  Widget _buildChangePasswordButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
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

  void _showChangeNameDialog(BuildContext context) {
    String fullName = widget.userName;
    List<String> nameParts = fullName.split(' ');
    // Check if there are at least two parts (first and last name)
    String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    String lastName = nameParts.length > 1 ? nameParts[1] : '';
    firstNameController.text = firstName;
    lastNameController.text = lastName;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // change name title
                Text(
                  AppLocalizations.of(context)!.changeName,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // logout notice msg
                Text(AppLocalizations.of(context)!.nameNotice,
                  style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // first name text field
                MyTextField(
                  controller: firstNameController,
                  hintText: AppLocalizations.of(context)!.firstName,
                  keyboardType: TextInputType.name,
                  prefixIcon: const Icon(CupertinoIcons.person),
                  validator: (value) => FormValidators.validateName(value, maxLength: 25),
                  obscureText: false,
                ),
                const SizedBox(height: 16),
                // last name text field
                MyTextField(
                  controller: lastNameController,
                  hintText: AppLocalizations.of(context)!.lastName,
                  keyboardType: TextInputType.name,
                  prefixIcon: const Icon(CupertinoIcons.person),
                  validator: (value) =>
                      FormValidators.validateName(value, maxLength: 25),
                  obscureText: false,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // cancel button
                    Flexible(
                      child: ElevatedButton(
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
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
                    ),
                    const SizedBox(width: 5),
                    // change name button
                    Flexible(
                      child: ElevatedButton(
                          child: Text(
                            AppLocalizations.of(context)!.change,
                            style: GoogleFonts.poppins(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.inversePrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () async {
                            try {
                              await _userRepository.updateUserName(
                                firstNameController.text,
                                lastNameController.text,
                              );
                            } catch (e) {
                              print("Error updating user name: $e");
                              throw Exception("Failed to update user name: $e");
                            }
                            Navigator.of(context).pop();
                          }
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.changePassword,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.passwordNotice,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        context: context,
                        controller: currentPasswordController,
                        hintText: AppLocalizations.of(context)!.currentPassword,
                        obscureText: obscureCurrentPassword,
                        onToggle: () {
                          setState(() {
                            obscureCurrentPassword = !obscureCurrentPassword;
                            iconCurrentPassword = obscureCurrentPassword
                                ? CupertinoIcons.eye_fill
                                : CupertinoIcons.eye_slash_fill;
                          });
                        },
                        icon: iconCurrentPassword,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        context: context,
                        controller: newPasswordController,
                        hintText: AppLocalizations.of(context)!.newPassword,
                        obscureText: obscureNewPassword,
                        onToggle: () {
                          setState(() {
                            obscureNewPassword = !obscureNewPassword;
                            iconNewPassword = obscureNewPassword
                                ? CupertinoIcons.eye_fill
                                : CupertinoIcons.eye_slash_fill;
                          });
                        },
                        icon: iconNewPassword,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        context: context,
                        controller: confirmPasswordController,
                        hintText: AppLocalizations.of(context)!.confirmPass,
                        obscureText: obscureConfirmPassword,
                        onToggle: () {
                          setState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                            iconConfirmPassword = obscureConfirmPassword
                                ? CupertinoIcons.eye_fill
                                : CupertinoIcons.eye_slash_fill;
                          });
                        },
                        icon: iconConfirmPassword,
                        validator: (value) {
                          if (value != newPasswordController.text) {
                            return AppLocalizations.of(context)!
                                .passwordMismatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: ElevatedButton(
                              child: Text(
                                AppLocalizations.of(context)!.cancel,
                                style: GoogleFonts.poppins(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () {
                                currentPasswordController.clear();
                                newPasswordController.clear();
                                confirmPasswordController.clear();
                                Navigator.of(context).pop();
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: ElevatedButton(
                              child: Text(
                                AppLocalizations.of(context)!.change,
                                style: GoogleFonts.poppins(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  await _userRepository.changePassword(
                                    currentPassword: currentPasswordController.text,
                                    newPassword: newPasswordController.text,
                                  );
                                } catch (e) {
                                  throw Exception("Failed to change password: $e");
                                }
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
    IconData? icon,
    String? Function(String?)? validator,
  }) {
    return MyTextField(
      controller: controller,
      hintText: hintText,
      obscureText: obscureText,
      keyboardType: TextInputType.visiblePassword,
      prefixIcon: const Icon(CupertinoIcons.lock_fill),
      validator: validator ?? FormValidators.validatePassword,
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(icon),
      ),
    );
  }
}
