
import 'models.dart';

class Category {
  String categoryId;
  String categoryName;
  int quizCount;
  List<Quiz> quizzes;
  final double averageScore; // Average score for the category
  
  // Constructor to initialize the quiz object with required fields.
  Category({
    required this.categoryId,
    required this.categoryName,
    required this.quizCount,
    required this.averageScore,
    List<Quiz>? quizzes, // Allow nullable list and default to empty
  }) : quizzes = quizzes ?? []; // Default to an empty List<Quiz>

// Convert to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'quizCount': quizCount,
      'quizzes': quizzes.map((quiz) => quiz.toEntity()).toList(),
      'averageScore': averageScore,
    };
  }

  // Create an instance from Firestore data
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      categoryId: map['categoryId'],
      categoryName: map['categoryName'],
      quizCount: map['quizCount'],
      quizzes: (map['quizzes'] as List).map((quiz) => Quiz.fromEntity(quiz)).toList(),
      averageScore: map['averageScore'].toDouble(),
    );
  }
}