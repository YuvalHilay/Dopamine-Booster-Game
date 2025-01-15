import 'package:Dopamine_Booster/components/popup_msg.dart';
import 'package:Dopamine_Booster/utils/PreferencesService.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final String packageName = "com.DopamineGame.DopamineGame";
  final PreferencesService _preferencesService = PreferencesService();
  bool isAPKInstalled = false; // Track installation status
  static const int countdownDuration = 2 * 60 * 60  ; // 3-hour timer in seconds
  bool isButtonLocked = false;
  int countdown = 0;
  Timer? _countdownTimer;
  bool isDownloadComplete = false;  // Track the APK download status
  bool isInstallButtonVisible = false; // Track visibility of the Install button
  bool isDownloading = false; // Track download progress

  @override
  void initState() {
    super.initState();
    _loadTimerState();
    _checkIfAPKInstalled(); // Check if the APK has been installed
  }

  // Check if the APK is installed by checking the PreferencesService
  Future<void> _checkIfAPKInstalled() async {
    final bool? isInstalled = await _preferencesService.getAPKInstalledStatus();
    print(isInstalled);
    if (isInstalled == true) {
      setState(() {
        isAPKInstalled = true;
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTimerState() async {
    final int? savedTimestamp =
        await _preferencesService.getTimerEndTimestamp();
    if (savedTimestamp != null) {
      final int currentTime = DateTime.now().millisecondsSinceEpoch;
      if (savedTimestamp > currentTime) {
        setState(() {
          isButtonLocked = true;
          countdown = (savedTimestamp - currentTime) ~/ 1000;
        });
        _startCountdown();
      } else {
        await _preferencesService.clearTimerEndTimestamp();
      }
    }
  }

  Future<void> _saveTimerState(int durationSeconds) async {
    final int endTimestamp =
        DateTime.now().millisecondsSinceEpoch + durationSeconds * 1000;
    await _preferencesService.setTimerEndTimestamp(endTimestamp);
  }

  // Method to download and install the APK
  Future<void> downloadAndInstallAPK() async {
    setState(() {
      isDownloading = true; // Start download
    });
    try {
      // Firebase Storage file URL
      String fileUrl = 'gs://dopamine-game.firebasestorage.app/DopamineGame64.apk';
      final ref = FirebaseStorage.instance.refFromURL(fileUrl);
      final String downloadUrl = await ref.getDownloadURL();

      // Download the APK file
      final response = await http.get(Uri.parse(downloadUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/game.apk');
        await file.writeAsBytes(response.bodyBytes);

        // Open and trigger APK installation
        final result = await OpenFile.open(file.path);
        if (result.type != ResultType.done) { 
          displayMessageToUser(AppLocalizations.of(context)!.errorInstallApk, context);
        }

        setState(() {
          isDownloadComplete = true; // Update the button to hide after download
          isAPKInstalled = true;
          isDownloading = false; // Download complete
        });
        await _preferencesService.setAPKInstalledStatus(true);
      } else {
        throw Exception("Failed to download thhe game APK");
      }
    } catch (e) {
      setState(() {
        isDownloading = false; // Hide the progress indicator on error
      }); 
      displayMessageToUser(AppLocalizations.of(context)!.errorDownloadApk, context);
    }
  }

  // Method to open the Dopamine Booster Game in the phonem adjust state and game timer start
  Future<void> startGame() async {
  try {
    // Try to open the app
    await LaunchApp.openApp(
      androidPackageName: packageName,
      iosUrlScheme: 'pulsesecure://',
      appStoreLink: 'itms-apps://itunes.apple.com/us/app/pulse-secure/id945832041',
      openStore: false,
    );

    // Lock the button and start the countdown
    setState(() {
      isButtonLocked = true;
      countdown = countdownDuration;
    });

    // Save the timer state
    await _saveTimerState(countdown);
    _startCountdown();
  } catch (e) {
    // Handle any errors
    displayMessageToUser(AppLocalizations.of(context)!.failedGameStart,context);
  }
}


  void _startCountdown() {
    _countdownTimer?.cancel(); // Cancel any existing timer
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
  if (!mounted) {
    timer.cancel();
    return;
  }
  if (countdown > 0 && mounted) {
    setState(() {
      countdown--;
    });
  } else {
    timer.cancel();
    setState(() {
      isButtonLocked = false;
    });
    _preferencesService.clearTimerEndTimestamp();
  }
});
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/boostergameimg.png',
              fit: BoxFit.fill,
            ),
          ),
          // Content overlay
          Center(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.25), // Moves children 50 pixels from the top
                // Download and Install button, only visible if APK is not installed
                if (!isAPKInstalled && !isButtonLocked) 
                  ElevatedButton(
                    onPressed: downloadAndInstallAPK,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: TextStyle(fontSize: 18),
                      foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(AppLocalizations.of(context)!.downloadBtn),
                  ),
                
                // Show the progress indicator while downloading
                if (isDownloading)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: CircularProgressIndicator(),
                  ),
                
                // Start Game button, only visible if APK is installed and the button is not locked
                if (isAPKInstalled && !isButtonLocked)
                  ElevatedButton(
                    onPressed: startGame,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: TextStyle(fontSize: 18),
                      foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(AppLocalizations.of(context)!.startGame),
                  ),
                
                // Countdown message
                if (isButtonLocked && countdown > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      AppLocalizations.of(context)!.gameAvailableIn(
                        (countdown ~/ 3600).toString().padLeft(2, '0'),
                        ((countdown % 3600) ~/ 60).toString().padLeft(2, '0'),
                        (countdown % 60).toString().padLeft(2, '0')                       
                        ),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
