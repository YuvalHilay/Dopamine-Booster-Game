
import 'models.dart';

class Category {
  String categoryId;
  String categoryName;
  int quizCount;
  List<Quiz> quizzes;
  
  // Constructor to initialize the quiz object with required fields.
  Category({
    required this.categoryId,
    required this.categoryName,
    required this.quizCount,
    List<Quiz>? quizzes, // Allow nullable list and default to empty
  }) : quizzes = quizzes ?? []; // Default to an empty List<Quiz>

}