import 'package:flutter/services.dart';
import '../models/app_info.dart';

class AppService {
  static const MethodChannel _channel =
      MethodChannel('com.example.focus_guard/installed_apps');

  /// Retrieves the list of installed apps from the native side.
  static Future<List<AppInfo>> getInstalledApps() async {
    final raw = await _channel.invokeListMethod<dynamic>('getInstalledApps') ??
        const [];
    return raw
        .map((e) => AppInfo.fromMap(e as Map<dynamic, dynamic>))
        .where((app) => app.name.isNotEmpty && app.packageName.isNotEmpty)
        .toList();
  }

  static Future<String?> getAppIcon(String packageName) async {
    return _channel
        .invokeMethod<String>('getAppIcon', {'packageName': packageName});
  }

  static Future<void> updatePreferences(
    List<String> blockedApps,
    bool blockReels,
    bool blockShorts,
    bool blockExplore,
    bool blockStories,
    bool blockFeed,
    bool blockLive,
    bool blockHomeFeed,
    bool blockTrending,
    bool blockSubscriptions,
    bool fbBlockReels,
    bool fbBlockWatch,
    bool fbBlockMarketplace,
  ) async {
    await _channel.invokeMethod('updatePreferences', {
      'blockedApps': blockedApps,
      'blockReels': blockReels,
      'blockShorts': blockShorts,
      'blockExplore': blockExplore,
      'blockStories': blockStories,
      'blockFeed': blockFeed,
      'blockLive': blockLive,
      'blockHomeFeed': blockHomeFeed,
      'blockTrending': blockTrending,
      'blockSubscriptions': blockSubscriptions,
      'fbBlockReels': fbBlockReels,
      'fbBlockWatch': fbBlockWatch,
      'fbBlockMarketplace': fbBlockMarketplace,
    });
  }

  static Future<void> updateSchedules(
      List<Map<dynamic, dynamic>> schedules) async {
    // Convert to a format suitable for MethodChannel
    final formattedSchedules = schedules
        .map((s) => {
              'name': s['name'],
              'startHour': s['startHour'],
              'startMinute': s['startMinute'],
              'endHour': s['endHour'],
              'endMinute': s['endMinute'],
              'enabled': s['enabled'],
            })
        .toList();
    await _channel
        .invokeMethod('updateSchedules', {'schedules': formattedSchedules});
  }

  static Future<void> updateDailyLimit(double limitHours) async {
    await _channel.invokeMethod('updateDailyLimit', {'limitHours': limitHours});
  }

  static Future<void> requestUsagePermission() async {
    await _channel.invokeMethod('requestUsagePermission');
  }

  static Future<bool> checkAccessibilityService() async {
    final bool? result =
        await _channel.invokeMethod('checkAccessibilityService');
    return result ?? false;
  }

  static Future<void> openAccessibilitySettings() async {
    await _channel.invokeMethod('openAccessibilitySettings');
  }
}
