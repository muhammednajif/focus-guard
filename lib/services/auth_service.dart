// TODO(Phase-2): Replace stub with real Firebase auth when firebase_core,
// firebase_auth, and flutter_secure_storage are re-added to pubspec.yaml.

class AuthService {
  // Stub: always returns a guest "user" string so the UI can navigate forward.
  static Stream<String?> get authStateChanges async* {
    yield 'guest';
  }

  Future<void> signInAnonymously() async {
    // No-op stub — skips Firebase entirely for now.
  }

  Future<void> signOut() async {
    // No-op stub.
  }
}
