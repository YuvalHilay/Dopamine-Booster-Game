// Dummy quiz screen for category selection
import 'package:Dopamine_Booster/screens/home/categories_screen.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatelessWidget {
  final Category category;

  const QuizScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${category.name} Quizzes'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text('Display quizzes for ${category.name}'),
      ),
    );
  }
}
