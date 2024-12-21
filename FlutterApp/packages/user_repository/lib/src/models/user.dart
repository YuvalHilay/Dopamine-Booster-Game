import '../entities/entities.dart';

class MyUser {
  String userId;
  String email;
  String firstName;
  String lastName;
  String gender;
  String userRole;

  // Constructor to initialize the user object with required fields.
  MyUser({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.userRole,
  });

  // A static, predefined "empty" user instance - to represent an unauthenticated or uninitialized user.
  static final empty = MyUser(
    userId: '',
    email: '',
    firstName: '',
    lastName: '',
    gender: '',
    userRole: '',
  );

  // Converts this [MyUser] instance into a [MyUserEntity] for persistence, when saving user data to a database.
  MyUserEntity toEntity() {
    return MyUserEntity(
      userId: userId,
      email: email,
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      userRole: userRole,
    );
  }
  // Creates a [MyUser] object from a [MyUserEntity], when retrieving user data from a database.
  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
        userId: entity.userId,
        email: entity.email,
        firstName: entity.firstName,
        lastName: entity.lastName,
        gender: entity.gender,
        userRole: entity.userRole);
  }

  @override
  // Provides a string representation of the [MyUser] instance.
  String toString() {
    return 'MyUser: $userId, $email, $firstName, $lastName, $gender, $userRole';
  }
}
