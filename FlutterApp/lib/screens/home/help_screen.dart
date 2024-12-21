import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.helpTitle),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                'What is ADHD?',
                'Attention-Deficit/Hyperactivity Disorder (ADHD) is a neurodevelopmental disorder characterized by persistent patterns of inattention, hyperactivity, and impulsivity.',
              ),
              _buildSection(
                'How Dopamine Booster Game Helps',
                'Our game is designed to stimulate dopamine production in the brain through engaging activities. This can help improve attention, focus, and impulse control.',
              ),
              _buildSection(
                'Features',
                '• Interactive games to boost concentration\n• Progress tracking\n• Customizable difficulty levels\n• Educational content integrated with gameplay',
              ),
              _buildSection(
                'Tips for Success',
                '• Play regularly for best results\n• Start with shorter sessions and gradually increase\n• Use the app in conjunction with other ADHD management strategies',
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/contact');
                  },
                  child: Text(AppLocalizations.of(context)!.contactUs),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

