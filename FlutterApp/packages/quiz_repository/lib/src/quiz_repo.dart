
import 'models/models.dart';

abstract class QuizRepository {
  Future<void> addQuiz(Quiz quiz);
  Future<void> updateQuiz(Quiz quiz);
  Future<void> deleteQuiz(String quizId);
  Future<Quiz> getQuiz(String quizId);
  Future<List<Quiz>> getQuizzesByCategory(String categoryId);
  Future<List<Category>> getAllCategories();
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String categoryId);
}

