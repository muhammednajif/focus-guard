import 'package:flutter/material.dart';
import 'package:focus_guard/screens/focus_session_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../services/focus_score_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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

    bool focusGoalMet = focusScore > 75;

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              const SizedBox(height: 40),
              FocusGarden(focusGoalMet: focusGoalMet),
              const SizedBox(height: 40),
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
                    _loadDashboardData();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FocusGarden extends StatefulWidget {
  final bool focusGoalMet;
  const FocusGarden({super.key, required this.focusGoalMet});

  @override
  _FocusGardenState createState() => _FocusGardenState();
}

class _FocusGardenState extends State<FocusGarden> {
  int leaves = 0;
  String? lastWateredDate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGardenState();
  }

  Future<void> _loadGardenState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      leaves = prefs.getInt('focus_garden_leaves') ?? 0;
      lastWateredDate = prefs.getString('focus_garden_last_watered');
      isLoading = false;
    });
  }

  Future<void> _waterPlant() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    setState(() {
      leaves++;
      lastWateredDate = today;
    });

    await prefs.setInt('focus_garden_leaves', leaves);
    await prefs.setString('focus_garden_last_watered', today);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your plant grew a new leaf!')),
    );
  }

  bool _canWater() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return widget.focusGoalMet && lastWateredDate != today;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            _buildPlantAscii(leaves),
            style: const TextStyle(fontSize: 24, height: 1.2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.water_drop),
            label: const Text("Water Plant"),
            onPressed: _canWater() ? _waterPlant : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          if (!_canWater() && widget.focusGoalMet)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text("You've already watered today. Come back tomorrow!", style: TextStyle(color: Colors.grey)),
            )
          else if (!_canWater() && !widget.focusGoalMet)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text("Meet your focus goal (Score > 75) to water your plant!", style: TextStyle(color: Colors.grey)),
            )
        ],
      ),
    );
  }

  String _buildPlantAscii(int leaves) {
    if (leaves == 0) return "🌱\nPot";
    String stem = List.generate(leaves ~/ 3 + 1, (index) => '|').join('\n');
    String plant = List.generate(leaves, (index) => (index % 2 == 0 ? '/' : '\\')).join();
    return "$plant\n$stem\n|___|";
  }
}
