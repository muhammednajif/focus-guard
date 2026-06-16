import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import 'dart:math';

class FocusSessionScreen extends StatefulWidget {
  final int durationMinutes;
  const FocusSessionScreen({super.key, required this.durationMinutes});

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen> {
  late int remainingSeconds;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.durationMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        t.cancel();
        _sessionComplete();
      }
    });
  }

  void _sessionComplete() async {
    final box = await Hive.openBox('sessionHistory');
    box.add({
      'timestamp': DateTime.now().toIso8601String(),
      'durationMinutes': widget.durationMinutes,
      'completed': true,
    });

    // Award Focus Coins
    final profileBox = await Hive.openBox('userProfile');
    int currentCoins = profileBox.get('focusCoins', defaultValue: 0) as int;
    int earnedCoins = widget.durationMinutes;
    profileBox.put('focusCoins', currentCoins + earnedCoins);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Session Complete! \u{1F389}"),
        content: Text(
            "You successfully maintained your focus.\n\nYou earned +$earnedCoins Focus Coins!"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Finish"),
          ),
        ],
      ),
    );
  }

  void _tryExit() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final random = Random();
        final a = random.nextInt(20) + 10;
        final b = random.nextInt(20) + 10;
        final ans = a + b;
        final ctrl = TextEditingController();
        final messenger = ScaffoldMessenger.of(context);
        final dialogNavigator = Navigator.of(ctx);
        final pageNavigator = Navigator.of(context);

        return AlertDialog(
          title: const Text("Break Focus?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Solve this to exit early:"),
              const SizedBox(height: 10),
              Text("$a + $b = ?",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: "Enter answer"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => dialogNavigator.pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (ctrl.text == ans.toString()) {
                  timer?.cancel();

                  final box = await Hive.openBox('sessionHistory');
                  int elapsedSeconds =
                      (widget.durationMinutes * 60) - remainingSeconds;
                  box.add({
                    'timestamp': DateTime.now().toIso8601String(),
                    'durationMinutes': (elapsedSeconds / 60).round(),
                    'completed': false,
                  });

                  if (!mounted) return;
                  dialogNavigator.pop();
                  pageNavigator.pop(); // exit session
                } else {
                  messenger.showSnackBar(const SnackBar(
                      content: Text("Incorrect! Keep focusing.")));
                  dialogNavigator.pop();
                }
              },
              child: const Text("Exit Session"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // PopScope prevents back button
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _tryExit();
      },
      child: Scaffold(
        backgroundColor: Colors.teal.shade900,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.self_improvement,
                  size: 100, color: Colors.white),
              const SizedBox(height: 20),
              const Text("Deep Focus Active",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Text(
                "${(remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}",
                style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w200,
                    color: Colors.white),
              ),
              const SizedBox(height: 50),
              TextButton(
                onPressed: _tryExit,
                child: const Text("Give Up",
                    style: TextStyle(color: Colors.white54)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
