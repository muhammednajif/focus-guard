import 'package:flutter/material.dart';
import 'package:focus_guard/screens/home_screen.dart';
import 'package:focus_guard/screens/apps_screen.dart';
import 'package:focus_guard/screens/schedules_screen.dart';
import 'package:focus_guard/screens/statistics_screen.dart';
import 'package:focus_guard/screens/settings_screen.dart';
import 'package:focus_guard/services/blocking_sync_service.dart';
import 'package:focus_guard/theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:focus_guard/widgets/block_screen.dart';
import 'package:focus_guard/screens/onboarding_screen.dart';

// TODO(Phase-2): Re-add Firebase.initializeApp() and Workmanager().initialize()
// when firebase_core, firebase_auth, and workmanager are restored to pubspec.yaml.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await BlockingSyncService.syncHiveStateToNative();
  final settingsBox = await Hive.openBox('settings');
  final onboardingComplete =
      settingsBox.get('onboarding_complete', defaultValue: false) as bool;
  runApp(MyApp(showOnboarding: !onboardingComplete));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: {
        '/block': (context) => const BlockScreen(),
        '/home': (context) => const MainScreen(),
      },
      home: showOnboarding ? const OnboardingScreen() : const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int currentIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    AppsScreen(),
    SchedulesScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      BlockingSyncService.syncHiveStateToNative();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Focus Guard')),
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Apps'),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Stats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
