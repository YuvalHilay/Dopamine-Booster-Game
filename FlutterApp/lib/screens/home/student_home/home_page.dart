import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quiz_repository/quiz.repository.dart';

class HomeScreen extends StatefulWidget {
  final String gender;

  const HomeScreen({Key? key, required this.gender}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final QuizRepository _quizRepository = FirebaseQuizRepo();
  late String selectedAvatar;
  final List<String> avatarPaths = [
    'assets/avatars/avatar1.png',
    'assets/avatars/avatar2.png',
    'assets/avatars/avatar3.png',
    'assets/avatars/avatar4.png',
    'assets/avatars/avatar5.png',
    'assets/avatars/avatar6.png',
    'assets/avatars/avatar7.png',
    'assets/avatars/avatar8.png',
    'assets/avatars/avatar9.png',
  ];

  @override
  void initState() {
    super.initState();
    selectedAvatar = widget.gender == 'F' ? 'assets/avatars/avatar1.png' : 'assets/avatars/avatar2.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showAvatarDialog(context);
                      },
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: AssetImage(selectedAvatar),
                        backgroundColor: Colors.orange[100],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)!.changeAvatar,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Leaderboard Section
              _buildCard(
                title: AppLocalizations.of(context)!.leaderboard,
                icon: Icons.leaderboard,
                color: Colors.blue,
                description: AppLocalizations.of(context)!.leaderboardMsg,
                leaderboard: FutureBuilder<List<Map<String, dynamic>>>( // FutureBuilder for leaderboard data
                  future: _quizRepository.getLeaderboard(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    final leaderboard = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < leaderboard.length; i++)
                          _buildLeaderboardEntry(
                            position: i + 1,
                            userName: leaderboard[i]['userName'] as String,   
                            score: leaderboard[i]['totalScore'] as double,
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Achievements Section
              _buildCard(
                title: AppLocalizations.of(context)!.achievements,
                icon: Icons.star,
                color: Colors.orange,
                description: AppLocalizations.of(context)!.achievementsMsg,
              ),
              const SizedBox(height: 32)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardEntry({
    required int position,
    required String userName, 
    required double score,
  }) {
    final colors = [Colors.amber, Colors.grey, Colors.brown]; // Colors for positions 1, 2, 3

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: position <= 3 ? colors[position - 1] : Colors.grey[400],
          child: Text(
            position.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        // top 3 users' names 
        Expanded(
          child: Text(
            userName.isNotEmpty ? userName : ' - ', 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        //top 3 users' points 
        Text(
          score > 0 ? '${score.toStringAsFixed(1)} pts' : '-',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    Widget? leaderboard, // Optional widget to display leaderboard data
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 50, color: color),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            if (leaderboard != null) leaderboard, // Show leaderboard if provided
          ],
        ),
      ),
    );
  }

  // Avatar Selection Dialog
  void _showAvatarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.chooseAvatar,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: avatarPaths.map((path) {
                  return GestureDetector(
                    onTap: () {
                      // Update the selected avatar and close the dialog
                      setState(() {
                        selectedAvatar = path;
                      });
                      Navigator.pop(context); // Close dialog
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(path),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
