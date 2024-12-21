import 'package:Dopamine_Booster/screens/home/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Mock data model for categories
class Category {
  final String name;
  //final String imageUrl;
  final int quizCount;

  Category({required this.name, required this.quizCount});
}

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // Simulating data fetching from DB
  Future<List<Category>> fetchCategories() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    // Example categories data
    return [
      Category(name: AppLocalizations.of(context)!.science, quizCount: 5),
      Category(name: AppLocalizations.of(context)!.math, quizCount: 13),
      Category(name: AppLocalizations.of(context)!.english, quizCount: 3),
      Category(name: AppLocalizations.of(context)!.geography, quizCount: 3),
      Category(name: AppLocalizations.of(context)!.history, quizCount: 7),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.categories,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
                childAspectRatio: 0.75, // Adjust tile aspect ratio
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
                  'assets/categories/${category.name.toLowerCase()}.png',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.broken_image,
                      size: 120,
                      color: Colors.grey,
                    );
                  },
                )),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${category.quizCount} Quizzes',
              style: const TextStyle(fontSize: 17, color: Colors.grey),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
