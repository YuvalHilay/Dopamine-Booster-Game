import 'package:Dopamine_Booster/screens/home/student_home/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quiz_repository/quiz.repository.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final QuizRepository _quizRepository = FirebaseQuizRepo(); // Initialize the quiz repository
  List<String> defCategoryNames = [ 'Sports', 'Science', 'History', 'Math', 'Geography', 'English'];
  
  // Fetch categories from the quiz repository
  Future<List<Category>> fetchCategories() async {
    try {
      return await _quizRepository.getAllCategories();
    } catch (e) {
      return [];
    }
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
                childAspectRatio: 0.8, // Adjust tile aspect ratio
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryTile(category: category , defCategoryNames: defCategoryNames);
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

  const CategoryTile({Key? key, required this.category, required this.defCategoryNames}) : super(key: key);

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
              child: _buildCategoryImage(),
            ),
            const SizedBox(height:10),
            Text(
              getLocalizedCategoryName(context, category.categoryName),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              AppLocalizations.of(context)!.quizCount(category.quizCount),
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoryImage() {
  // Check if the category name is in the predefined list of category names
  if (defCategoryNames.contains(category.categoryName)) {
    // If it is, attempt to load the category-specific image
    return Image.asset(
      'assets/categories/${category.categoryName.toLowerCase()}.png',
      height: 150,
      width: 150,
      fit: BoxFit.fill,
      errorBuilder: (context, error, stackTrace) {
        // If the category-specific image fails to load, use the default image
        return _buildDefaultImage();
      },
    );
  } else {
    // If the category name is not in the predefined list, use the default image
    return _buildDefaultImage();
  }
}

  Widget _buildDefaultImage() {
    // Attempt to load the default category image
    return Image.asset(
      'assets/categories/default_category.png',
      height: 150,
      width: 150,
      fit: BoxFit.fill,
      errorBuilder: (context, error, stackTrace) {
        // If the default image fails to load, show a fallback icon
        return Container(
          height: 130,
          width: 110,
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