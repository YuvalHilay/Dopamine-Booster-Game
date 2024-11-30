// ignore_for_file: file_names

import 'dart:ffi';

class Questions {
  Long id;
  Long teacherId;
  String question;

  Questions({
    required this.id,
    required this.teacherId,
    required this.question,
  });

  Questions.fromJson(Map<String, Object?> json)
      : this(
          id: json['id']! as Long,
          teacherId: json['teacherId']! as Long,
          question: json['question']! as String,
        );

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'teacherId': teacherId,
    };
  }
}
