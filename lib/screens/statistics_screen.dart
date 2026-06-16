import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../services/focus_score_service.dart'; // Assuming you have this service

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool isLoading = true;
  int focusScore = 0;
  int journeyProgress = 0;
  int gardenLeaves = 0;

  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final score = await FocusScoreService.calculateSmartFocusScore();

    setState(() {
      focusScore = score;
      journeyProgress = prefs.getInt('journey_progress') ?? 0;
      gardenLeaves = prefs.getInt('focus_garden_leaves') ?? 0;
      isLoading = false;
    });
  }

  void _shareProgress() async {
    final image = await _screenshotController.capture(
      delay: const Duration(milliseconds: 10),
      pixelRatio: 2.0 // Higher resolution for sharing
    );

    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await File('${directory.path}/progress.png').create();
      await imagePath.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: "Here's my Focus Guard progress! #FocusGuard #Productivity",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress Snapshot"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareProgress,
            tooltip: "Share Progress",
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Screenshot(
                  controller: _screenshotController,
                  child: _buildShareableCard(),
                ),
              ),
            ),
    );
  }

  Widget _buildShareableCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF2D2D44)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.cyanAccent, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "My Focus Guard Stats",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 24),

          // Focus Score
          _buildStatItem(Icons.track_changes, "Focus Score", "$focusScore / 100"),
          const Divider(color: Colors.white24),

          // Journey Progress
          _buildStatItem(Icons.map, "Journey Progress", "Day $journeyProgress / 100"),
          const Divider(color: Colors.white24),

          // Focus Garden
          _buildStatItem(Icons.eco, "Focus Garden", "$gardenLeaves Leaves"),
          const SizedBox(height: 24),

          // Plant ASCII Art
          Text(
            _buildPlantAscii(gardenLeaves),
            style: const TextStyle(fontSize: 36, color: Colors.greenAccent, height: 1.2),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 30),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontSize: 18, color: Colors.white)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  // Using the same ASCII logic from the home screen
  String _buildPlantAscii(int leaves) {
    if (leaves == 0) return "🌱\n(Pot)";
    String stem = List.generate(leaves ~/ 3 + 1, (index) => '|').join('\n');
    String plant = List.generate(leaves, (index) => (index % 2 == 0 ? '/' : '\\')).join();
    return "$plant\n$stem\n|___|";
  }
}
