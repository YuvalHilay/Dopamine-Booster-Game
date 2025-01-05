import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_repository/quiz.repository.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToAddQuiz;
  final VoidCallback onNavigateToAddCategory;
  const HomeScreen({Key? key, required this.onNavigateToAddQuiz, required this.onNavigateToAddCategory}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final QuizRepository quizRepository = FirebaseQuizRepo(); // Initialize the quiz repository
  String categoryCount = '0';
  String quizCount = '0';

  @override
  void initState() {
    super.initState();
    fetchAndDisplayDBCounts(); // Call the method when the page loads
  }

  Future<void> fetchAndDisplayDBCounts() async {
    try {
      final categories = await quizRepository.getCategoryCount();
      final quizzes = await quizRepository.getQuizCount();

      // Use setState to update UI
      setState(() {
        categoryCount = categories;
        quizCount = quizzes;
      });
    } catch (e) {
      print('Failed to get counts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    _buildStatistics(context),
                    const SizedBox(height: 24),
                    _buildRecentActivities(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/teacherBG.png'),
          fit: BoxFit.cover,
          opacity: 0.7,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppLocalizations.of(context)!.quickActions,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                context,
                Icons.category,
                AppLocalizations.of(context)!.addCatergory,
                widget.onNavigateToAddCategory,
                Color(0xFFFF6B6B),
              ),
              _buildActionButton(
                context,
                Icons.quiz,
                AppLocalizations.of(context)!.addQuizBtn,
                widget.onNavigateToAddQuiz,
                Color(0xFF4ECDC4),
              ),
              _buildActionButton(
                context,
                Icons.bar_chart,
                AppLocalizations.of(context)!.viewStats,
                () {
                  // TODO: Implement stats view
                },
                Color(0xFFFFD93D),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
    Color color,
  ) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: color,
            padding: const EdgeInsets.all(20),
          ),
          child: Icon(
            icon,
            size: 30,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: 14,
            ),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatistics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.statistics,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard(context, categoryCount,
                AppLocalizations.of(context)!.categories, Color(0xFF6A11CB)),
            _buildStatCard(context, quizCount,
                AppLocalizations.of(context)!.quizzes, Color(0xFF2575FC)),
            _buildStatCard(context, '3', AppLocalizations.of(context)!.activeStudents, Color(0xFFFFA500)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, Color color) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.recentActivities,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getActivityColor(index),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getActivityIcon(index),
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                title: Text(
                  _getActivityTitle(context, index),
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                subtitle: Text(
                  _getActivitySubtitle(context, index),
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),
                trailing: Text(
                  '${index + 1}d ago',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getActivityIcon(int index) {
    final icons = [
      Icons.quiz,
      Icons.category,
      Icons.person_add,
      Icons.edit,
      Icons.star,
    ];
    return icons[index % icons.length];
  }

  Color _getActivityColor(int index) {
    final colors = [
      Color(0xFFFF6B6B),
      Color(0xFF4ECDC4),
      Color(0xFFFFD93D),
      Color(0xFF6A11CB),
      Color(0xFF2575FC),
    ];
    return colors[index % colors.length];
  }

  String _getActivityTitle(BuildContext context, int index) {
    final titles = [
      'New Quiz Created',
      'New Category Added',
      'New Student Joined',
      'Quiz Updated',
      'Achievement Unlocked',
    ];
    return titles[index % titles.length];
  }

  String _getActivitySubtitle(BuildContext context, int index) {
    final subtitles = [
      'Math Quiz: Sixth Grade',
      'Science: Physics',
      'Shoval David',
      'History: World War II',
      'Quiz Master Level 5',
    ];
    return subtitles[index % subtitles.length];
  }
}
