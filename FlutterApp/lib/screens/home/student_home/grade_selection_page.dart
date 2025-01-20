import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'categories_screen.dart';

class GradeSelectionScreen extends StatelessWidget {
  final String userId;
  final String userName;

  const GradeSelectionScreen({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List of grade options with corresponding icons and colors
    final List<Map<String, dynamic>> grades = [
      {'name': AppLocalizations.of(context)!.thirdGrade, 'icon': Icons.looks_3, 'color': Colors.purple},
      {'name': AppLocalizations.of(context)!.fourthGrade, 'icon': Icons.looks_4, 'color': Colors.green},
      {'name': AppLocalizations.of(context)!.fifthGrade, 'icon': Icons.looks_5, 'color': Colors.blue},
      {'name': AppLocalizations.of(context)!.sixthGrade, 'icon': Icons.looks_6, 'color': Colors.red},
      {'name': AppLocalizations.of(context)!.seventhGrade, 'icon': Icons.grade, 'color': Colors.orange},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Container(
        child: SafeArea(
          child: Column(
            children: [
              // Animated header
              _buildHeader(context),
              // Scrollable grade list
              Expanded(child: _buildGradeList(context, grades)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.school,
            size: 80,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.selectGrade,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.chooseGrade,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGradeList(BuildContext context, List<Map<String, dynamic>> grades) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: grades.length,
      itemBuilder: (context, index) {
        final grade = grades[index];
        return _buildGradeCard(context, grade);
      },
    );
  }

  Widget _buildGradeCard(BuildContext context, Map<String, dynamic> grade) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToCategoriesScreen(context, grade['name']),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Grade icon with background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: grade['color'].withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(grade['icon'], color: grade['color'], size: 32),
              ),
              const SizedBox(width: 16),
              // Grade name
              Expanded(
                child: Text(
                  grade['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Arrow icon for visual cue
              Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.inversePrimary),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation to CategoriesScreen
  void _navigateToCategoriesScreen(BuildContext context, String selectedGrade) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CategoriesScreen(
          userId: userId,
          userName: userName,
          grade: selectedGrade,
        ),
        transitionDuration: Duration(seconds: 0), // No animation
      ),
    );
  }
}

