import '../models/models.dart';

class CatagoryEntity {
  String catagoryId;
  String catagoryName;
  List<Quiz> quizzes;

// Constructor to initialize the quiz object with required fields.
  CatagoryEntity({
    required this.catagoryId,
    required this.catagoryName,
    required this.quizzes,
  });


}