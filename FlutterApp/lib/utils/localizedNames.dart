  // Localize category names based on the app's language settings.
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String getLocalizedCategoryName(BuildContext context, String categoryName) {
  final localizations = AppLocalizations.of(context)!;

  // Define a map of all possible base categories and their localized names
  final categories = {
    'Sports': localizations.sport,
    'Physics': localizations.physics,
    'Science': localizations.science,
    'History': localizations.history,
    'Math': localizations.math,
    'Geography': localizations.geography,
    'English': localizations.english,
  };

  // Check if the category is an exact match in the map
  if (categories.containsKey(categoryName)) {
    return categories[categoryName]!;
  }

  // Handle dynamic cases with a suffix (e.g., 'Math x', 'English 2')
  for (var entry in categories.entries) {
    final baseCategory = entry.key; // e.g., 'Math', 'English'
    final localizedCategory = entry.value;

    if (categoryName.startsWith('$baseCategory ')) {
      final suffix = categoryName.replaceFirst('$baseCategory ', ''); // Extract the suffix
      if (int.tryParse(suffix) != null) { // Ensure the suffix is a valid number
        return '$localizedCategory $suffix'; // Return localized name with suffix
      }
    }
  }

  // Return the original name if no match is found
  return categoryName;
}