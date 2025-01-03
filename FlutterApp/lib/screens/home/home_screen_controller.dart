import 'package:flutter/material.dart';
import 'package:user_repository/user_repository.dart';
import 'parent_home/parent_home_screen.dart';
import 'student_home/student_home_screen.dart';
import 'teacher_home/teacher_home_screen.dart';

class HomeScreenController {
  
  static Widget getHomeScreen(MyUser? user) {
    if (user == null) {
      return _buildErrorScreen('User not found');
    }
    
    switch (user.userRole.toLowerCase()) {
      case 'student':
        return StudentHomeScreen(user: user);
      case 'teacher':
        return TeacherHomeScreen(user: user);
      case 'parent':
        return ParentHomeScreen(user: user);
      default:
        return _buildErrorScreen('Invalid user role: ${user.userRole}');
    }
  }

  static Widget _buildErrorScreen(String message) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(message),
          ],
        ),
      ),
    );
  }
}

