import 'package:Dopamine_Booster/components/app_bar.dart';
import 'package:Dopamine_Booster/components/my_drawer.dart';
import 'package:Dopamine_Booster/screens/auth/blocs/sign_in_bloc/bloc/sign_in_bloc.dart';
import 'package:Dopamine_Booster/screens/home/home_menu/profile_screen.dart';
import 'package:Dopamine_Booster/screens/home/teacher_home/add_caterogies_page.dart';
import 'package:Dopamine_Booster/screens/home/teacher_home/add_quiz_page.dart';
import 'package:Dopamine_Booster/screens/home/teacher_home/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:Dopamine_Booster/components/logout_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TeacherHomeScreen extends StatefulWidget {
  final MyUser user;

  const TeacherHomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _currentPageIndex = 0;
  
  // List of pages for bottom navigation
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(),
      AddQuizScreen(authorName: '${widget.user.firstName} ${widget.user.lastName}'),
      const AddCategoriesScreen(),
      const ProfileScreen(),
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: MainAppBar(context: context, user: widget.user),
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
          BottomNavigationBarItem(icon: const Icon(CupertinoIcons.book), label: AppLocalizations.of(context)!.addQuizBtn),
          BottomNavigationBarItem(icon: const Icon(CupertinoIcons.gamecontroller), label: AppLocalizations.of(context)!.addCatergory),
          BottomNavigationBarItem(icon: const Icon(CupertinoIcons.profile_circled), label: AppLocalizations.of(context)!.profile),
        ],
      ),
    );
  }
}