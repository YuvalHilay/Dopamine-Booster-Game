import '../models/models.dart';

class CatagoryEntity {
  String catagoryId;
  String catagoryName;
  String quizCount;
  List<Quiz> quizzes;

// Constructor to initialize the quiz object with required fields.
  CatagoryEntity({
    required this.catagoryId,
    required this.catagoryName,
    required this.quizCount,
    required this.quizzes,
  });


}