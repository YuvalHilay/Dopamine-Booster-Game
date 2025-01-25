import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_repository/quiz.repository.dart';

class FirebaseQuizRepo implements QuizRepository {
  final FirebaseFirestore _firestore;

  // Collections references
  late final CollectionReference _quizzesCollection;
  late final CollectionReference _categoriesCollection;
  late final CollectionReference _gradesCollection;

  FirebaseQuizRepo({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _gradesCollection = _firestore.collection('grades');
    _quizzesCollection = _firestore.collection('quizzes');
    _categoriesCollection = _firestore.collection('categories');
  }

  @override
  // Adds a new quiz to Firestore and updates the related category
  Future<void> addQuiz(Quiz quiz) async {
    try {
      // Create a new quiz document with a unique ID
      DocumentReference quizDoc = await _quizzesCollection.add({
        'category': quiz.category,
        'author': quiz.author,
        'description': quiz.description,
        'question': quiz.question,
        'answer1': quiz.answer1,
        'answer2': quiz.answer2,
        'answer3': quiz.answer3,
        'answer4': quiz.answer4,
        'correctAnswer': quiz.correctAnswer,
        'img': quiz.img,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Get the auto-generated quizId
      String quizId = quizDoc.id;

      // Update the quiz document with its ID
      await quizDoc.update({'quizId': quizId});

      // Find the category document by `categoryName`
      QuerySnapshot querySnapshot = await _categoriesCollection
          .where('categoryName', isEqualTo: quiz.category)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Category "${quiz.category}" does not exist.');
      }

      // Get the first matching document (assuming `categoryName` is unique)
      DocumentReference categoryDoc = querySnapshot.docs.first.reference;

      // Update the category document
      await categoryDoc.update({
        'quizCount': FieldValue.increment(1), // Increment quizCount
        'quizzes':
            FieldValue.arrayUnion([quizId]), // Add quizId to quizzes array
      });
    } catch (e) {
      log('Error adding quiz: ${e.toString()}');
      rethrow; // Pass the error up the call stack
    }
  }

  @override
  // Deletes a quiz and removes it from its associated category
  Future<void> deleteQuiz(String quizId) async {
    try {
      // Fetch the quiz document to retrieve its associated category ID
      final quizDoc = await _quizzesCollection.doc(quizId).get();
      if (!quizDoc.exists) {
        throw Exception('Quiz with ID $quizId not found.');
      }

      final data = quizDoc.data() as Map<String, dynamic>;
      final categoryId = data['categoryId'];

      // Fetch the associated category document
      final categoryDoc = await _categoriesCollection.doc(categoryId).get();
      if (!categoryDoc.exists) {
        throw Exception('Category with ID $categoryId not found.');
      }

      // Start a Firestore batch for atomic operations
      final batch = FirebaseFirestore.instance.batch();

      // Remove the quizId from the category's quizzes array
      batch.update(_categoriesCollection.doc(categoryId), {
        'quizIds': FieldValue.arrayRemove([quizId]),
        'quizCount': FieldValue.increment(-1), // Decrease the quiz count
      });

      // Delete the quiz document
      batch.delete(_quizzesCollection.doc(quizId));

      // Commit the batch
      await batch.commit();

      log('Quiz $quizId deleted successfully.');
    } catch (e) {
      log('Error deleting quiz: ${e.toString()}');
      rethrow;
    }
  }

  @override
  // Retrieves a single quiz by its ID
  Future<Quiz> getQuiz(String quizId) async {
    try {
      final quizDoc = await _quizzesCollection.doc(quizId).get();
      if (!quizDoc.exists) {
        throw Exception('Quiz not found');
      }

      final quizData = quizDoc.data() as Map<String, dynamic>;

      // Get category data
      final categoryDoc =
          await _categoriesCollection.doc(quizData['categoryId']).get();

      if (!categoryDoc.exists) {
        throw Exception('Category not found');
      }

      final categoryData = categoryDoc.data() as Map<String, dynamic>;

      // Create and return quiz object
      return Quiz(
        quizId: quizData['quizId'],
        category: categoryData['categoryName'],
        author: quizData['author'],
        description: quizData['description'],
        question: quizData['question'],
        answer1: quizData['answer1'],
        answer2: quizData['answer2'],
        answer3: quizData['answer3'],
        answer4: quizData['answer4'],
        correctAnswer: quizData['correctAnswer'],
      );
    } catch (e) {
      log('Error getting quiz: ${e.toString()}');
      rethrow;
    }
  }

  @override
  // Retrieves all quizzes for a specific category by category ID
  Future<List<Quiz>> getQuizzesByCategory(String categoryId) async {
    try {
      // Fetch the category document
      final categoryDoc = await _categoriesCollection.doc(categoryId).get();

      if (!categoryDoc.exists) {
        throw Exception('Category not found');
      }

      final categoryData = categoryDoc.data() as Map<String, dynamic>;
      final List<dynamic> quizIds = categoryData['quizzes'];

      // Fetch quizzes using the IDs in the array
      final quizDocs = await Future.wait(
        quizIds.map((quizId) => _quizzesCollection.doc(quizId).get()),
      );

      // Map the results to Quiz objects using QuizEntity methods
      final quizzes = quizDocs.map((quizDoc) {
        final data = quizDoc.data() as Map<String, dynamic>;
        final quizEntity = QuizEntity.fromDocument(data);
        return Quiz.fromEntity(quizEntity);
      }).toList();

      return quizzes;
    } catch (e) {
      log('Error getting quizzes by category: $e');
      rethrow;
    }
  }

  @override
  // Retrieves categories filtered by grade and their associated quizzes
  Future<List<Category>> getCategoriesByGrade(String grade) async {
    try {
      // Query categories collection where the grade matches the given parameter
      final querySnapshot =
          await _categoriesCollection.where('grade', isEqualTo: grade).get();

      // Map each category document to a Category object
      return Future.wait(querySnapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;
        final categoryId = doc.id;

        // Safely handle quizCount as an integer (if not present, default to 0)
        final quizCount = data['quizCount'] is int ? data['quizCount'] : 0;

        // Get all quizzes for this category
        final quizzes = await getQuizzesByCategory(categoryId);

        return Category(
          categoryId: categoryId,
          categoryName:
              data['categoryName'] ?? '', // Default to empty string if null
          grade: data['grade'],
          isLocked: data['isLocked'],
          quizCount: quizCount,
          averageScore:
              (data['averageScore'] ?? 0).toDouble(), // Ensure it's a double
          quizzes: quizzes,
        );
      }).toList());
    } catch (e) {
      log('Error getting categories for grade $grade: ${e.toString()}');
      rethrow;
    }
  }

