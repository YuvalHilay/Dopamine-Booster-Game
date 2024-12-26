import 'dart:ui';
import 'package:Dopamine_Booster/screens/auth/blocs/sign_in_bloc/bloc/sign_in_bloc.dart';
import 'package:Dopamine_Booster/screens/auth/blocs/sign_up_bloc/bloc/sign_up_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../blocs/authentication_bloc/authentication_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  bool isSignIn = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleScreen() {
    setState(() {
      isSignIn = !isSignIn;
      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      _buildVividBackground(constraints),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            _buildLogo(),
                            const SizedBox(height: 5),
                            Expanded(
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: isSignIn
                                      ? BlocProvider<SignInBloc>(
                                          key: const ValueKey('SignIn'),
                                          create: (context) => SignInBloc(
                                              context.read<AuthenticationBloc>().userRepository),
                                          child: const SignInScreen(),
                                        )
                                      : BlocProvider<SignUpBloc>(
                                          key: const ValueKey('SignUp'),
                                          create: (context) => SignUpBloc(
                                              context.read<AuthenticationBloc>().userRepository),
                                          child: const SignUpScreen(),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildToggleButton(),
                            const SizedBox(height: 20),
                            _buildDivider(),
                            const SizedBox(height: 20),
                            _buildGoogleSignInButton(),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: _buildSettingsButton(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVividBackground(BoxConstraints constraints) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue[400]!,
                Colors.purple[500]!,
                Colors.pink[300]!,
              ],
            ),
          ),
        ),
        Positioned(
          top: -constraints.maxHeight * 0.15,
          right: -constraints.maxWidth * 0.4,
          child: Container(
            height: constraints.maxWidth * 0.8,
            width: constraints.maxWidth * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.yellow[300]!.withOpacity(0.3),
            ),
          ),
        ),
        Positioned(
          top: constraints.maxHeight * 0.4,
          left: -constraints.maxWidth * 0.3,
          child: Container(
            height: constraints.maxWidth * 0.6,
            width: constraints.maxWidth * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green[300]!.withOpacity(0.2),
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(26),      
          child: Image.asset(
            'assets/app_icon.png',
            height: 80,
            width: 80,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Dopamine Booster',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: const Offset(2, 2),
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
        ),
      ],
    );
  }

  Widget _buildToggleButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isSignIn
              ? AppLocalizations.of(context)!.noAcc
              : AppLocalizations.of(context)!.haveAcc,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        TextButton(
          onPressed: toggleScreen,
          child: Text(
            isSignIn
                ? AppLocalizations.of(context)!.regsHere
                : AppLocalizations.of(context)!.loginHere,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.yellow[300],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            AppLocalizations.of(context)!.signupWith,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [Colors.red[400]!, Colors.orange[300]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          // Implement Google Sign-In logic
        },
        icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white),
        label: Text(
          "sign with google",
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.blue[300]!, Colors.purple[300]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.settings, color: Colors.white),
        onPressed: () {
          Navigator.pushNamed(context, '/settings');
        },
      ),
    );
  }
}
