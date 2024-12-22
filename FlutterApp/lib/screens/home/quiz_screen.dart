import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quiz_repository/quiz.repository.dart';

class QuizScreen extends StatefulWidget {
  final Category category;

  const QuizScreen({Key? key, required this.category}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentQuizIndex = 0;
  int _score = 0;
  bool _answered = false;
  String? _selectedAnswer;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleAnswer(String answer) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedAnswer = answer;
      if (answer == widget.category.quizzes[_currentQuizIndex].correctAnswer) {
        _score++;
      }
    });

    _animationController.forward();

    Timer(const Duration(seconds: 2), () {
      if (_currentQuizIndex < widget.category.quizzes.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentQuizIndex++;
          _answered = false;
          _selectedAnswer = null;
        });
      } else {
        _showResults();
      }
      _animationController.reset();
    });
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz Completed!'),
          content: Text('Your score: $_score / ${widget.category.quizzes.length}'),
          actions: <Widget>[
            TextButton(
              child: const Text('Try Again'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _currentQuizIndex = 0;
                  _score = 0;
                  _answered = false;
                  _selectedAnswer = null;
                });
                _pageController.jumpToPage(0);
              },
            ),
            TextButton(
              child: const Text('Back to Categories'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.categoryName),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: widget.category.quizzes.isNotEmpty
                  ? (_currentQuizIndex + 1) / widget.category.quizzes.length.toDouble()
                  : 0.0,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.category.quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = widget.category.quizzes[index];
                  return _buildQuizCard(quiz);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard(Quiz quiz) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            quiz.question,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ..._buildAnswerButtons(quiz),
          const SizedBox(height: 16),
          Text(
            'Author: ${quiz.author}',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            quiz.description,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAnswerButtons(Quiz quiz) {
    final answers = [quiz.answer1, quiz.answer2, quiz.answer3, quiz.answer4];
    return answers.map((answer) {
      final isSelected = _selectedAnswer == answer;
      final isCorrect = quiz.correctAnswer == answer;

      Color getButtonColor() {
        if (!_answered) return Colors.white;
        if (isSelected) {
          return isCorrect ? Colors.green.shade100 : Colors.red.shade100;
        }
        if (isCorrect) return Colors.green.shade100;
        return Colors.white;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: isSelected ? 1.0 + (_animation.value * 0.05) : 1.0,
              child: child,
            );
          },
          child: ElevatedButton(
            onPressed: () => _handleAnswer(answer),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black87, backgroundColor: getButtonColor(),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(
                  color: _answered && (isSelected || isCorrect)
                      ? (isCorrect ? Colors.green : Colors.red)
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }).toList();
  }
}