import 'package:Dopamine_Booster/components/categories_bar.dart';
import 'package:Dopamine_Booster/screens/home/student_home/quiz_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quiz_repository/quiz.repository.dart';
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}
class _CategoriesScreenState extends State<CategoriesScreen> {
  final QuizRepository _quizRepository = FirebaseQuizRepo();
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
        child: FutureBuilder<List<Category>>(
          future: fetchCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No categories available.'));
            }

            final categories = snapshot.data!;
            final filteredCategories = categories
                .where((category) => category.categoryName
                    .toLowerCase()
                    .contains(_searchQuery))
                .toList();

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
                return CategoryTile(
                  category: category,
                  defCategoryNames: defCategoryNames,
                  searchQuery: _searchQuery,
                  getLocalizedCategoryName: (context, categoryName) => categoryName,
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
  final String Function(BuildContext, String) getLocalizedCategoryName;

  const CategoryTile({
    Key? key,
    required this.category,
    required this.defCategoryNames,
    required this.searchQuery,
    required this.getLocalizedCategoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizedCategoryName =
        getLocalizedCategoryName(context, category.categoryName);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(category: category),
          ),
        );
      },
      child: Card(
        elevation: 4,
        color: Theme.of(context).colorScheme.primary,
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
              style: const TextStyle(fontSize: 14, color: Colors.grey),
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
