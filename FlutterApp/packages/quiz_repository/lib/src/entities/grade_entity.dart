
class GradeEntity {
  String categoryId;
  String categoryName;
  bool isComplete;
  bool isPlayed;
  String userId;
  String score;
  String userName;

  // Constructor to initialize the grade object with required fields.
  GradeEntity({
    required this.categoryId,
    required this.categoryName,
    required this.isComplete,
    required this.isPlayed,
    required this.userId,
    required this.score,
    required this.userName,
  }); 

  // Method to update the quiz count dynamically based on the quizzes list
  void updateGrade() {
    
  }


}