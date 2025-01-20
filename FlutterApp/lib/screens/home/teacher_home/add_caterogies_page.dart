import 'package:Dopamine_Booster/components/categories_bar.dart';
import 'package:Dopamine_Booster/components/popup_msg.dart';
import 'package:Dopamine_Booster/utils/localizedNames.dart';
import 'package:flutter/material.dart';
import 'package:quiz_repository/quiz.repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddCategoriesScreen extends StatefulWidget {
  const AddCategoriesScreen({Key? key}) : super(key: key);

  @override
  _AddCategoriesScreenState createState() => _AddCategoriesScreenState();
}

class _AddCategoriesScreenState extends State<AddCategoriesScreen> {
  final QuizRepository quizRepository = FirebaseQuizRepo();
  final TextEditingController _categoryNameController = TextEditingController();
  List<Category> categories = [];
  String _searchQuery = '';
  String _selectedGrade = 'Third Grade'; // Default selected grade
  
  final List<Map<String, dynamic>> grades = [
    {'name': 'Third Grade', 'icon': Icons.looks_3, 'color': Colors.purple},
    {'name': 'Fourth Grade', 'icon': Icons.looks_4, 'color': Colors.green},
    {'name': 'Fifth Grade', 'icon': Icons.looks_5, 'color': Colors.blue},
    {'name': 'Sixth Grade', 'icon': Icons.looks_6, 'color': Colors.red},
    {'name': 'Seventh Grade', 'icon': Icons.grade, 'color': Colors.orange},
  ];

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
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.addNewCat),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _categoryNameController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.enterCat,
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButton<String>(
                    value: _selectedGrade,
                    isExpanded: true,
                    items: grades.map((grade) {
                      return DropdownMenuItem<String>(
                        value: grade['name'],
                        child: Row(
                          children: [
                            Icon(grade['icon'], color: grade['color']),
                            SizedBox(width: 8),
                            Text(grade['name']),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGrade = newValue!;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(AppLocalizations.of(context)!.cancel),
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                ),
                TextButton(
                  child: Text(AppLocalizations.of(context)!.add),
                  onPressed: () => Navigator.of(context).pop({
                    'name': _categoryNameController.text,
                    'grade': _selectedGrade,
                  }),
                  style: TextButton.styleFrom(foregroundColor: Colors.green),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result['name']!.isNotEmpty) {
      try {
        final newCategory = Category(
          categoryId: '',
          categoryName: result['name']!,
          grade: result['grade']!,
          isLocked: false,
          quizCount: 0,
          averageScore: 0,
          quizzes: [],
        );
        await quizRepository.addCategory(newCategory);
        _loadCategories();
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
          content: Text(AppLocalizations.of(context)!
              .deleteCateMsg(category.categoryName)),
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
        _loadCategories();
      } catch (e) {
        displayMessageToUser('Failed to delete category!', context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = categories
        .where((category) => category.categoryName
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
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
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                child: Text(
                  filteredCategories[index].categoryName[0].toUpperCase(),
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              title: Text(getLocalizedCategoryName(context, filteredCategories[index].categoryName)),
              subtitle: Text(
                  '${filteredCategories[index].quizCount} quizzes - ${filteredCategories[index].grade}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => _deleteCategory(filteredCategories[index]),
                  ),
                  // Lock/Unlock button
                  IconButton(
  icon: Icon(
    filteredCategories[index].isLocked ? Icons.lock : Icons.lock_open,
    color: filteredCategories[index].isLocked ? Colors.green : Colors.grey,
    size: 20,
  ),
  onPressed: () async {
    // Toggle the lock state in the UI
    setState(() {
      filteredCategories[index].isLocked = !filteredCategories[index].isLocked;
    });

    // Update the database
    await quizRepository.updateCategoryLockState(
      filteredCategories[index].categoryId,
      filteredCategories[index].isLocked,
    );
  },
),

                ],
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
