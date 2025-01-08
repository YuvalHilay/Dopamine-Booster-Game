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

  /// Saves or updates a user's grade for a specific category in the database.
  /// @return A Future that completes when the grade is successfully saved or updated.
  Future<void> saveGrade(String categoryId, String categoryName, String userName, bool isComplete, String userId, String normalizedScore);
  
  /// Retrieves a leaderboard containing the top users based on their performance.
  /// @return A Future that resolves to a list of maps, each containing user-related details such as name and total score.
  Future<List<Map<String, dynamic>>> getLeaderboard();
  
  /// Fetches the grades of a specific user from the database.
  /// @param userId The unique identifier of the user whose grades are to be fetched.
  /// @return A Future that resolves to a list of Grade objects containing details such as category, score, and completion status.
  Future<List<Grade>> fetchUserGrades(String userId);

  /// Deletes a category from the repository using its unique identifier.
  /// [categoryId] - The unique identifier of the category to be deleted.
  Future<void> deleteCategory(String categoryId);
}
