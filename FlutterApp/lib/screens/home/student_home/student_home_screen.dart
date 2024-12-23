import 'package:Dopamine_Booster/components/my_drawer.dart';
import 'package:Dopamine_Booster/screens/auth/blocs/sign_in_bloc/bloc/sign_in_bloc.dart';
import 'package:Dopamine_Booster/screens/home/categories_screen.dart';
import 'package:Dopamine_Booster/screens/home/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:Dopamine_Booster/components/logout_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class StudentHomeScreen extends StatefulWidget {
  final MyUser user;

  const StudentHomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentPageIndex = 0;

  // List of pages for bottom navigation
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const Placeholder(child: Center(child: Text('Home Page'))),
      const CategoriesScreen(),
      const Placeholder(child: Center(child: Text('Game  Page'))),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Welcome ${widget.user.userRole}, ${widget.user.firstName} ${widget.user.lastName}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(CupertinoIcons.bars),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final shouldLogout = await showLogoutDialog(context);
              if (shouldLogout) {
                // Perform the sign-out logic
                BlocProvider.of<SignInBloc>(context).add(SignOutRequired());
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentPageIndex], // Display current page
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        onTap: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: const Icon(CupertinoIcons.home), label: AppLocalizations.of(context)!.home),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.book), label: AppLocalizations.of(context)!.quizzes),
          BottomNavigationBarItem(icon: const Icon(CupertinoIcons.gamecontroller), label: AppLocalizations.of(context)!.game),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.profile_circled), label: AppLocalizations.of(context)!.profile),
        ],
      ),
    );
  }
}