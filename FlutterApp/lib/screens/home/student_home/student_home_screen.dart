import 'package:Dopamine_Booster/components/app_bar.dart';
import 'package:Dopamine_Booster/components/my_drawer.dart';
import 'package:Dopamine_Booster/screens/home/home_menu/profile_screen.dart';
import 'package:Dopamine_Booster/screens/home/student_home/game_page.dart';
import 'package:Dopamine_Booster/screens/home/student_home/grade_selection_page.dart';
import 'package:Dopamine_Booster/screens/home/student_home/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentHomeScreen extends StatefulWidget {
  final MyUser user;

  const StudentHomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentPageIndex = 0;
  List<String> studentNotifications = [
    "🎉 New quiz added! Test your skills now.",
    "⏰ Time to play the dopamine booster game.",
    "📈 Your weekly progress is ready to view.",
  ];
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(gender: widget.user.gender),
      GradeSelectionScreen(userId: widget.user.userId, userName: '${widget.user.firstName} ${widget.user.lastName}'),
      //CategoriesScreen(userId: widget.user.userId, userName: '${widget.user.firstName} ${widget.user.lastName}'),
      GamePage(),
      ProfileScreen(email: widget.user.email, userName: '${widget.user.firstName} ${widget.user.lastName}'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: MainAppBar(context: context, user: widget.user, notifications: studentNotifications),
      drawer: MyDrawer(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentPageIndex],
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
          BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.home),
              label: AppLocalizations.of(context)!.home),
          BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.book),
              label: AppLocalizations.of(context)!.quizzes),
          BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.gamecontroller),
              label: AppLocalizations.of(context)!.game),
          BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.profile_circled),
              label: AppLocalizations.of(context)!.profile),
        ],
      ),
    );
  }

}
