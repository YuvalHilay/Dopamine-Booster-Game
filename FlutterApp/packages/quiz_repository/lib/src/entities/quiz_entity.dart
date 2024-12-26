
class QuizEntity {
  final String quizId;
  final String category;
  final String author;
  final String description;
  final String question;
  final String answer1;
  final String answer2;
  final String answer3;
  final String answer4;
  final String correctAnswer;
  final String? img;

  // Constructor for initializing the entity.
  QuizEntity({
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
    this.img,
  });

  // Converts the current object into a map representation for serializing the entity to a database.
  Map<String, Object?> toDocument() {
    return {
      'quizId': quizId,
      'catagory': category,
      'author': author,
      'description': description,
      'question': question,
      'answer1': answer1,
      'answer2': answer2,
      'answer3': answer3,
      'answer4': answer4,
      'correctAnswer': correctAnswer,
      'img': img,
    };
  }
  // Factory method for creating a `QuizEntity` object from a map for deserializing data retrieved from a database.
  static QuizEntity fromDocument(Map<String, dynamic> doc) {
    return QuizEntity(
      quizId: doc['quizId'], 
      category: doc['category'],
      author: doc['author'],
      description: doc['description'],
      question: doc['question'],
      answer1: doc['answer1'],
      answer2: doc['answer2'],
      answer3: doc['answer3'],
      answer4: doc['answer4'],
      correctAnswer: doc['correctAnswer'],
      img: doc['img'] as String?,
    );
  }
}
