import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BlockScreen extends StatefulWidget {
  const BlockScreen({super.key});

  @override
  State<BlockScreen> createState() => _BlockScreenState();
}

class _BlockScreenState extends State<BlockScreen> {
  int delaySeconds = 15;
  Timer? timer;
  String? blockedPackage;
  bool _hasLoggedCraving = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _logCraving();
  }

  Future<void> _logCraving() async {
    try {
      final String? pkg = await const MethodChannel('focus_guard/block').invokeMethod('getBlockedPackage');
      if (pkg != null && !_hasLoggedCraving) {
        _hasLoggedCraving = true;
        setState(() {
          blockedPackage = pkg;
        });
        final box = await Hive.openBox('cravingHistory');
        box.add({
          'timestamp': DateTime.now().toIso8601String(),
          'package': pkg,
          'overridden': false,
        });
      }
    } catch (e) {
      // ignore
    }
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (delaySeconds > 0) {
        setState(() => delaySeconds--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _unlock() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text("Entry Tax"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Why do you want to open this app right now?"),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Enter at least 10 characters...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().length >= 10) {
                  // Mark craving as overridden
                  try {
                    final box = await Hive.openBox('cravingHistory');
                    if (box.isNotEmpty) {
                      final last = box.getAt(box.length - 1) as Map<dynamic, dynamic>;
                      last['overridden'] = true;
                      last['reason'] = controller.text;
                      box.putAt(box.length - 1, last);
                    }
                  } catch (e) {
                    // ignore
                  }
                  
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  const MethodChannel('focus_guard/block').invokeMethod('unlock');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please write a thoughtful reason (min 10 chars).")));
                }
              },
              child: const Text("Unlock"),
            ),
          ],
        );
      },
    );
  }

  void _chooseAlternative(String name) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Great choice! Starting $name...")));
    const MethodChannel('focus_guard/block').invokeMethod('unlock');
    // In a real app, this would redirect to a breathing exercise screen, etc.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.95),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text(
                "Mindful Delay",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                "Take a deep breath. Do you really need to open this app right now?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 40),
              
              // Healthy Alternatives
              const Text("Try a healthy alternative:", style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ActionChip(label: const Text("Deep Breathing"), avatar: const Icon(Icons.air), onPressed: () => _chooseAlternative("Breathing")),
                  ActionChip(label: const Text("Drink Water"), avatar: const Icon(Icons.water_drop), onPressed: () => _chooseAlternative("Water")),
                  ActionChip(label: const Text("Stretch"), avatar: const Icon(Icons.accessibility_new), onPressed: () => _chooseAlternative("Stretch")),
                ],
              ),
              
              const Spacer(),
              
              if (delaySeconds > 0)
                Text(
                  "Unlock available in $delaySeconds s",
                  style: const TextStyle(color: Colors.white54, fontSize: 16),
                )
              else
                ElevatedButton(
                  onPressed: _unlock,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                  ),
                  child: const Text('I still want to open it'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
