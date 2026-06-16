import 'package:hive_flutter/hive_flutter.dart';

class FocusScoreService {
  static Future<int> calculateSmartFocusScore() async {
    try {
      final sessionBox = await Hive.openBox('sessionHistory');
      final cravingBox = await Hive.openBox('cravingHistory');
      
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1)).copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

      double focusHours = 0.0;
      int completedSessions = 0;
      int totalSessions = 0;
      Set<String> activeDates = {};

      for (var i = 0; i < sessionBox.length; i++) {
        final session = sessionBox.getAt(i) as Map<dynamic, dynamic>;
        final timestamp = DateTime.parse(session['timestamp'] as String);
        final durationMins = session['durationMinutes'] as int;
        final completed = (session['completed'] as bool?) ?? true;

        if (timestamp.isAfter(startOfWeek) || timestamp.isAtSameMomentAs(startOfWeek)) {
          focusHours += durationMins / 60.0;
          totalSessions++;
          if (completed) completedSessions++;
        }

        final dateStr = "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}";
        if (durationMins > 0) activeDates.add(dateStr);
      }

      int currentStreak = 0;
      DateTime checkDate = now;
      while (true) {
        final dateStr = "${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}";
        if (activeDates.contains(dateStr)) {
          currentStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          if (checkDate.year == now.year && checkDate.month == now.month && checkDate.day == now.day) {
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

      int cravings = 0;
      for (var i = 0; i < cravingBox.length; i++) {
        final craving = cravingBox.getAt(i) as Map<dynamic, dynamic>;
        final timestamp = DateTime.parse(craving['timestamp'] as String);
        if (timestamp.isAfter(startOfWeek) || timestamp.isAtSameMomentAs(startOfWeek)) {
          cravings++;
        }
      }

      // Mathematical Model: FS = (F * S * C) / D
      // F = Focus Hours
      // S = Session Completion Rate (0.1 to 1.0)
      // C = Consistency Factor (Streak multiplier)
      // D = Distractions (Cravings)
      
      double completionRate = totalSessions > 0 ? (completedSessions / totalSessions) : 0.5;
      if (completionRate < 0.1) completionRate = 0.1;
      
      double consistency = 1.0 + (currentStreak * 0.1); // Max +X based on streak
      if (consistency > 2.0) consistency = 2.0;

      double distractionWeight = 1.0 + (cravings * 0.2);

      double rawScore = (focusHours * completionRate * consistency * 10) / distractionWeight;

      // Scale to 0-100
      int finalScore = rawScore.round();
      if (finalScore > 100) finalScore = 100;
      if (finalScore < 0) finalScore = 0;

      return finalScore;
    } catch (e) {
      return 0; // Default error score
    }
  }

  static String getLevel(int score) {
    if (score < 20) return "Beginner";
    if (score < 50) return "Focused";
    if (score < 80) return "Disciplined";
    return "Master";
  }
}
