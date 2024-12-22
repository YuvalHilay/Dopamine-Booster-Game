import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/models.dart';
import 'quiz_repo.dart';

class FirebaseQuizRepo implements QuizRepository {
  final FirebaseFirestore _firestore;
  
  // Collections references
  late final CollectionReference _quizzesCollection;
  late final CollectionReference _categoriesCollection;

  FirebaseQuizRepo({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _quizzesCollection = _firestore.collection('quizzes');
    _categoriesCollection = _firestore.collection('categories');
  }

  @override
  Future<void> addQuiz(Quiz quiz) async {
    try {
      // Create quiz document with custom ID
      await _quizzesCollection.doc(quiz.quizId).set({
        'quizId': quiz.quizId,
        'category': quiz.category,
        'author': quiz.author,
        'description': quiz.description,
        'question': quiz.question,
        'answer1': quiz.answer1,
        'answer2': quiz.answer2,
        'answer3': quiz.answer3,
        'answer4': quiz.answer4,
        'correctAnswer': quiz.correctAnswer,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update category's quizzes array
      await _categoriesCollection
          .doc(quiz.category)
          .update({
        'quizIds': FieldValue.arrayUnion([quiz.quizId])
      });
    } catch (e) {
      log('Error adding quiz: ${e.toString()}');
      rethrow;
    }
  }


  @override
  Future<void> deleteQuiz(String quizId) async {
    try {
      // Get the quiz to find its category
      final quizDoc = await _quizzesCollection.doc(quizId).get();
      if (quizDoc.exists) {
        final data = quizDoc.data() as Map<String, dynamic>;
        final categoryId = data['categoryId'];

        // Remove quiz from category's quizzes array
        await _categoriesCollection
            .doc(categoryId)
            .update({
          'quizIds': FieldValue.arrayRemove([quizId])
        });

        // Delete the quiz document
        await _quizzesCollection.doc(quizId).delete();
      }
    } catch (e) {
      log('Error deleting quiz: ${e.toString()}');
      rethrow;
    }
  }

  @override
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
      
      // Create category object
      final category = Category(
        categoryId: categoryData['categoryId'],
        categoryName: categoryData['categoryName'],
        quizCount: categoryData['quizCount'],
        quizzes: [], // We don't need to load all quizzes here
      );

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
  Future<List<Quiz>> getQuizzesByCategory(String categoryId) async {
    try {
      final querySnapshot = await _quizzesCollection
          .where('categoryId', isEqualTo: categoryId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      // Get category data once
      final categoryDoc = await _categoriesCollection
          .doc(categoryId)
          .get();
      
      if (!categoryDoc.exists) {
        throw Exception('Category not found');
      }

      final categoryData = categoryDoc.data() as Map<String, dynamic>;
      final category = Category(
        categoryId: categoryData['categoryId'],
        categoryName: categoryData['categoryName'],
        quizCount: categoryData['quizCount'],
        quizzes: [], // Will be populated with the quizzes we're fetching
      );

      // Map documents to Quiz objects
      final quizzes = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Quiz(
          quizId: data['quizId'],
          category: data['category'],
          author: data['author'],
          description: data['description'],
          question: data['question'],
          answer1: data['answer1'],
          answer2: data['answer2'],
          answer3: data['answer3'],
          answer4: data['answer4'],
          correctAnswer: data['correctAnswer'],
        );
      }).toList();

      // Update category's quizzes list
      category.quizzes = quizzes;
      return quizzes;
    } catch (e) {
      log('Error getting quizzes by category: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<List<Category>> getAllCategories() async {
    try {
      final querySnapshot = await _categoriesCollection.get();
      
      return Future.wait(querySnapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;
        final categoryId = doc.id;
        
        // Get all quizzes for this category
        final quizzes = await getQuizzesByCategory(categoryId);
        
        return Category(
          categoryId: categoryId,
          categoryName: data['categoryName'],
          quizCount: data['quizCount'],
          quizzes: quizzes,
        );
      }).toList());
    } catch (e) {
      log('Error getting categories: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<void> addCategory(Category category) async {
    try {
      await _categoriesCollection.doc(category.categoryId).set({
        'categoryId': category.categoryId,
        'categoryName': category.categoryName,
        'quizIds': [], // Initialize empty array of quiz IDs
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error adding category: ${e.toString()}');
      rethrow;
    }
  }

  @override
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
  Future<void> deleteCategory(String categoryId) async {
    try {
      // First, delete all quizzes in this category
      final quizzes = await getQuizzesByCategory(categoryId);
      for (final quiz in quizzes) {
        await deleteQuiz(quiz.quizId);
      }
      
      // Then delete the category
      await _categoriesCollection.doc(categoryId).delete();
    } catch (e) {
      log('Error deleting category: ${e.toString()}');
      rethrow;
    }
  }
}

