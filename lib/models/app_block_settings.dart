class AppBlockSettings {
  final String packageName;
  final String reason;
  final int dailyLimitMinutes;
  final int daysPerWeek;

  AppBlockSettings({
    required this.packageName,
    required this.reason,
    required this.dailyLimitMinutes,
    required this.daysPerWeek,
  });

  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'reason': reason,
      'dailyLimitMinutes': dailyLimitMinutes,
      'daysPerWeek': daysPerWeek,
    };
  }

  factory AppBlockSettings.fromMap(Map<dynamic, dynamic> map) {
    return AppBlockSettings(
      packageName: map['packageName'] as String,
      reason: map['reason'] as String,
      dailyLimitMinutes: map['dailyLimitMinutes'] as int,
      daysPerWeek: map['daysPerWeek'] as int,
    );
  }
}
