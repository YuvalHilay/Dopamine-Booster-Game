import 'package:Dopamine_Booster/components/categories_bar.dart';
import 'package:Dopamine_Booster/screens/home/student_home/quiz_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quiz_repository/quiz.repository.dart';

// Categories screen displaying a list of quiz categories for the user.
class CategoriesScreen extends StatefulWidget {
  final String userId; // User's unique identifier.
  final String userName; // User's name.

  CategoriesScreen({Key? key, required this.userId, required this.userName})
      : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final QuizRepository _quizRepository = FirebaseQuizRepo(); // Repository for quiz-related operations.
  late Future<List<Grade>> _gradesList; // Future to store grades fetched from the repository.

  // Default list of category names for localization and fallback purposes.
  List<String> defCategoryNames = [
    'Sports',
    'Science',
    'History',
    'Math',
    'Geography',
    'Physics',
    'English'
  ];
  String _searchQuery = ''; // Holds the user's search query.

  @override
  void initState() {
    super.initState();
    // Fetch the grades for the user when the screen initializes.
    _gradesList = _quizRepository.fetchUserGrades(widget.userId);
  }

  // Fetch all quiz categories from the repository.
  Future<List<Category>> fetchCategories() async {
    try {
      return await _quizRepository.getAllCategories();
    } catch (e) {
      return []; // Return an empty list if there's an error.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CategoriesBar(
        onSearchChanged: (newQuery) {
          setState(() {
            _searchQuery = newQuery; // Update the search query dynamically.
          });
        },
      ),
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          // Combine fetching categories and grades in one Future.
          future: Future.wait([
            fetchCategories(),
            _quizRepository.fetchUserGrades(widget.userId),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator()); // Show loading indicator.
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}')); // Display errors if any.
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No data available.')); // Handle no data scenario.
            }

            // Extract categories from snapshot data.
            final categories = snapshot.data![0] as List<Category>;
            // Filter categories based on the user's search query.
            final filteredCategories = categories
                .where((category) =>
                    category.categoryName.toLowerCase().contains(_searchQuery))
                .toList();

            return FutureBuilder<List<Grade>>(
              future: _gradesList,
              builder: (context, gradesSnapshot) {
                if (gradesSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final grades = gradesSnapshot.data ?? [];

                // Build a grid view to display categories.
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two items per row.
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];

                    // Find grade associated with the current category.
                    final grade = grades.firstWhere(
                      (grade) => grade.categoryId == category.categoryId,
                      orElse: () => Grade(
                          categoryId: '',
                          categoryName: '',
                          isComplete: false,
                          userId: '',
                          score: '0/0',
                          userName: widget.userName),
                    );

                    // Render individual category tiles.
                    return CategoryTile(
                      userId: widget.userId,
                      category: category,
                      defCategoryNames: defCategoryNames,
                      searchQuery: _searchQuery,
                      userName: widget.userName,
                      grade: grade, // Pass grade to the tile.
                      onTileTapped: () {
                        setState(() {
                          _gradesList =
                              _quizRepository.fetchUserGrades(widget.userId);
                        });
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Widget for rendering individual category tiles.
class CategoryTile extends StatelessWidget {
  final Category category;
  final List<String> defCategoryNames;
  final String searchQuery;
  final String userId;
  final String userName;
  final Grade grade; // Represents the grade for the category.
  final VoidCallback onTileTapped; // Callback for reloading data on changes.

  const CategoryTile({
    Key? key,
    required this.category,
    required this.defCategoryNames,
    required this.userId,
    required this.grade,
    required this.searchQuery,
    required this.userName,
    required this.onTileTapped,
  }) : super(key: key);

  // Localize category names based on the app's language settings.
  String getLocalizedCategoryName(BuildContext context, String categoryName) {
    switch (categoryName) {
      case 'Sports':
        return AppLocalizations.of(context)!.sport;
      case 'Physics':
        return AppLocalizations.of(context)!.physics;
      case 'Science':
        return AppLocalizations.of(context)!.science;
      case 'History':
        return AppLocalizations.of(context)!.history;
      case 'Math':
        return AppLocalizations.of(context)!.math;
      case 'Geography':
        return AppLocalizations.of(context)!.geography;
      case 'English':
        return AppLocalizations.of(context)!.english;
      default:
        return categoryName; // Default to the original name if no localization is found.
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
                category: category, userId: userId, userName: userName),
          ),
        );

        // Reload data if the user completes a quiz or data changes.
        if (result == true) {
          onTileTapped();
        }
      },
      child: Card(
        elevation: 4,
        color: grade.isComplete
            ? const Color.fromARGB(255, 153, 238, 156) // Completed category color.
            : Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildCategoryImage(), // Category image widget.
            ),
            const SizedBox(height: 10),
            Text(
              getLocalizedCategoryName(context, category.categoryName),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: grade.isComplete
                    ? Colors.black
                    : Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              AppLocalizations.of(context)!.quizCount(category.quizCount),
              style: TextStyle(
                  fontSize: 14,
                  color: grade.isComplete
                      ? Colors.black
                      : Theme.of(context).colorScheme.inversePrimary),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: grade.isComplete
                        ? Colors.green
                        : Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    grade.isComplete ? Icons.check : Icons.info_outline,
                    color: grade.isComplete
                        ? Colors.white
                        : Theme.of(context).colorScheme.inversePrimary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.grade(grade.score),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: grade.isComplete
                        ? Colors.black
                        : Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build category-specific image or fallback to a default image.
  Widget _buildCategoryImage() {
    String? matchingName;
    for (String defName in defCategoryNames) {
      if (category.categoryName.contains(defName)) {
        matchingName = defName;
        break;
      }
    }
    if (matchingName != null) {
      return Image.asset(
        'assets/categories/${matchingName.toLowerCase()}.png',
        height: 130,
        width: 130,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultImage();
        },
      );
    } else {
      return _buildDefaultImage();
    }
  }

  // Default image for categories with no specific image.
  Widget _buildDefaultImage() {
    return Image.asset(
      'assets/categories/default_category.png',
      height: 130,
      width: 130,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 130,
          width: 130,
          color: Colors.grey[300],
          child: const Icon(
            Icons.category,
            size: 50,
            color: Colors.grey,
          ),
        );
      },
    );
  }
}
