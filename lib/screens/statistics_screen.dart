import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool isLoading = true;
  List<double> weeklyData = List.filled(7, 0.0);
  int streakDays = 0;
  double maxY = 10.0;
  int weeklyCravings = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final box = await Hive.openBox('sessionHistory');
    final cravingBox = await Hive.openBox('cravingHistory');
    final now = DateTime.now();
    // Start of the current week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)).copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    
    List<double> week = List.filled(7, 0.0);
    Set<String> activeDates = {};

    for (var i = 0; i < box.length; i++) {
      final session = box.getAt(i) as Map<dynamic, dynamic>;
      final timestamp = DateTime.parse(session['timestamp'] as String);
      final durationMins = session['durationMinutes'] as int;

      // Track streak dates
      final dateStr = "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}";
      if (durationMins > 0) {
        activeDates.add(dateStr);
      }

      // Add to weekly chart if in current week
      if (timestamp.isAfter(startOfWeek) || timestamp.isAtSameMomentAs(startOfWeek)) {
        int dayIndex = timestamp.weekday - 1; // 0 = Monday, 6 = Sunday
        week[dayIndex] += durationMins / 60.0; // hours
      }
    }

    // Calculate streak
    int currentStreak = 0;
    DateTime checkDate = now;
    while (true) {
      final dateStr = "${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}";
      if (activeDates.contains(dateStr)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        if (checkDate.year == now.year && checkDate.month == now.month && checkDate.day == now.day) {
           // Maybe they haven't focused today yet, check yesterday
           checkDate = checkDate.subtract(const Duration(days: 1));
           final yesterdayStr = "${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}";
           if(activeDates.contains(yesterdayStr)){
             currentStreak++;
             checkDate = checkDate.subtract(const Duration(days: 1));
             continue;
           }
        }
        break;
      }
    }

    double maxVal = week.reduce((a, b) => a > b ? a : b);
    
    int cravingsCount = 0;
    for (var i = 0; i < cravingBox.length; i++) {
      final craving = cravingBox.getAt(i) as Map<dynamic, dynamic>;
      final timestamp = DateTime.parse(craving['timestamp'] as String);
      if (timestamp.isAfter(startOfWeek) || timestamp.isAtSameMomentAs(startOfWeek)) {
        cravingsCount++;
      }
    }

    setState(() {
      weeklyData = week;
      streakDays = currentStreak;
      maxY = maxVal > 10.0 ? maxVal * 1.2 : 10.0;
      weeklyCravings = cravingsCount;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Weekly Focus (Hours)", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          if (value.toInt() >= 0 && value.toInt() < 7) {
                            return Text(days[value.toInt()]);
                          }
                          return const Text("");
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: List.generate(7, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [BarChartRodData(toY: weeklyData[index], color: Colors.green, width: 16, borderRadius: BorderRadius.circular(4))],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.local_fire_department, color: Colors.orange),
                title: const Text("Current Focus Streak"),
                trailing: Text("$streakDays Days", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                title: const Text("Distraction Attempts (7 Days)"),
                subtitle: const Text("Times you tried to open a blocked app"),
                trailing: Text("$weeklyCravings", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
