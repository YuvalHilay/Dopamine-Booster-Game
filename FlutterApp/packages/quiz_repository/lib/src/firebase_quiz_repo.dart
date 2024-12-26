import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:quiz_repository/quiz.repository.dart';

class FirebaseQuizRepo implements QuizRepository {
  final FirebaseFirestore _firestore;
  
  // Collections references
  late final CollectionReference _quizzesCollection;
  late final CollectionReference _categoriesCollection;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  FirebaseQuizRepo({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _quizzesCollection = _firestore.collection('quizzes');
    _categoriesCollection = _firestore.collection('categories');
  }


  Future<String> _uploadImageToStorage(String filePath, String fileName) async {
    try {
      final file = File(filePath);
      final storageRef = _firebaseStorage.ref().child('quiz_images/$fileName');
      final uploadTask = await storageRef.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      log('Error uploading image: ${e.toString()}');
      throw Exception('Failed to upload image to Firebase Storage');
    }
  }

  @override
  // Adds a new quiz to Firestore and updates the related category
  Future<void> addQuiz(Quiz quiz) async {
    try {
      String? imageUrl;
/*
      // Check if the quiz includes an image and upload it
      if (quiz.img != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${quiz.img!.split('/').last}';
        imageUrl = await _uploadImageToStorage(quiz.img!, fileName);
      }*/
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
  // Updates an existing category's information (future use)
  Future<void> updateCategory(Category category) async {
    try {
      await _categoriesCollection.doc(category.categoryId).update({
        'categoryName': category.categoryName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error updating category: ${e.toString()}');
      rethrow;
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

