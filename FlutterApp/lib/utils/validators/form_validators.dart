
// form_validators.dart
class FormValidators {
  // Validate Name
 static String? validateName(String? value, {required int maxLength}) {
  if (value == null || value.trim().isEmpty) {
    return 'Name is required';
  }
  if (value.length > maxLength) {
    return 'Name cannot exceed $maxLength characters';
  }
  // Updated regex to allow Hebrew, English letters, and spaces
  final nameRegex = RegExp(r'^[\p{L}\s]+$', unicode: true);
  if (!nameRegex.hasMatch(value)) {
    return "Name must only contain letters and spaces.";
  }
  return null;
}

  // Validate Email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Validate Password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

 // Validate Message
static String? validateMessage(String? value, 
    {int minLength = 10, int maxWords = 150}) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter your message';
  }

  // Ensure accurate character count, considering trimmed Unicode strings
  final trimmedValue = value.trim();

  // Check minimum character length
  if (trimmedValue.runes.length < minLength) {
    return 'Message must be at least $minLength characters long';
  }

  // Check maximum word count, accounting for Unicode word boundaries
  final wordCount = trimmedValue.split(RegExp(r'\s+')).length;
  if (wordCount > maxWords) {
    return 'Message must not exceed $maxWords words';
  }

  return null;
}

}
