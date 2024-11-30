import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/models/questions.dart';

const String QUESTIONS_COLLECTION_REF = "questions";

class DatabaseService {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _questionsRef;

  DatabaseService() {
    _questionsRef = _firestore
        .collection(QUESTIONS_COLLECTION_REF)
        .withConverter<Questions>(
            fromFirestore: (snapshots, _) => Questions.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (questions, _) => questions.toJson());
  }

  Stream<QuerySnapshot> getQuestions() {
    return _questionsRef.snapshots();
  }
}
