import 'package:Dopamine_Booster/utils/localizedNames.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_repository/quiz.repository.dart';

class TeacherStatsScreen extends StatefulWidget {
  const TeacherStatsScreen({Key? key}) : super(key: key);

  @override
  _TeacherStatsScreenState createState() => _TeacherStatsScreenState();
}

class _TeacherStatsScreenState extends State<TeacherStatsScreen> {
  final QuizRepository quizRepository = FirebaseQuizRepo(); // Initialize the quiz repository

  // Initialize an empty list for student progress
  List<Map<String, dynamic>> _studentProgress = [];

  @override
  void initState() {
    super.initState();
    loadGrades();
  }

  // Fetch grades from the database
  Future<void> loadGrades() async {
    try {
      // Fetch the student progress data
      final studentProgressData = await quizRepository.fetchAllGrades();

      // Log the fetched data to check its structure
      print(studentProgressData);

      // Update the UI with the fetched data
      setState(() {
        _studentProgress.clear(); // Clear any existing data
        _studentProgress.addAll(studentProgressData); // Add the new data
      });
    } catch (e) {
      print('Error loading grades: $e');
    }
  }

  // Function to calculate the total score for a category and `isPlayed` value
  int _calculateCategoryTotal(List<Map<String, dynamic>> grades, String category, bool isPlayed) {
    return grades
        .where((grade) => grade['categoryName'] == category && grade['isPlayed'] == isPlayed)
        .fold(0, (sum, grade) => sum + (grade['score'] as int));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStudentList(context), // Displays the list of students and their grades
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // App bar widget
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.viewStats,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 143, 62, 230),
                Color.fromARGB(255, 81, 145, 255),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  // Builds the list of students and their grades
  Widget _buildStudentList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _studentProgress.map((student) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'], // Display the student's name
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Dynamically build category stats for each student
                ..._buildDynamicCategoryStats(student['grades']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Builds dynamic category stats based on the student's grades
  List<Widget> _buildDynamicCategoryStats(List<Map<String, dynamic>> grades) {
    Set categories = grades.map((grade) => grade['categoryName']).toSet();
    List<Widget> categoryStatsWidgets = [];

    // Loop through each category and build the stats for it
    for (var category in categories) {
      final totalPlayed = _calculateCategoryTotal(grades, category, true);
      final totalNotPlayed = _calculateCategoryTotal(grades, category, false);

      categoryStatsWidgets.add(
        _buildCategoryStats(category, totalPlayed, totalNotPlayed),
      );
    }

    return categoryStatsWidgets;
  }

  // Builds a category stats view (for each subject: Math, Science, History)
  Widget _buildCategoryStats(String category, int totalPlayed, int totalNotPlayed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getLocalizedCategoryName(context,category),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildGradeColumn(AppLocalizations.of(context)!.playedGrade, totalPlayed),
            _buildGradeColumn(AppLocalizations.of(context)!.notPlayedGrade, totalNotPlayed),
          ],
        ),
        const SizedBox(height: 6),
        _buildCategoryProgressBar(totalPlayed, totalNotPlayed),
      ],
    );
  }

  // Builds a column showing the label and the score for each category
  Widget _buildGradeColumn(String label, int totalScore) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color:  Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        '$totalScore',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: label == AppLocalizations.of(context)!.playedGrade ? Colors.green : Colors.red,
        ),
      ),
    ],
  );
}

  // Displays a progress bar comparing 'Played' vs 'Not Played' grades for a specific category
  Widget _buildCategoryProgressBar(int totalPlayed, int totalNotPlayed) {
    final total = totalPlayed + totalNotPlayed;
    final playedPercentage = total > 0 ? totalPlayed / total : 0;
    final notPlayedPercentage = total > 0 ? totalNotPlayed / total : 0;

    return Column(
      children: [
        LinearProgressIndicator(
          value: playedPercentage.toDouble(),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: notPlayedPercentage.toDouble(),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
