import 'fake_auth_service.dart';

class User {
  final String uid;
  final String? email;

  User({required this.uid, this.email});
}

class FirebaseAuth {
  static final FirebaseAuth _instance = FirebaseAuth._internal();

  factory FirebaseAuth() {
    return _instance;
  }

  FirebaseAuth._internal();

  static FirebaseAuth get instance => _instance;

  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Mock sign in
    _currentUser = User(uid: 'mock_user_id', email: email);
  }

  Future<void> signOut() async {
    _currentUser = null;
  }
}