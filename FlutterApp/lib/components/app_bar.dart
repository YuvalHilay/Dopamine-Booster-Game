import 'package:Dopamine_Booster/screens/auth/blocs/sign_in_bloc/bloc/sign_in_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_repository/user_repository.dart';
import 'logout_dialog.dart';
import 'notificationMenu.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final MyUser user;
  final BuildContext context;

  MainAppBar({required this.context, required this.user});

  @override
  Size get preferredSize => Size.fromHeight(85);


  @override
  Widget build(BuildContext context) {
    return  Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[300]!,
              Colors.purple[300]!,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 17.0, vertical: 12.0),
            child: Row(
              children: [
                _buildMenuButton(),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!
                            .welcomeUser(user.userRole),
                        style: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                NotificationIcon(),
                const SizedBox(width: 12),
                // Logout Button
                _buildLogoutButton(),
              ],
            ),
          ),
        ),
    );  
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
                onTap: () async {
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout) {
                    // Perform the sign-out logic
                    BlocProvider.of<SignInBloc>(context)
                        .add(SignOutRequired());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              );
  }

  Widget _buildMenuButton() {
    return Builder(
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.bars,
              color: Colors.white,
              size: 28,
            ),
          ),
        );
      },
    );
  }

}
