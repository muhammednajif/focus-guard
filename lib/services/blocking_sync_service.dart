import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app_service.dart';

class BlockingSyncService {
  static Future<void> syncHiveStateToNative() async {
    try {
      final blockedAppsBox = await Hive.openBox('blockedApps');
      final settingsBox = await Hive.openBox('settings');

      final blockedApps = blockedAppsBox.keys.cast<String>().toList();
      final blockReels =
          settingsBox.get('blockReels', defaultValue: true) as bool;
      final blockShorts =
          settingsBox.get('blockShorts', defaultValue: true) as bool;
      final blockExplore =
          settingsBox.get('blockExplore', defaultValue: false) as bool;
      final blockStories =
          settingsBox.get('blockStories', defaultValue: false) as bool;
      final blockFeed =
          settingsBox.get('blockFeed', defaultValue: false) as bool;
      final blockLive =
          settingsBox.get('blockLive', defaultValue: false) as bool;
      final blockHomeFeed =
          settingsBox.get('blockHomeFeed', defaultValue: false) as bool;
      final blockTrending =
          settingsBox.get('blockTrending', defaultValue: false) as bool;
      final blockSubscriptions =
          settingsBox.get('blockSubscriptions', defaultValue: false) as bool;
      final fbBlockReels =
          settingsBox.get('fbBlockReels', defaultValue: false) as bool;
      final fbBlockWatch =
          settingsBox.get('fbBlockWatch', defaultValue: false) as bool;
      final fbBlockMarketplace =
          settingsBox.get('fbBlockMarketplace', defaultValue: false) as bool;

      await AppService.updatePreferences(
        blockedApps,
        blockReels,
        blockShorts,
        blockExplore,
        blockStories,
        blockFeed,
        blockLive,
        blockHomeFeed,
        blockTrending,
        blockSubscriptions,
        fbBlockReels,
        fbBlockWatch,
        fbBlockMarketplace,
      );
    } on MissingPluginException catch (e) {
      debugPrint('Native blocking sync unavailable on this platform: $e');
    } catch (e) {
      debugPrint('Failed to sync Hive blocking state to native: $e');
    }
  }
}
