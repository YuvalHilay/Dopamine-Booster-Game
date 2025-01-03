import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 132, 64, 204),
              Color.fromARGB(255, 71, 133, 240),
            ],
          ),
        ),
        child: SafeArea(
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement quiz creation
        },
        icon: const Icon(Icons.add),
        label: Text('Create Quiz'),
        backgroundColor: Color(0xFFFFA500),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/teacherBG.png'),
        fit: BoxFit.cover, // This will make the image cover the whole area of the widget
        opacity: 0.7, // Adjust opacity to dim the background
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: Colors.white,
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
              'Create Category',
              () {
                // TODO: Implement category creation
              },
              Color(0xFFFF6B6B),
            ),
            _buildActionButton(
              context,
              Icons.quiz,
              'Create Quiz',
              () {
                // TODO: Implement quiz creation
              },
              Color(0xFF4ECDC4),
            ),
            _buildActionButton(
              context,
              Icons.bar_chart,
              'View Stats',
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
            ), backgroundColor: color,
            padding: const EdgeInsets.all(20),
          ),
          child: Icon(
            icon,
            size: 30,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Colors.white,
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
          'Statistics',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard(context, '15', AppLocalizations.of(context)!.categories, Color(0xFF6A11CB)),
            _buildStatCard(context, '42', AppLocalizations.of(context)!.quizzes, Color(0xFF2575FC)),
            _buildStatCard(context, '128', 'Active Students', Color(0xFFFFA500)),
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
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
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
          'Recent Activities',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Colors.white,
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white.withOpacity(0.1),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getActivityColor(index),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getActivityIcon(index),
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  _getActivityTitle(context, index),
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                subtitle: Text(
                  _getActivitySubtitle(context, index),
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ),
                trailing: Text(
                  '${index + 1}d ago',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Colors.white60,
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
      'Math Quiz: Algebra Basics',
      'Science: Physics',
      'John Doe',
      'History: World War II',
      'Quiz Master Level 5',
    ];
    return subtitles[index % subtitles.length];
  }
}

