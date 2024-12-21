class MyUserEntity {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String userRole;

  // Constructor for initializing the entity.
  MyUserEntity({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.userRole,
  });

  // Converts the current object into a map representation for serializing the entity to a database.
  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'userRole': userRole,
    };
  }
  // Factory method for creating a `MyUserEntity` object from a map for deserializing data retrieved from a database.
  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    return MyUserEntity(
      userId: doc['userId'], 
      email: doc['email'],
      firstName: doc['firstName'],
      lastName: doc['lastName'],
      gender: doc['gender'],
      userRole: doc['userRole'],
    );
  }
}
