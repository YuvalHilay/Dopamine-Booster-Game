import 'models/models.dart';

/// Abstract class defining the contract for a Quiz repository.
/// This repository serves as the interface for managing quiz and category data,
/// ensuring a consistent structure for data operations regardless of the data source.
abstract class QuizRepository {
  /// Adds a new quiz to the repository.
  /// [quiz] - The quiz object containing all required details to be added.
  Future<void> addQuiz(Quiz quiz);

  /// Deletes a quiz from the repository using its unique identifier.
  /// [quizId] - The unique identifier of the quiz to be deleted.
  Future<void> deleteQuiz(String quizId);

  /// Retrieves a single quiz from the repository based on its unique identifier.
  /// [quizId] - The unique identifier of the quiz to be fetched.
  /// Returns a [Quiz] object if found, otherwise throws an exception.
  Future<Quiz> getQuiz(String quizId);

  /// Retrieves a list of quizzes filtered by a specific category.
  /// [categoryId] - The unique identifier of the category whose quizzes are to be retrieved.
  /// Returns a list of [Quiz] objects that belong to the specified category.
  Future<List<Quiz>> getQuizzesByCategory(String categoryId);

  /// Retrieves all categories available in the repository.
  /// Returns a list of [Category] objects representing all available categories.
  Future<List<Category>> getAllCategories();

  /// Adds a new category to the repository.
  /// [category] - The category object containing all required details to be added.
  Future<void> addCategory(Category category);

  /// This method fetches the count of categories from the Firestore collection.
  Future<String> getCategoryCount();

  /// This method fetches the count of quizzes from the Firestore collection.
  Future<String> getQuizCount();

  /// Deletes a category from the repository using its unique identifier.
  /// [categoryId] - The unique identifier of the category to be deleted.
  Future<void> deleteCategory(String categoryId);
}
