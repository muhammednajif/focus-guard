import 'package:flutter/material.dart';
import 'package:focus_guard/screens/dashboard_screen.dart';
import 'package:focus_guard/screens/journey_screen.dart';
import 'package:focus_guard/screens/apps_screen.dart';
import 'package:focus_guard/screens/schedules_screen.dart';
import 'package:focus_guard/screens/statistics_screen.dart';
import 'package:focus_guard/screens/settings_screen.dart';
import 'package:focus_guard/screens/fidget_spinner_screen.dart';
import 'package:focus_guard/services/blocking_sync_service.dart';
import 'package:focus_guard/theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:focus_guard/widgets/block_screen.dart';
import 'package:focus_guard/screens/onboarding_screen.dart';

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
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    AppsScreen(),
    JourneyScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  final List<String> _titles = const [
    'Dashboard',
    'Blocked Apps',
    'Your Journey',
    'Progress Snapshot',
    'Settings'
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

  void _onTabTapped(int index) {
      setState(() {
        _currentIndex = index;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FidgetSpinnerScreen()),
          );
        },
        tooltip: 'Craving Tool',
        child: const Icon(Icons.touch_app_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Apps'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Journey'),
            BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Stats'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
