
import 'models.dart';

class Grade {
  String categoryId;
  String categoryName;
  bool isComplete;
  String userId;
  String score;
  String userName;
  
  // Constructor to initialize the grade object with required fields.
  Grade({
    required this.categoryId,
    required this.categoryName,
    required this.isComplete,
    required this.userId,
    required this.score,
    required this.userName,
  }); 

  

}