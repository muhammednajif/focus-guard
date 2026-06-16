import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  _JourneyScreenState createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  int userProgress = 0;
  bool isLoading = true;
  final int totalDays = 100; // Total length of the journey

  // Define the milestones for the journey
  final Map<int, String> milestones = {
    0: 'The Beginning',
    7: 'Forest of Serenity',
    14: 'Mountain of Momentum',
    30: 'City of Discipline',
    60: 'Ocean of Calm',
    90: 'Galaxy of Focus',
  };

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userProgress = prefs.getInt('journey_progress') ?? 0;
      isLoading = false;
    });
  }

  // This function simulates making a day of progress.
  // In the real app, this would be called once per day when focus goals are met.
  Future<void> _incrementProgress() async {
    final prefs = await SharedPreferences.getInstance();
    if (userProgress < totalDays) {
      setState(() {
        userProgress++;
      });
      await prefs.setInt('journey_progress', userProgress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Focus Journey"),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.grey[900],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: totalDays,
              itemBuilder: (context, index) {
                final day = index + 1;
                bool isCompleted = day <= userProgress;
                bool isCurrent = day == userProgress + 1;
                String? milestone = milestones[index];

                return _buildJourneyStep(day, isCompleted, isCurrent, milestone);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _incrementProgress,
        icon: const Icon(Icons.arrow_upward),
        label: const Text("Simulate Progress"),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Widget _buildJourneyStep(int day, bool isCompleted, bool isCurrent, String? milestone) {
    IconData iconData;
    Color iconColor;
    String title;

    if (isCompleted) {
      iconData = Icons.check_circle;
      iconColor = Colors.green;
      title = "Day $day: Complete";
    } else if (isCurrent) {
      iconData = Icons.hiking;
      iconColor = Colors.amber;
      title = "Day $day: You are here!";
    } else {
      iconData = Icons.circle_outlined;
      iconColor = Colors.grey;
      title = "Day $day";
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 80,
            child: Column(
              children: [
                Expanded(
                  child: VerticalDivider(
                    thickness: 2,
                    color: day == 1 ? Colors.transparent : Colors.grey.shade700,
                  ),
                ),
                Icon(iconData, color: iconColor, size: 30),
                 Expanded(
                  child: VerticalDivider(
                    thickness: 2,
                    color: day == totalDays ? Colors.transparent : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isCompleted ? Colors.green : (isCurrent ? Colors.amber : Colors.white),
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  if (milestone != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "📍 $milestone",
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
