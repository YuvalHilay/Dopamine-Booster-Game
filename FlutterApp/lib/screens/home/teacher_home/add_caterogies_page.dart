import 'package:Dopamine_Booster/components/categories_bar.dart';
import 'package:Dopamine_Booster/components/popup_msg.dart';
import 'package:flutter/material.dart';
import 'package:quiz_repository/quiz.repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddCategoriesScreen extends StatefulWidget {
  const AddCategoriesScreen({Key? key}) : super(key: key);

  @override
  _AddCategoriesScreenState createState() => _AddCategoriesScreenState();
}

class _AddCategoriesScreenState extends State<AddCategoriesScreen> {
  final QuizRepository quizRepository = FirebaseQuizRepo(); // Initialize the quiz repository
  final TextEditingController _categoryNameController = TextEditingController();
  List<Category> categories = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final loadedCategories = await quizRepository.getAllCategories();
      if (mounted) {
        setState(() {
          categories = loadedCategories;
        });
      }
    } catch (e) {
      if (mounted) {
        displayMessageToUser('Failed to load categories!', context);
      }
    }
  }

  Future<void> _addCategory() async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addNewCat),
          content: TextField(
            controller: _categoryNameController,
            decoration: InputDecoration(hintText: AppLocalizations.of(context)!.enterCat),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.add),
              onPressed: () => Navigator.of(context).pop(_categoryNameController.text),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
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
        displayMessageToUser('Failed to add category!', context);
      }
    }
    _categoryNameController.clear();
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteCategory),
          content: Text(AppLocalizations.of(context)!.deleteCateMsg(category.categoryName)),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.delete),
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
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
        displayMessageToUser('Failed to delete category!', context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = categories
        .where((category) => category.categoryName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: CategoriesBar(
        onSearchChanged: (newQuery) {
          setState(() {
            _searchQuery = newQuery;
          });
        },
      ),
      body: ListView.builder(
        itemCount: filteredCategories.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  filteredCategories[index].categoryName[0].toUpperCase(),
                  style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                ),
              ),
              title: Text(filteredCategories[index].categoryName),
              subtitle: Text('${filteredCategories[index].quizCount} quizzes'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () => _deleteCategory(filteredCategories[index]),
              ),
              onTap: () {
                // TODO: Future Navigate to category detail or quiz list
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        child: const Icon(Icons.add),
        tooltip: AppLocalizations.of(context)!.addNewCat,
      ),
    );
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }
}
