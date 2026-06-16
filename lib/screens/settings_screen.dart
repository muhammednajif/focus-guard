import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/app_service.dart';
import '../services/blocking_sync_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool blockReels = true;
  bool blockShorts = true;
  double dailyLimit = 2.0;

  late Box settingsBox;
  bool isAccessibilityEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkAccessibility();
  }

  Future<void> _checkAccessibility() async {
    final enabled = await AppService.checkAccessibilityService();
    setState(() {
      isAccessibilityEnabled = enabled;
    });
  }

  Future<void> _loadSettings() async {
    settingsBox = await Hive.openBox('settings');
    setState(() {
      dailyLimit = settingsBox.get('dailyLimit', defaultValue: 0.0) as double;
      blockReels = settingsBox.get('blockReels', defaultValue: true) as bool;
      blockShorts = settingsBox.get('blockShorts', defaultValue: true) as bool;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const ListTile(
            title: Text("Permissions",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ListTile(
            leading: Icon(Icons.accessibility,
                color: isAccessibilityEnabled ? Colors.green : Colors.red),
            title: const Text("Accessibility Service"),
            subtitle: Text(isAccessibilityEnabled
                ? "Enabled"
                : "Tap to enable (Required for blocking)"),
            onTap: () async {
              await AppService.openAccessibilitySettings();
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text("Grant Usage Access"),
            subtitle: const Text("Required for Daily Limits to work"),
            onTap: () async {
              await AppService.requestUsagePermission();
            },
          ),
          const Divider(),
          const ListTile(
            title: Text("Daily Limits",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ListTile(
            title: const Text("Global App Daily Limit (Hours)"),
            subtitle: Slider(
              value: dailyLimit,
              min: 0.0,
              max: 5.0,
              divisions: 10,
              label: dailyLimit == 0.0
                  ? "Disabled"
                  : "${dailyLimit.toStringAsFixed(1)} hours",
              onChanged: (val) => setState(() => dailyLimit = val),
              onChangeEnd: (val) {
                settingsBox.put('dailyLimit', val);
                AppService.updateDailyLimit(val);
              },
            ),
          ),
          const Divider(),
          const ListTile(
            title: Text("Reels/Shorts Detection",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          SwitchListTile(
            title: const Text("Block Instagram Reels"),
            value: blockReels,
            onChanged: (val) async {
              setState(() => blockReels = val);
              settingsBox.put('blockReels', val);
              await BlockingSyncService.syncHiveStateToNative();
            },
          ),
          SwitchListTile(
            title: const Text("Block YouTube Shorts"),
            value: blockShorts,
            onChanged: (val) async {
              setState(() => blockShorts = val);
              settingsBox.put('blockShorts', val);
              await BlockingSyncService.syncHiveStateToNative();
            },
          ),
          const Divider(),
          const ListTile(
            title: Text("Phase 10 & 11: Premium Features",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text("Invite Accountability Friend"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Friend invited! (Mock)')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: const Text("Upgrade to Premium"),
            subtitle: const Text("Unlock cloud sync and advanced stats"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Upgraded! (Mock IAP)')));
            },
          ),
        ],
      ),
    );
  }
}
