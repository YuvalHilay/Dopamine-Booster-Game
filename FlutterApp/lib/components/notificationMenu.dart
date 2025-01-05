import 'package:flutter/material.dart';

class NotificationIcon extends StatefulWidget {
  // Accepts a list of notifications as input
  final List<String> notifications;

  const NotificationIcon({
    Key? key,
    required this.notifications,
  }) : super(key: key);

  @override
  _NotificationIconState createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  late List<String> notifications; // Local copy of notifications for state management
  bool _isDropdownOpen = false; // Tracks whether the dropdown is open

  @override
  void initState() {
    super.initState();
    // Initialize the local notifications list with the provided notifications
    notifications = List<String>.from(widget.notifications);
  }

  // Toggles the dropdown menu's visibility
  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen; // Flip the dropdown state
    });
  }

  // Removes a notification by index and updates the UI
  void _removeNotification(int index) { 
    if (index >= 0 && index < notifications.length) {
      setState(() {
        notifications.removeAt(index); // Remove the selected notification
        // Close the dropdown if no notifications remain
        if (notifications.isEmpty) {
          _isDropdownOpen = false;
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl; // Check text direction
    final screenWidth = MediaQuery.of(context).size.width; // Get the screen width

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: _toggleDropdown, // Toggle the dropdown when tapped
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        if (_isDropdownOpen)
          Positioned(
            // The dropdown menu, positioned dynamically based on locale
            top: 40,
            left: isRtl ? 0 : null,
            right: isRtl ? null : 0,
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenWidth * 0.7, // Dynamically adjust to 70% of screen width
                  maxHeight: notifications.length > 4 ? 300 : double.infinity,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 2.5),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        radius: 18,
                        child: Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                        ),
                      ),
                      title: Text(
                        notifications[index],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: isRtl ? TextAlign.right : TextAlign.left,
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          _removeNotification(index);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
