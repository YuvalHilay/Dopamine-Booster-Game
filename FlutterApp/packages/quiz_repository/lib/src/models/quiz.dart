import '../entities/entities.dart';
import 'models.dart';

class Quiz {
  String quizId;
  String category;
  String author;
  String description;
  String question;
  String answer1;
  String answer2;
  String answer3;
  String answer4;
  String correctAnswer;


  // Constructor to initialize the quiz object with required fields.
  Quiz({
    required this.quizId,
    required this.category,
    required this.author,
    required this.description,
    required this.question,
    required this.answer1,
    required this.answer2,
    required this.answer3,
    required this.answer4,
    required this.correctAnswer,
  });

  // Converts this [Quiz] instance into a [QuizEntity] for persistence, when saving user data to a database.
  QuizEntity toEntity() {
    return QuizEntity(
      quizId: quizId,
      category: category,
      author: author,
      description: description,
      question: question,
      answer1: answer1,
      answer2: answer2,
      answer3: answer3,
      answer4: answer4,
      correctAnswer: correctAnswer,
    );
  }
  // Creates a [Quiz] object from a [QuizEntity], when retrieving user data from a database.
  static Quiz fromEntity(QuizEntity entity) {
    return Quiz(
      quizId: entity.quizId,
      category: entity.category,
      author: entity.author,
      description: entity.description,
      question: entity.question,
      answer1: entity.answer1,
      answer2: entity.answer2,
      answer3: entity.answer3,
      answer4: entity.answer4,
      correctAnswer: entity.correctAnswer);
  }

  @override
  // Provides a string representation of the [Quiz] instance.
  String toString() {
    return 'Quiz: $quizId, $category, $author, $description, $question, $answer1, $answer2, $answer3, $answer4, $correctAnswer';
  }

}