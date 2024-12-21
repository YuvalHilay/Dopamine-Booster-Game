import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.profile,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildUserAvatar(),
                const SizedBox(height: 20),
                _buildUserInfo(),
                const Divider(thickness: 1, height: 40),
                _buildProfileOptions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            //backgroundImage: const AssetImage('assets/avatar_placeholder.png'),
            backgroundColor: Colors.grey[300],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // TODO: Implement change avatar functionality
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Text(
          'John Doe',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'john.doe@example.com',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    return Column(
      children: [
        _buildOptionTile(
          context,
          icon: Icons.settings,
          title: 'Settings',
          onTap: () {
            // TODO: Navigate to settings screen
          },
        ),
        _buildOptionTile(
          context,
          icon: Icons.account_circle,
          title: 'Account Info',
          onTap: () {
            // TODO: Navigate to account info screen
          },
        ),
        _buildOptionTile(
          context,
          icon: Icons.notifications,
          title: 'Notifications',
          onTap: () {
            // TODO: Navigate to notifications settings
          },
        ),
        _buildOptionTile(
          context,
          icon: Icons.help,
          title: 'Help & Support',
          onTap: () {
            // TODO: Navigate to help & support
          },
        ),
        _buildOptionTile(
          context,
          icon: Icons.logout,
          title: 'Logout',
          onTap: () {
            _showLogoutDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 28, color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement logout logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully.')),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
