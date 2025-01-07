import 'package:Dopamine_Booster/components/categories_bar.dart';
import 'package:Dopamine_Booster/screens/home/student_home/quiz_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quiz_repository/quiz.repository.dart';

class CategoriesScreen extends StatefulWidget {
  final String userId;
  final String userName;
  CategoriesScreen({Key? key, required this.userId, required this.userName}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final QuizRepository _quizRepository = FirebaseQuizRepo();
  late Future<List<Grade>> _gradesList;
  List<String> defCategoryNames = [
    'Sports',
    'Science',
    'History',
    'Math',
    'Geography',
    'Physics',
    'English'
  ];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _gradesList = _quizRepository.fetchUserGrades(widget.userId);
  }

  Future<List<Category>> fetchCategories() async {
    try {
      return await _quizRepository.getAllCategories();
    } catch (e) {
      return [];
    }
  }

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
        return categoryName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CategoriesBar(
        onSearchChanged: (newQuery) {
          setState(() {
            _searchQuery = newQuery;
          });
        },
      ),
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: Future.wait([
            fetchCategories(), // Fetch categories
            _quizRepository.fetchUserGrades(widget.userId), // Fetch grades
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No data available.'));
            }

            // Extract categories and grades from the snapshot
            final categories = snapshot.data![0] as List<Category>;
            final grades = snapshot.data![1] as List<Grade>;
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

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];

                    // Find the grade for the category
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

                    return CategoryTile(
                      userId: widget.userId,
                      category: category,
                      defCategoryNames: defCategoryNames,
                      searchQuery: _searchQuery,
                      userName: widget.userName,
                      grade: grade, // Pass the grade to the CategoryTile
                      getLocalizedCategoryName: (context, categoryName) =>
                          categoryName,
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

class CategoryTile extends StatelessWidget {
  final Category category;
  final List<String> defCategoryNames;
  final String searchQuery;
  final String userId;
  final String userName;
  final Grade grade; // Add the grade parameter
  final VoidCallback onTileTapped; // New callback for reloading
  final String Function(BuildContext, String) getLocalizedCategoryName;

  const CategoryTile({
    Key? key,
    required this.category,
    required this.defCategoryNames,
    required this.userId,
    required this.grade, // Accept grade
    required this.searchQuery,
    required this.userName,
    required this.getLocalizedCategoryName,
    required this.onTileTapped, // Required parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizedCategoryName =
        getLocalizedCategoryName(context, category.categoryName);

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                QuizScreen(category: category, userId: userId, userName: userName),
          ),
        );

        // Trigger callback if data changes
        if (result == true) {
          onTileTapped();
        }
      },
      child: Card(
        elevation: 4,
        color: grade.isComplete
            ? const Color.fromARGB(255, 153, 238, 156)
            : Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildCategoryImage(),
            ),
            const SizedBox(height: 10),
            Text(
              localizedCategoryName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              AppLocalizations.of(context)!.quizCount(category.quizCount),
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
            const SizedBox(height: 5),
            // Display the grade below the quiz count
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the row content
              children: [
                if (grade.isComplete)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check, // Icon for completion
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                const SizedBox(width: 8), // Small space between icon and text
                Text(
                  'Grade: ${grade.score}', // Updated text
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
