import 'package:flutter/material.dart';
import 'package:quiz_repository/quiz.repository.dart';


class AddCategoriesScreen extends StatefulWidget {

  const AddCategoriesScreen({Key? key}) : super(key: key);

  @override
  _AddCategoriesScreenState createState() => _AddCategoriesScreenState();
}

class _AddCategoriesScreenState extends State<AddCategoriesScreen> {
  final QuizRepository quizRepository = new FirebaseQuizRepo(); // Initialize the quiz repository
  List<Category> categories = [];
  final TextEditingController _categoryNameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final loadedCategories = await quizRepository.getAllCategories();
      setState(() {
        categories = loadedCategories;
      });
    } catch (e) {
      // Handle error (e.g., show a snackbar with the error message)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
    }
  }

  Future<void> _addCategory() async {
    final result = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add New Category'),
        content: TextField(
          controller: _categoryNameController,
          decoration: const InputDecoration(hintText: "Enter category name"),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black, // Set the desired color for the Cancel button
            ),
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () => Navigator.of(context).pop(_categoryNameController.text),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green, // Set the desired color for the Add button
            ),
          ),
        ],
      );
    },
  );

    if (result != null && result.isNotEmpty) {
      try {
        final newCategory = Category(
          categoryId: '',
          categoryName: result,
          quizCount: 0,
          quizzes: [],
        );
        await quizRepository.addCategory(newCategory);
        _loadCategories(); // Reload categories to reflect the change
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add category: $e')),
        );
      }
    }
    _categoryNameController.clear();
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Category'),
      content: Text('Are you sure you want to delete "${category.categoryName}"?'),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: Colors.black, // Set the desired color for the Cancel button
          ),
        ),
        TextButton(
          child: const Text('Delete'),
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red, // Set the desired color for the Delete button
          ),
        ),
      ],
    );
  },
);

    if (confirmed == true) {
      try {
        await quizRepository.deleteCategory(category.categoryId);
        _loadCategories(); // Reload categories to reflect the change
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete category: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  categories[index].categoryName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(categories[index].categoryName),
              subtitle: Text('${categories[index].quizCount} quizzes'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => _deleteCategory(categories[index]),
                  ),
                  const Icon(Icons.arrow_forward_ios),
                ],
              ),
              onTap: () {
                // TODO: Navigate to category detail or quiz list
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
         backgroundColor: Theme.of(context).colorScheme.inversePrimary, // Replace with your custom color
        child: const Icon(Icons.add),
        tooltip: 'Add New Category',
      ),
    );
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }
}

