class AppInfo {
  final String name;
  final String packageName;

  AppInfo({
    required this.name,
    required this.packageName,
  });

  factory AppInfo.fromMap(Map<dynamic, dynamic> map) => AppInfo(
        name: map['name'] as String? ?? '',
        packageName:
            map['packageName'] as String? ?? map['package'] as String? ?? '',
      );
}
