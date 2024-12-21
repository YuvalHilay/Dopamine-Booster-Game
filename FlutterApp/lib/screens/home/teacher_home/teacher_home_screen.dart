import 'package:Dopamine_Booster/components/my_drawer.dart';
import 'package:Dopamine_Booster/screens/auth/blocs/sign_in_bloc/bloc/sign_in_bloc.dart';
import 'package:Dopamine_Booster/screens/home/teacher_home/add_quiz_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:Dopamine_Booster/components/logout_dialog.dart';

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
      const Placeholder(child: Center(child: Text('Home Page'))),
      const AddQuizScreen(),
      const Placeholder(child: Center(child: Text('Add Catagory'))),
      const Placeholder(child: Center(child: Text('Profile'))),
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Welcome, ${widget.user.firstName} ${widget.user.lastName}',
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
            tooltip: 'Logout',
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
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.book), label: 'Add Quizzes'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.gamecontroller), label: 'Add Catagory'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.profile_circled), label: 'Profile'),
        ],
      ),
    );
  }
}