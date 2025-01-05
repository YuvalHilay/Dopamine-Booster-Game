import 'package:Dopamine_Booster/components/app_bar.dart';
import 'package:Dopamine_Booster/components/my_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ParentHomeScreen extends StatefulWidget {
  final MyUser user;

  const ParentHomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  int _currentPageIndex = 0;

  // List of pages for bottom navigation
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const Placeholder(child: Center(child: Text('Home Page'))),
      const Placeholder(child: Center(child: Text('View Stats'))),
      const Placeholder(child: Center(child: Text('Contact Teacher'))),
      const Placeholder(child: Center(child: Text('Profile'))),
    ];
  }
List<String> notifications = [
    "🎉 New quiz added! hsh Test your skills now.",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: MainAppBar(context: context, user: widget.user, notifications: notifications),
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
          const BottomNavigationBarItem(icon: Icon(CupertinoIcons.book), label: 'View Stats'),
          const BottomNavigationBarItem(icon: Icon(CupertinoIcons.gamecontroller), label: 'Contact Teacher'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.profile_circled), label: AppLocalizations.of(context)!.profile),
        ],
      ),
    );
  }
}