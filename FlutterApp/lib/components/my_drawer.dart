import 'package:Dopamine_Booster/screens/auth/blocs/sign_in_bloc/bloc/sign_in_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home,
                  title: AppLocalizations.of(context)!.home,
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline,
                  title: AppLocalizations.of(context)!.help,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/help');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.contact_support_outlined,
                  title: AppLocalizations.of(context)!.contact,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/contact');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: AppLocalizations.of(context)!.settings,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/app_icon.png',
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 10),
          Text(
            'Dopamine Booster Game',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.inversePrimary),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18),
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout),
        label: Text(AppLocalizations.of(context)!.logout),
        style: ElevatedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onError,
          backgroundColor: Theme.of(context).colorScheme.error,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () {
          BlocProvider.of<SignInBloc>(context).add(SignOutRequired());
          Navigator.pop(context);
        },
      ),
    );
  }
}

