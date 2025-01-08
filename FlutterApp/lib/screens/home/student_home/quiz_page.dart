import 'dart:async';
import 'package:Dopamine_Booster/components/popup_msg.dart';
import 'package:flutter/material.dart';
import 'package:quiz_repository/quiz.repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QuizScreen extends StatefulWidget {
  final Category category;
  final String userId;
  final String userName;

  const QuizScreen({Key? key, required this.category, required this.userId, required this.userName}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  final QuizRepository quizRepository = FirebaseQuizRepo(); // Initialize the quiz repository
  final QuizRepository gradeRepository = FirebaseQuizRepo(); // Initialize the quiz repository
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  int _currentQuizIndex = 0;
  int _score = 0;
  bool _answered = false;
  String? _selectedAnswer;
  List<Quiz> _quizzes = [];
  bool _isLoading = true; // To handle loading state

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    _loadQuizzes(); // Load quizzes for the selected category
  }

  // Fetches quizzes for the selected category
  Future<void> _loadQuizzes() async {
    try {
      List<Quiz> quizzes = await quizRepository.getQuizzesByCategory(widget.category.categoryId);
      setState(() {
        _quizzes = quizzes;
        _isLoading = false;  // Set loading to false once quizzes are loaded
      });
    } catch (e) {
      displayMessageToUser('Failed to load quizzes!', context);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

   // Handles the user's answer selection
  void _handleAnswer(String answer) {
    if (_answered) return;

    setState(() {
      _answered = true; // Mark question as answered
      _selectedAnswer = answer; // Save selected answer
      if (answer == _quizzes[_currentQuizIndex].correctAnswer) {
        _score++;
      }
    });

    _animationController.forward(); // Trigger animation

    Timer(const Duration(seconds: 2), () {
      if (_currentQuizIndex < _quizzes.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentQuizIndex++;
          _answered = false;
          _selectedAnswer = null; // Reset selected answer
        });
      } else {
        _showResults(widget.category.categoryId, widget.category.categoryName, widget.userId);
      }
      _animationController.reset(); // Reset animation
    });
  }

  // Checks if the user has completed the quiz
  bool isQuizComplete(int score, int totalQuizzes) {
    return score == totalQuizzes;
  }

  // Displays the results dialog after completing the quiz
  void _showResults(String categoryId, String categoryName, String userId) {
    final bool isComplete = isQuizComplete(_score, _quizzes.length);
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.quizComplete),
          content: Text('Your score: $_score / ${_quizzes.length}'),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.tryAgain),
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
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // Set the desired color for the Try Again button
              ),
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.backCat),
              onPressed: () async {
                // Save the grade before navigating back
                await gradeRepository.saveGrade(
                  categoryId,
                  categoryName,
                  widget.userName,
                  isComplete,
                  userId,
                  '$_score/${_quizzes.length}', // Save as percentage or normalized score 
                );

                Navigator.of(context).pop();
                Navigator.pop(context, true); // Pass a flag to indicate data has changed
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.green, // Set the desired color for the Back to Categories button
              ),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  LinearProgressIndicator(
                    value: _quizzes.isNotEmpty
                        ? (_currentQuizIndex + 1) / _quizzes.length.toDouble()
                        : 0.0,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 16),
                  // Add question number display
                  if (_quizzes.isNotEmpty)
                    Text(
                      '${_quizzes.length} / ${_currentQuizIndex + 1}', // Show current question/total questions
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 16),
                 // Quiz content
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _quizzes.length,
                      itemBuilder: (context, index) {
                        final quiz = _quizzes[index];
                        return _buildQuizCard(quiz);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Builds a single quiz card
  Widget _buildQuizCard(Quiz quiz) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (quiz.img != null && quiz.img!.isNotEmpty)
            Container(
              height: 200, // Adjust the height as needed
              margin: const EdgeInsets.only(bottom: 16),
              child: Image.network(
                quiz.img!,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading image: $error');
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.red, size: 50),
                    ),
                  );
                },
              ),
            ),
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
          // Add the quiz description
          Text(
            AppLocalizations.of(context)!.quizDescRes(quiz.description),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // add the author of the quiz
          Text(
            AppLocalizations.of(context)!.quizDescRes(quiz.author),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Builds answer buttons for the quiz
  List<Widget> _buildAnswerButtons(Quiz quiz) {
    final answers = [quiz.answer1, quiz.answer2, quiz.answer3, quiz.answer4];
    return answers.map((answer) {
      final isSelected = _selectedAnswer == answer; // Check if answer is selected
      final isCorrect = quiz.correctAnswer == answer; // Check if answer is correct

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
            onPressed: () => _handleAnswer(answer),  // Disable if answered
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black87,
              backgroundColor: getButtonColor(),
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
