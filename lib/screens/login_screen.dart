import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Focus Guard', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                await AuthService().signInAnonymously();
              },
              child: const Text('Continue as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}
