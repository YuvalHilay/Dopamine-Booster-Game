import 'package:Dopamine_Booster/screens/home/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quiz_repository/quiz.repository.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

// Dummy category data
final dummyCategory = Category(
  categoryId: '1',
  categoryName: 'Math',
  quizCount: '2',
  quizzes: [
    Quiz(
      quizId: '1',
      category: 'Math',
      author: 'Sapir Cohen',
      description: 'A simple question to test your general knowledge.',
      question: 'What is the capital of France?',
      answer1: 'Berlin',
      answer2: 'Madrid',
      answer3: 'Paris',
      answer4: 'Rome',
      correctAnswer: 'Paris',
    ),
    Quiz(
      quizId: '2',
      category: 'Math',
      author: 'Anna Smith',
      description: 'A question about the solar system.',
      question: 'Which planet is known as the Red Planet?',
      answer1: 'Earth',
      answer2: 'Mars',
      answer3: 'Jupiter',
      answer4: 'Venus',
      correctAnswer: 'Mars',
    ),
  ],
  );

class _CategoriesScreenState extends State<CategoriesScreen> {
  // Simulating data fetching from DB
  Future<List<Category>> fetchCategories() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    // Example categories data
    return [
      Category(categoryName: 'Science', quizCount: '5', categoryId: '', quizzes: []),
      Category(categoryName: dummyCategory.categoryName, quizCount: dummyCategory.quizCount, categoryId: '' , quizzes: dummyCategory.quizzes),
      Category(categoryName: 'English', quizCount: '3', categoryId: '', quizzes: []),
      Category(categoryName: 'History', quizCount: '3', categoryId: '', quizzes: []),
      Category(categoryName: 'Geography', quizCount: '7', categoryId: '', quizzes: []),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category, size: 32),
            const SizedBox(width: 10), 
            Text(
              AppLocalizations.of(context)!.categories,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two columns
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1, // Adjust tile aspect ratio
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryTile(category: category);
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

  const CategoryTile({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to quiz screen for the selected category
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(category: category),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/categories/${category.categoryName.toLowerCase()}.png',
                height: 130,
                width: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.broken_image,
                    size: 100,
                    color: Colors.grey,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              getLocalizedCategoryName(context, category.categoryName),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${category.quizCount} Quizzes',
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Returns the localized name of a category based on the given `categoryName`.
  String getLocalizedCategoryName(BuildContext context, String categoryName) {
    switch (categoryName) {
      case 'Sports':
        return AppLocalizations.of(context)!.sport;
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
        return categoryName; // Fallback to the original name if no key exists
    }
}
}