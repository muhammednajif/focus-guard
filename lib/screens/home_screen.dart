import 'package:flutter/material.dart';
import 'package:focus_guard/screens/focus_session_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/focus_score_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int focusScore = 0;
  String level = "Beginner";
  int focusCoins = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final score = await FocusScoreService.calculateSmartFocusScore();
    final profileBox = await Hive.openBox('userProfile');
    final coins = profileBox.get('focusCoins', defaultValue: 0) as int;

    if (mounted) {
      setState(() {
        focusScore = score;
        level = FocusScoreService.getLevel(score);
        focusCoins = coins;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber),
                const SizedBox(width: 4),
                Text("$focusCoins", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Smart Focus Score Gauge
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: focusScore / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[300],
                    color: focusScore > 70 ? Colors.green : (focusScore > 40 ? Colors.orange : Colors.red),
                  ),
                ),
                Column(
                  children: [
                    Text("$focusScore", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                    const Text("Focus Score", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text("Level: $level", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 60),
            ElevatedButton.icon(
              icon: const Icon(Icons.timer),
              label: const Text("Start Deep Focus Session"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FocusSessionScreen(durationMinutes: 25)),
                ).then((_) {
                  // Reload data after session ends
                  _loadDashboardData();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}