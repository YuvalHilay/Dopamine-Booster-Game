import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Function to show confirmation dialog before logout
Future<bool> showLogoutDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.logoutConf),
        content: Text(AppLocalizations.of(context)!.sureLogout),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Return false on cancel
            },
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Return true on logout
            },
            child: Text(
              AppLocalizations.of(context)!.logout,
              style: const TextStyle(color: Colors.red),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
