import 'package:Dopamine_Booster/components/popup_msg.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Dopamine_Booster/utils/PreferencesService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HelpScreen extends StatelessWidget {
  HelpScreen({Key? key}) : super(key: key);

  final PreferencesService _preferencesService = PreferencesService();

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
                        AppLocalizations.of(context)!.adhdDescription,  
                      Icons.psychology,
                      ),
                      _buildSection(
                        context,
                        AppLocalizations.of(context)!.helpSection2,
                        AppLocalizations.of(context)!.dopamineGameDescription,
                        Icons.games,
                      ),
                      _buildSection(
                        context,
                        AppLocalizations.of(context)!.helpSection3,
                        AppLocalizations.of(context)!.gameFeatures,
                        Icons.star,
                      ),
                      _buildSection(
                        context,
                        AppLocalizations.of(context)!.helpSection4,
                        AppLocalizations.of(context)!.tipsForSuccess,
                        Icons.lightbulb,
                      ),
                      _buildSection(
                        context,
                        AppLocalizations.of(context)!.helpSection5,
                        AppLocalizations.of(context)!.gameInstallHelp,
                        Icons.install_desktop,
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
                                  textStyle: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.inversePrimary),
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
                      textStyle: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                  ),
          ),
          // Reset button in game install section
          if (title == AppLocalizations.of(context)!.helpSection5) 
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  await _preferencesService.setAPKInstalledStatus(false); 
                  // Display a message to the user after resetting the status.
                  displayMessageToUser(AppLocalizations.of(context)!.resetInstallSuccessMsg,context);
                },
                child: Text(AppLocalizations.of(context)!.resetInstallBtn),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}