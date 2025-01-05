import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[300]!,
              Colors.purple[300]!,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    AppLocalizations.of(context)!.helpTitle,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  background: Image.asset(
                    'assets/images/helpinfoImage.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        context,
                        AppLocalizations.of(context)!.helpSection1,
                        'Attention-Deficit/Hyperactivity Disorder (ADHD) is a neurodevelopmental disorder characterized by persistent patterns of inattention, hyperactivity, and impulsivity.',
                        Icons.psychology,
                      ),
                      _buildSection(
                        context,
                        AppLocalizations.of(context)!.helpSection2,
                        'Our game is designed to stimulate dopamine production in the brain through engaging activities. This can help improve attention, focus, and impulse control.',
                        Icons.games,
                      ),
                      _buildSection(
                        context,
                        AppLocalizations.of(context)!.helpSection3,
                        '• Interactive games to boost concentration\n• Progress tracking\n• Customizable difficulty levels\n• Educational content integrated with gameplay',
                        Icons.star,
                      ),
                      _buildSection(
                        context,
                        AppLocalizations.of(context)!.helpSection4,
                        '• Play regularly for best results\n• Start with shorter sessions and gradually increase\n• Use the app in conjunction with other ADHD management strategies',
                        Icons.lightbulb,
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          label: Text(
                            AppLocalizations.of(context)!.backBtn,
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[400],
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content, IconData icon) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.only(bottom: 20),
      child: ExpansionTile(
        leading: Icon(icon, size: 30, color: Colors.blue[700]),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: content.contains('•')
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: content.split('\n').map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.trim().startsWith('•'))
                              Container(
                                width: 8,
                                height: 8,
                                margin: EdgeInsets.only(top: 6, right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.orange[400],
                                  shape: BoxShape.circle,
                                ),
                              )
                            else
                              SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item.trim().startsWith('•') ? item.substring(1).trim() : item,
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                : Text(
                    content,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

