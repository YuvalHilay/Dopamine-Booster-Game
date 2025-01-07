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
        'quizzes': FieldValue.arrayUnion([quizId]), // Add quizId to quizzes array
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
    // Get the quiz to find its category
    final quizDoc = await _quizzesCollection.doc(quizId).get();
    if (quizDoc.exists) {
      final data = quizDoc.data() as Map<String, dynamic>;
      final categoryId = data['categoryId'];

      // Check if the category document exists
      final categoryDoc = await _categoriesCollection.doc(categoryId).get();
      if (categoryDoc.exists) {
        // Remove quiz from category's quizzes array
        await _categoriesCollection
            .doc(categoryId)
            .update({
          'quizIds': FieldValue.arrayRemove([quizId])
        });
      } else {
        log('Category $categoryId not found. Skipping array update.');
      }

      // Delete the quiz document
      await _quizzesCollection.doc(quizId).delete();
    }
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
      final categoryDoc = await _categoriesCollection
          .doc(quizData['categoryId'])
          .get();
      
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
  // Retrieves all categories and their associated quizzes
  Future<List<Category>> getAllCategories() async {
  try {
    final querySnapshot = await _categoriesCollection.get();
    
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
        categoryName: data['categoryName'] ?? '', // Default to empty string if null
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
    final newDocRef = _categoriesCollection.doc(); // Generates a new unique ID
    final generatedId = newDocRef.id; // Retrieve the generated ID

    await newDocRef.set({
      'categoryId': generatedId, // Store the generated ID
      'categoryName': category.categoryName,
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
    final snapshot = await _categoriesCollection.get(); // Retrieve data from categories collection
    return snapshot.size.toString(); // This gives the number of documents in the collection
  } catch (e) {
    return '0'; // Return 0 if there's an error
  }
}

  @override
  // This method fetches the count of quizzes from the Firestore collection.
  Future<String> getQuizCount() async {
  try {
    final snapshot = await _quizzesCollection.get(); // Retrieve data from quizzes collection
    return snapshot.size.toString(); // This gives the number of documents in the collection
  } catch (e) {
    return '0'; // Return 0 if there's an error
  }
}

  @override
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
  try {
    // Fetch all grades
    final gradesSnapshot = await _gradesCollection.get();
    final userScores = <String, double>{};
    final userNames = <String, String>{};

    // Aggregate scores by userId and fetch user names
    for (final doc in gradesSnapshot.docs) {
      final userId = doc['userId'];
      final userName = doc['userName']; // Assuming userName is present in the document
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
              'userName': userNames[e.key] ?? 'Unknown', // Get the userName if available
              'totalScore': e.value,
            })
        .toList()
      ..sort((a, b) => (b['totalScore'] as double).compareTo(a['totalScore'] as double));

    // Take top 3 users or fill with empty entries if less than 3
    return List.generate(3, (index) {
      if (index < leaderboard.length) {
        return leaderboard[index];
      }
      return {'userId': '', 'userName': ' - ', 'totalScore': 0.0}; // Empty placeholder
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
  Future<void> saveGrade(String categoryId, String categoryName, String userName, bool isComplete, String userId, String normalizedScore) async {
  try {
    // Query to check if a grade already exists for the user in the same category
    final querySnapshot = await _gradesCollection
        .where('userId', isEqualTo: userId)
        .where('categoryId', isEqualTo: categoryId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // If a grade exists, update the existing document
      final existingDocId = querySnapshot.docs.first.id;
      await _gradesCollection.doc(existingDocId).update({
        'categoryName': categoryName,
        'isComplete': isComplete,
        'score': normalizedScore, // Update normalized score
      });
    } else {
      // If no grade exists, add a new document
      final gradeData = {
        'categoryId': categoryId,
        'categoryName': categoryName,
        'isComplete': isComplete,
        'userId': userId,
        'score': normalizedScore, // Save normalized score
        'userName': userName,
      };

      await _gradesCollection.add(gradeData);
    }
  } catch (e) {
    print("Error saving grade: $e");
  }
}
  
  @override
  Future<List<Grade>> fetchUserGrades(String userId) async {
    try {
      final querySnapshot = await _gradesCollection.where('userId', isEqualTo: userId).get();

      // Map Firestore documents to Grade objects
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Convert score to a string format
        var score = data['score'];
        String scoreString = '';
        if (score is double) {
          scoreString = score.toStringAsFixed(2); // Convert the double to a string with 2 decimal places
        } else if (score is String) {
          scoreString = score; // If already a string, keep it as it is
        }

        return Grade(
          categoryId: data['categoryId'] ?? '',
          categoryName: data['categoryName'] ?? '',
          isComplete: data['isComplete'] ?? false,
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
  // Deletes a category and all associated quizzes
  Future<void> deleteCategory(String categoryId) async {
  try {
    // First, delete all quizzes in this category
    final quizzes = await getQuizzesByCategory(categoryId);
    for (final quiz in quizzes) {
      await deleteQuiz(quiz.quizId);
    }

    // Then delete the category
    final categoryDoc = await _categoriesCollection.doc(categoryId).get();
    if (categoryDoc.exists) {
      await _categoriesCollection.doc(categoryId).delete();
    } else {
      log('Category $categoryId not found. Skipping deletion.');
    }
  } catch (e) {
    log('Error deleting category: ${e.toString()}');
    rethrow;
  }
}
}

