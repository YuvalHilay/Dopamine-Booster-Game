import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoriesBar extends StatefulWidget implements PreferredSizeWidget {
  // This callback is triggered when the search query changes
  final Function(String) onSearchChanged;

  const CategoriesBar({
    Key? key,
    required this.onSearchChanged, // The search change callback is required
  }) : super(key: key);

  // The preferred size for the AppBar to maintain consistency with the default height
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CategoriesBar> createState() => _CategoriesBarState();
}

class _CategoriesBarState extends State<CategoriesBar> {
  // Controller for the search text field to manage the text input
  final TextEditingController _searchController = TextEditingController();
  
  // Flag to track if the search mode is active
  bool _isSearching = false;

  // Starts the search mode when the search icon is pressed
  void _startSearch() {
    setState(() {
      _isSearching = true; // Set the flag to true, indicating search mode is active
    });
  }

  // Stops the search mode, clears the search field, and resets the search query
  void _stopSearch() {
    setState(() {
      _isSearching = false; // Set the flag to false, exiting search mode
      _searchController.clear(); // Clear the search field
      widget.onSearchChanged(''); // Reset the search query by passing an empty string
    });
  }

  // Updates the search query and triggers the callback with the lowercase query
  void _updateSearchQuery(String newQuery) {
    widget.onSearchChanged(newQuery.toLowerCase()); // Pass the search query in lowercase to the parent widget
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Background gradient for the AppBar
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.secondary, 
              Theme.of(context).colorScheme.primary,  
            ],
          ),
        ),
      ),
      elevation: 0, // Remove elevation to make the AppBar flat
      centerTitle: true, 
      title: _isSearching
          // If in search mode, show the search TextField
          ? TextField(
              controller: _searchController, // Controller to manage the text input
              autofocus: true, // Auto-focus the field on entering search mode
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchCategories, 
                border: InputBorder.none, // Remove border for a clean look
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.8), 
                ),
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary), 
              onChanged: _updateSearchQuery, // Callback when the text changes
            )
          // If not in search mode, show the title with an icon
          : Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the elements horizontally
              children: [
                Icon(
                  Icons.category_rounded, 
                  size: 36, 
                  color: Theme.of(context).colorScheme.inversePrimary, 
                ),
                const SizedBox(width: 12), // Add some space between the icon and the title
                Text(
                  AppLocalizations.of(context)!.categories, 
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold, 
                    color: Theme.of(context).colorScheme.inversePrimary, 
                  ),
                ),
              ],
            ),
      actions: [
        // Icon button for toggling search mode
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search_rounded, // Change icon based on search mode
            color: Theme.of(context).colorScheme.inversePrimary, 
          ),
          onPressed: _isSearching ? _stopSearch : _startSearch, // Toggle search mode on press
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }
}
