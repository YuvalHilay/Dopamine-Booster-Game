
import 'models.dart';

class Category {
  String categoryId;
  String categoryName;
  List<Quiz> quizzes;
  
// Constructor to initialize the quiz object with required fields.
  Category({
    required this.categoryId,
    required this.categoryName,
    required this.quizzes,
  });

}