import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_info.dart';
import '../services/app_service.dart';
import '../services/blocking_sync_service.dart';

class AppsScreen extends StatefulWidget {
  const AppsScreen({super.key});

  @override
  State<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> {
  List<AppInfo> installedApps = [];
  bool isLoading = true;
  String? loadError;
  late Box blockedAppsBox;
  late Box settingsBox;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    blockedAppsBox = await Hive.openBox('blockedApps');
    settingsBox = await Hive.openBox('settings');
    try {
      final apps = await AppService.getInstalledApps();
      setState(() {
        installedApps = apps;
        loadError = null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        loadError = e.toString();
        isLoading = false;
      });
      debugPrint("Failed to load apps: $e");
    }
  }

  Future<void> _updateNativePrefs() async {
    await BlockingSyncService.syncHiveStateToNative();
  }

  void _showDeepBlockOptions(AppInfo app) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isBlocked = blockedAppsBox.get(app.packageName,
                defaultValue: false) as bool;
            final blockReels =
                settingsBox.get('blockReels', defaultValue: true) as bool;
            final blockExplore =
                settingsBox.get('blockExplore', defaultValue: false) as bool;
            final blockShorts =
                settingsBox.get('blockShorts', defaultValue: true) as bool;

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Deep Block: ${app.name}",
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text("Block Entire App",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Prevent all access to this app"),
                    value: isBlocked,
                    onChanged: (val) {
                      setSheetState(() {
                        if (val) {
                          blockedAppsBox.put(app.packageName, true);
                        } else {
                          blockedAppsBox.delete(app.packageName);
                        }
                      });
                      setState(() {});
                      _updateNativePrefs();
                    },
                  ),
                  if (app.packageName.contains("instagram")) ...[
                    const Divider(),
                    const Text("Content Blocks",
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold)),
                    SwitchListTile(
                      title: const Text("Block Reels"),
                      subtitle: const Text("Prevent access to Instagram Reels"),
                      value: blockReels,
                      onChanged: isBlocked
                          ? null
                          : (val) {
                              setSheetState(
                                  () => settingsBox.put('blockReels', val));
                              _updateNativePrefs();
                            },
                    ),
                    SwitchListTile(
                      title: const Text("Block Explore/Search"),
                      subtitle:
                          const Text("Prevent mindless scrolling in Explore"),
                      value: blockExplore,
                      onChanged: isBlocked
                          ? null
                          : (val) {
                              setSheetState(
                                  () => settingsBox.put('blockExplore', val));
                              _updateNativePrefs();
                            },
                    ),
                    SwitchListTile(
                      title: const Text("Block Stories"),
                      subtitle: const Text("Prevent viewing Instagram Stories"),
                      value: settingsBox.get('blockStories',
                          defaultValue: false) as bool,
                      onChanged: isBlocked
                          ? null
                          : (val) {
                              setSheetState(() {
                                settingsBox.put('blockStories', val);
                                setState(() {});
                              });
                              _updateNativePrefs();
                            },
                    ),
                    SwitchListTile(
                      title: const Text("Block Feed"),
                      subtitle: const Text("Prevent accessing the main feed"),
                      value: settingsBox.get('blockFeed', defaultValue: false)
                          as bool,
                      onChanged: isBlocked
                          ? null
                          : (val) {
                              setSheetState(() {
                                settingsBox.put('blockFeed', val);
                                setState(() {});
                              });
                              _updateNativePrefs();
                            },
                    ),
                    SwitchListTile(
                      title: const Text("Block Live"),
                      subtitle:
                          const Text("Prevent joining Instagram Live sessions"),
                      value: settingsBox.get('blockLive', defaultValue: false)
                          as bool,
                      onChanged: isBlocked
                          ? null
                          : (val) {
                              setSheetState(() {
                                settingsBox.put('blockLive', val);
                                setState(() {});
                              });
                              _updateNativePrefs();
                            },
                    ),
                  ],
                  if (app.packageName.contains("youtube")) ...[
                    const Divider(),
                    const Text("Content Blocks",
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold)),
                    SwitchListTile(
                      title: const Text("Block Shorts"),
                      subtitle: const Text("Prevent access to YouTube Shorts"),
                      value: blockShorts,
                      onChanged: isBlocked
                          ? null
                          : (val) {
                              setSheetState(
                                  () => settingsBox.put('blockShorts', val));
                              _updateNativePrefs();
                            },
                    ),
                    SwitchListTile(
                      title: const Text("Block Home Feed"),
                      subtitle:
                          const Text("Prevent accessing YouTube home feed"),
                      value: settingsBox.get('blockHomeFeed',
                          defaultValue: false) as bool,
                      onChanged: isBlocked
                          ? null
                          : (val) {
                              setSheetState(() {
                                settingsBox.put('blockHomeFeed', val);
                                setState(() {});
                              });
                              _updateNativePrefs();
                            },
                    ),
                    SwitchListTile(
                      title: const Text("Block Trending"),
                      subtitle: const Text("Prevent viewing trending videos"),
                      value: settingsBox.get('blockTrending',
                          defaultValue: false) as bool,
                      onChanged: isBlocked
                          ? null
                          : (val) {
                              setSheetState(() {
                                settingsBox.put('blockTrending', val);
                                setState(() {});
                              });
                              _updateNativePrefs();
                            },
                    ),
                    SwitchListTile(
                      title: const Text("Block Subscriptions"),
                      subtitle:
                          const Text("Prevent viewing subscribed channels"),
                      value: settingsBox.get('blockSubscriptions',
                          defaultValue: false) as bool,
                      onChanged: isBlocked
                          ? null
                          : (val) {
                              setSheetState(() {
                                settingsBox.put('blockSubscriptions', val);
                                setState(() {});
                              });
                              _updateNativePrefs();
                            },
                    ),
                  ],
                  if (app.packageName.contains("facebook")) ...[
                    const Divider(),
                    const Text("Content Blocks",
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold)),
                    SwitchListTile(
                      title: const Text("Block Reels"),
                      subtitle: const Text("Prevent access to Facebook Reels"),
                      value: settingsBox.get('fbBlockReels',
                          defaultValue: false) as bool,
                      onChanged: isBlocked
                          ? null
                          : (val) {
                              setSheetState(() {
                                settingsBox.put('fbBlockReels', val);
                                setState(() {});
                              });
                              _updateNativePrefs();
                            },
                    ),
                    SwitchListTile(
                      title: const Text("Block Watch"),
                      subtitle: const Text("Prevent access to Facebook Watch"),
                      value: settingsBox.get('fbBlockWatch',
                          defaultValue: false) as bool,
                      onChanged: isBlocked
                          ? null
                          : (val) {
                              setSheetState(() {
                                settingsBox.put('fbBlockWatch', val);
                                setState(() {});
                              });
                              _updateNativePrefs();
                            },
                    ),
                    SwitchListTile(
                      title: const Text("Block Marketplace"),
                      subtitle: const Text("Prevent access to Marketplace"),
                      value: settingsBox.get('fbBlockMarketplace',
                          defaultValue: false) as bool,
                      onChanged: isBlocked
                          ? null
                          : (val) {
                              setSheetState(() {
                                settingsBox.put('fbBlockMarketplace', val);
                                setState(() {});
                              });
                              _updateNativePrefs();
                            },
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBlockReasonDialog(AppInfo app) {
    String selectedReason = 'Study';
    int selectedMinutes = 30;
    int selectedDays = 7;

    final List<String> reasons = [
      '📚 Study',
      '💼 Work',
      '😴 Sleep',
      '💪 Health',
      '🎯 Other',
    ];

    final List<Map<String, dynamic>> timeOptions = [
      {'label': '15 minutes', 'value': 15},
      {'label': '30 minutes', 'value': 30},
      {'label': '1 hour', 'value': 60},
      {'label': '2 hours', 'value': 120},
      {'label': 'No limit', 'value': 0},
    ];

    final List<Map<String, dynamic>> dayOptions = [
      {'label': 'Every day', 'value': 7},
      {'label': 'Weekdays only', 'value': 5},
      {'label': 'Weekends only', 'value': 2},
      {'label': 'Today only', 'value': 1},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🚫', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Why are you blocking ${app.name}?',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Reason selection
                  const Text('Reason',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: reasons.map((reason) {
                      final isSelected = selectedReason == reason;
                      return GestureDetector(
                        onTap: () =>
                            setSheetState(() => selectedReason = reason),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.green
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.green
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            reason,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Daily limit
                  const Text('Daily time allowed',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: timeOptions.map((option) {
                      final isSelected = selectedMinutes == option['value'];
                      return GestureDetector(
                        onTap: () => setSheetState(
                            () => selectedMinutes = option['value']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.blue : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            option['label'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Days per week
                  const Text('Block on which days',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: dayOptions.map((option) {
                      final isSelected = selectedDays == option['value'];
                      return GestureDetector(
                        onTap: () =>
                            setSheetState(() => selectedDays = option['value']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.purple
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.purple
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            option['label'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Save to Hive
                        blockedAppsBox.put(app.packageName, true);
                        final settingsMap = {
                          'packageName': app.packageName,
                          'reason': selectedReason,
                          'dailyLimitMinutes': selectedMinutes,
                          'daysPerWeek': selectedDays,
                        };
                        settingsBox.put(
                            'block_settings_${app.packageName}', settingsMap);
                        setState(() {});
                        _updateNativePrefs();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Block App',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAppList(List<AppInfo> apps, {bool isActiveBlocksTab = false}) {
    if (apps.isEmpty) {
      return Center(
        child: Text(
          isActiveBlocksTab
              ? "No apps are currently blocked."
              : "No apps found.",
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        final isBlocked =
            blockedAppsBox.get(app.packageName, defaultValue: false) as bool;
        final iconWidget = _AppIcon(packageName: app.packageName);

        if (isActiveBlocksTab) {
          return ListTile(
            leading: iconWidget,
            title: Text(app.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle:
                Text(app.packageName, style: const TextStyle(fontSize: 12)),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Colors.green),
              onPressed: () => _showEditBlockSheet(app),
            ),
            onTap: () => _showEditBlockSheet(app),
          );
        } else {
          return CheckboxListTile(
            secondary: iconWidget,
            title: Text(app.name),
            subtitle:
                Text(app.packageName, style: const TextStyle(fontSize: 12)),
            value: isBlocked,
            onChanged: (bool? value) {
              if (value == true) {
                _showBlockReasonDialog(app);
              } else {
                setState(() {
                  blockedAppsBox.delete(app.packageName);
                });
                _updateNativePrefs();
              }
            },
          );
        }
      },
    );
  }

  void _showEditBlockSheet(AppInfo app) {
    final existing = settingsBox.get(
      'block_settings_${app.packageName}',
      defaultValue: null,
    );

    String selectedReason = existing?['reason'] ?? '📚 Study';
    int selectedMinutes = existing?['dailyLimitMinutes'] ?? 30;
    int selectedDays = existing?['daysPerWeek'] ?? 7;

    final List<String> reasons = [
      '📚 Study',
      '💼 Work',
      '😴 Sleep',
      '💪 Health',
      '🎯 Other',
    ];

    final List<Map<String, dynamic>> timeOptions = [
      {'label': '15 minutes', 'value': 15},
      {'label': '30 minutes', 'value': 30},
      {'label': '1 hour', 'value': 60},
      {'label': '2 hours', 'value': 120},
      {'label': 'No limit', 'value': 0},
    ];

    final List<Map<String, dynamic>> dayOptions = [
      {'label': 'Every day', 'value': 7},
      {'label': 'Weekdays only', 'value': 5},
      {'label': 'Weekends only', 'value': 2},
      {'label': 'Today only', 'value': 1},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('✏️', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Edit block for ${app.name}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Reason',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: reasons.map((reason) {
                      final isSelected = selectedReason == reason;
                      return GestureDetector(
                        onTap: () =>
                            setSheetState(() => selectedReason = reason),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.green
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.green
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(reason,
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('Daily time allowed',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: timeOptions.map((option) {
                      final isSelected = selectedMinutes == option['value'];
                      return GestureDetector(
                        onTap: () => setSheetState(
                            () => selectedMinutes = option['value']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.blue : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(option['label'],
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('Block on which days',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: dayOptions.map((option) {
                      final isSelected = selectedDays == option['value'];
                      return GestureDetector(
                        onTap: () =>
                            setSheetState(() => selectedDays = option['value']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.purple
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.purple
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(option['label'],
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final settingsMap = {
                              'packageName': app.packageName,
                              'reason': selectedReason,
                              'dailyLimitMinutes': selectedMinutes,
                              'daysPerWeek': selectedDays,
                            };
                            settingsBox.put('block_settings_${app.packageName}',
                                settingsMap);
                            setState(() {});
                            _updateNativePrefs();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Save Changes',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            blockedAppsBox.delete(app.packageName);
                            settingsBox
                                .delete('block_settings_${app.packageName}');
                          });
                          _updateNativePrefs();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Unblock',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('App Management')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Unable to load installed apps',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  loadError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      loadError = null;
                    });
                    _loadApps();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final activeApps = installedApps
        .where((app) =>
            blockedAppsBox.get(app.packageName, defaultValue: false) == true)
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('App Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: "All Apps"),
              Tab(text: "Active Blocks"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAppList(installedApps, isActiveBlocksTab: false),
            _buildAppList(activeApps, isActiveBlocksTab: true),
          ],
        ),
      ),
    );
  }
}

class _AppIcon extends StatefulWidget {
  const _AppIcon({required this.packageName});

  final String packageName;

  @override
  State<_AppIcon> createState() => _AppIconState();
}

class _AppIconState extends State<_AppIcon> {
  static final Map<String, String?> _iconCache = {};

  late Future<String?> _iconFuture;

  @override
  void initState() {
    super.initState();
    _iconFuture = _loadIcon();
  }

  @override
  void didUpdateWidget(covariant _AppIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageName != widget.packageName) {
      _iconFuture = _loadIcon();
    }
  }

  Future<String?> _loadIcon() async {
    if (_iconCache.containsKey(widget.packageName)) {
      return _iconCache[widget.packageName];
    }

    final iconBase64 = await AppService.getAppIcon(widget.packageName);
    _iconCache[widget.packageName] = iconBase64;
    return iconBase64;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: FutureBuilder<String?>(
        future: _iconFuture,
        builder: (context, snapshot) {
          final iconBase64 = snapshot.data;
          if (iconBase64 == null || iconBase64.isEmpty) {
            return const Icon(Icons.android, size: 40);
          }

          try {
            final bytes = base64Decode(iconBase64);
            return Image.memory(bytes,
                width: 40, height: 40, fit: BoxFit.contain);
          } catch (e) {
            return const Icon(Icons.android, size: 40);
          }
        },
      ),
    );
  }
}
