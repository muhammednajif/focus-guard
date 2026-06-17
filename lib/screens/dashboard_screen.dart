
import 'package:flutter/material.dart';
import 'package:focus_guard/screens/focus_session_screen.dart';
import 'package:focus_guard/widgets/focus_score_indicator_painter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/focus_score_service.dart';
import '../widgets/plant_widget.dart'; // Assuming this is where your new plant widget is
import 'package:shared_preferences/shared_preferences.dart';

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
    if (isLoading) return const Center(child: CircularProgressIndicator());

    bool focusGoalMet = focusScore > 75;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text("Your Focus Dashboard", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 30),
            SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: FocusScoreIndicatorPainter(score: focusScore.toDouble(), goal: 75),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$focusScore",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 48),
                      ),
                      Text("Focus Score", style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text("Level: $level", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            focusScore < 40
                ? _buildLowScoreIllustration()
                : FocusGarden(focusGoalMet: focusGoalMet),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.timer),
              label: const Text("Start Deep Focus Session"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FocusSessionScreen(durationMinutes: 25)),
                ).then((_) {
                  _loadDashboardData();
                });
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLowScoreIllustration() {
    return Column(
      children: [
        Icon(Icons.sentiment_very_dissatisfied, size: 80, color: Colors.red[400]),
        const SizedBox(height: 20),
        Text(
          "Feeling distracted?",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text(
          "Take a short break, or start a focus session to get back on track.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class FocusGarden extends StatefulWidget {
  final bool focusGoalMet;
  const FocusGarden({super.key, required this.focusGoalMet});

  @override
  _FocusGardenState createState() => _FocusGardenState();
}

class _FocusGardenState extends State<FocusGarden> with SingleTickerProviderStateMixin {
  int leaves = 0;
  String? lastWateredDate;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadGardenState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    _animationController.forward(from: 0);

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
      return const SizedBox(height: 250, child: Center(child: CircularProgressIndicator()));
    }

    return Column(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1 + _animation.value * 0.1,
              child: PlantWidget(leaves: leaves),
            );
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.water_drop),
          label: const Text("Water Plant"),
          onPressed: _canWater() ? _waterPlant : null,
        ),
        const SizedBox(height: 10),
        Text(
          _canWater()
              ? "Your plant is thirsty!"
              : (widget.focusGoalMet
                  ? "You've already watered today. Come back tomorrow!"
                  : "Meet your focus goal (Score > 75) to water your plant!"),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