  @override
  //Retrieves all categories available in the repository as defualt dependent on isOpen if true fetches only categories thats unlocked.
  Future<List<Category>> getAllCategories({bool isOpen = false}) async {
    try {
      // Start with the base query
      Query query = _categoriesCollection;

      // If isOpen is true, add a condition to filter by isLocked
      if (isOpen) {
        query = query.where('isLocked', isEqualTo: false);
      }

      final querySnapshot = await query.get();

      // Map each category document to a Category object
      return Future.wait(querySnapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;
        final categoryId = doc.id;

        // Safely handle quizCount as an integer (if not present, default to 0)
        final quizCount = data['quizCount'] is int ? data['quizCount'] : 0;

        // Get all quizzes for this category
        final quizzes = await getQuizzesByCategory(categoryId);

        return Category(
          categoryId: categoryId,
          categoryName:data['categoryName'] ?? '', // Default to empty string if null
          grade: data['grade'],
          isLocked: data['isLocked'] ?? false, // Default to false if null
          quizCount: quizCount,
          averageScore: (data['averageScore'] ?? 0).toDouble(), // Ensure it's a double
          quizzes: quizzes,
        );
      }).toList());
    } catch (e) {
      log('Error getting categories: ${e.toString()}');
      rethrow;
    }
  }

  @override
  // Adds a new category to Firestore
  Future<void> addCategory(Category category) async {
    try {
      // Use Firestore to generate a unique ID
      final newDocRef =
          _categoriesCollection.doc(); // Generates a new unique ID
      final generatedId = newDocRef.id; // Retrieve the generated ID

      await newDocRef.set({
        'categoryId': generatedId, // Store the generated ID
        'categoryName': category.categoryName,
        'grade': category.grade,
        'isLocked': category.isLocked, // Default to false if null
        'quizCount': category.quizCount, // Default to 0 if null
        'quizzes': [], // Initialize empty array of quiz IDs
        'createdAt': FieldValue.serverTimestamp(),
      });

      log('Category added with ID: $generatedId');
    } catch (e) {
      log('Error adding category: ${e.toString()}');
      rethrow;
    }
  }

  @override
  // This method fetches the count of categories from the Firestore collection.
  Future<String> getCategoryCount() async {
    try {
      final snapshot = await _categoriesCollection
          .get(); // Retrieve data from categories collection
      return snapshot.size
          .toString(); // This gives the number of documents in the collection
    } catch (e) {
      return '0'; // Return 0 if there's an error
    }
  }

  @override
  // This method fetches the count of quizzes from the Firestore collection.
  Future<String> getQuizCount() async {
    try {
      final snapshot = await _quizzesCollection
          .get(); // Retrieve data from quizzes collection
      return snapshot.size
          .toString(); // This gives the number of documents in the collection
    } catch (e) {
      return '0'; // Return 0 if there's an error
    }
  }

  @override
  // Retrieves a leaderboard of top users based on their total scores.
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      // Fetch all grades
      final gradesSnapshot = await _gradesCollection.get();
      final userScores = <String, double>{};
      final userNames = <String, String>{};

      // Aggregate scores by userId and fetch user names
      for (final doc in gradesSnapshot.docs) {
        final userId = doc['userId'];
        final userName =
            doc['userName']; // Assuming userName is present in the document
        final scoreStr = doc['score'] as String;
        final scoreParts = scoreStr.split('/');
        final score = double.tryParse(scoreParts[0]) ?? 0.0;

        userScores[userId] = (userScores[userId] ?? 0) + score;
        if (userName.isNotEmpty) {
          userNames[userId] = userName;
        }
      }

      // Sort and get top 3 distinct users
      final leaderboard = userScores.entries
          .map((e) => {
                'userId': e.key,
                'userName': userNames[e.key] ??
                    'Unknown', // Get the userName if available
                'totalScore': e.value,
              })
          .toList()
        ..sort((a, b) =>
            (b['totalScore'] as double).compareTo(a['totalScore'] as double));

      // Take top 3 users or fill with empty entries if less than 3
      return List.generate(3, (index) {
        if (index < leaderboard.length) {
          return leaderboard[index];
        }
        return {
          'userId': '',
          'userName': ' - ',
          'totalScore': 0.0
        }; // Empty placeholder
      });
    } catch (e) {
      print('Error fetching leaderboard: $e');
      return [
        {'userId': '', 'userName': ' - ', 'totalScore': 0.0},
        {'userId': '', 'userName': ' - ', 'totalScore': 0.0},
        {'userId': '', 'userName': ' - ', 'totalScore': 0.0},
      ];
    }
  }

  @override
  // Saves or updates a user's grade for a specific category in the database, with isPlayed dependacy.
  Future<void> saveGrade(
      String categoryId,
      String categoryName,
      String userName,
      bool isComplete,
      bool isPlayed,
      String userId,
      String normalizedScore) async {
    try {
      // Query to check if a grade already exists for the user in the same category
      final querySnapshot = await _gradesCollection
          .where('userId', isEqualTo: userId)
          .where('categoryId', isEqualTo: categoryId)
          .get();

      // If a grade exists, check if 'isPlayed' is the same
      if (querySnapshot.docs.isNotEmpty) {
        final existingDocId = querySnapshot.docs.first.id;
        final existingGrade = querySnapshot.docs.first.data()
            as Map<String, dynamic>; // Ensure data is cast to Map

        // Check if 'isPlayed' is the same as the parameter
        if (existingGrade['isPlayed'] == isPlayed) {
          // Update the existing document if 'isPlayed' matches
          await _gradesCollection.doc(existingDocId).update({
            'categoryName': categoryName,
            'isComplete': isComplete,
            'isPlayed': isPlayed,
            'score': normalizedScore, // Update normalized score
          });
        } else {
          // If 'isPlayed' is different, create a new document with 'isPlayed' set to true
          final gradeData = {
            'categoryId': categoryId,
            'categoryName': categoryName,
            'isComplete': isComplete,
            'isPlayed': isPlayed, // Set isPlayed to true for the new record
            'userId': userId,
            'score': normalizedScore, // Save normalized score
            'userName': userName,
          };

          await _gradesCollection
              .add(gradeData); // Add new document with isPlayed = true
        }
      } else {
        // If no grade exists, add a new document
        final gradeData = {
          'categoryId': categoryId,
          'categoryName': categoryName,
          'isComplete': isComplete,
          'isPlayed': isPlayed, // Set the appropriate isPlayed value
          'userId': userId,
          'score': normalizedScore, // Save normalized score
          'userName': userName,
        };

        await _gradesCollection.add(gradeData); // Add new document
      }
    } catch (e) {
      print("Error saving grade: $e");
    }
  }

  @override
  // Fetches a list of grades for a specific user based on their user ID.
  Future<List<Grade>> fetchUserGrades(String userId) async {
    try {
      final querySnapshot =
          await _gradesCollection.where('userId', isEqualTo: userId).get();

      // Map Firestore documents to Grade objects
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Convert score to a string format
        var score = data['score'];
        String scoreString = '';
        if (score is double) {
          scoreString = score.toStringAsFixed(
              2); // Convert the double to a string with 2 decimal places
        } else if (score is String) {
          scoreString = score; // If already a string, keep it as it is
        }

        return Grade(
          categoryId: data['categoryId'] ?? '',
          categoryName: data['categoryName'] ?? '',
          isComplete: data['isComplete'] ?? false,
          isPlayed: data['isPlayed'] ?? false,
          userId: data['userId'] ?? '',
          score: scoreString, // Use the properly formatted score
          userName: data['userName'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error fetching grades: $e');
      return [];
    }
  }

  @override
  /// Fetches all grades from the Firestore database, groups them by user, and structures the data for UI consumption.
  /// and organizes it into a list of maps. Each map represents a student and contains:
  /// - `name`: The student's name.
  /// - `grades`: A list of grade objects for the student, where each grade includes:
  ///   - `categoryName`: The name of the category (e.g., subject or quiz type).
  ///   - `score`: The score for the category (parsed from "5/5" format).
  ///   - `isPlayed`: A boolean indicating whether the grade is marked as played.
  /// Returns: A list of maps where each map contains a student's name and their grades.
  Future<List<Map<String, dynamic>>> fetchAllGrades() async {
    try {
      // Access the Firestore collection for grades
      final gradesSnapshot = await _gradesCollection.get();

      // Map Firestore documents to a list of Grade objects
      final allGrades = gradesSnapshot.docs.map((doc) {
        return Grade(
          categoryId: doc['categoryId'] as String,
          categoryName: doc['categoryName'] as String,
          isComplete: doc['isComplete'] as bool,
          isPlayed: doc['isPlayed'] as bool,
          userId: doc['userId'] as String,
          score: doc['score'] as String,
          userName: doc['userName'] as String,
        );
      }).toList();

      // Group grades by userName
      final Map<String, List<Map<String, dynamic>>> groupedGrades = {};

      for (var grade in allGrades) {
        if (!groupedGrades.containsKey(grade.userName)) {
          groupedGrades[grade.userName] = [];
        }

        // Extract the score and convert it from "5/5" format to an integer
        final scoreParts = grade.score.split('/');
        final score =
            scoreParts.isNotEmpty ? int.tryParse(scoreParts[0]) ?? 0 : 0;

        // Add the grade data in the required format
        groupedGrades[grade.userName]?.add({
          'categoryName': grade.categoryName,
          'score': score,
          'isPlayed': grade.isPlayed,
        });
      }

      // Convert grouped data into the map format
      final studentProgress = groupedGrades.entries.map((entry) {
        return {
          'name': entry.key,
          'grades': entry.value,
        };
      }).toList();

      // Print the structured studentProgress list
      studentProgress.forEach((student) {
        print('name: ${student['name']}, grades: ${student['grades']}');
      });

      return studentProgress;
    } catch (e) {
      // Handle errors here (e.g., print or log the error)
      print('Error fetching all grades: $e');
      return [];
    }
  }


  // This method is used to toggle the lock state of a category in Firestore collection.
  Future<void> updateCategoryLockState(String categoryId, bool isLocked) async {
  try {
    // Reference the category document in the database
    final categoryDoc = _categoriesCollection.doc(categoryId);

    // Update the isLocked field in the database
    await categoryDoc.update({'isLocked': isLocked});
  } catch (e) {
    log('Error updating lock state for category $categoryId: ${e.toString()}');
  }
}

  @override
  // Deletes a category, all associated quizzes, and related grades
  Future<void> deleteCategory(String categoryId) async {
    try {
      // Fetch the category document
      final categoryDoc = await _categoriesCollection.doc(categoryId).get();

      if (!categoryDoc.exists) {
        throw Exception('Category with ID $categoryId not found.');
      }

      // Get the category data
      final categoryData = categoryDoc.data() as Map<String, dynamic>;
      final List<dynamic> quizIds = categoryData['quizzes'] ?? [];

      // Start a Firestore batch for atomic operations
      final batch = FirebaseFirestore.instance.batch();

      // Delete all quizzes associated with the category
      for (final quizId in quizIds) {
        batch.delete(_quizzesCollection.doc(quizId));
      }

      // Fetch and delete all grades associated with the category
      final gradesQuery = await _gradesCollection.where('categoryId', isEqualTo: categoryId).get();
      for (final gradeDoc in gradesQuery.docs) {
        batch.delete(gradeDoc.reference);
      }

      // Delete the category document
      batch.delete(_categoriesCollection.doc(categoryId));

      // Commit the batch
      await batch.commit();

      log('Category $categoryId, associated quizzes, and grades deleted successfully.');
    } catch (e) {
      log('Error deleting category: ${e.toString()}');
      rethrow;
    }
  }


}
