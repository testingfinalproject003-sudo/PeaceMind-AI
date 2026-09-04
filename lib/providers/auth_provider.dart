import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
// import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import 'routine_provider.dart';
import 'package:flutter/material.dart';
import '../screens/auth_screen.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({this.routineProvider}) {
    // Firebase session bahar se change ho (jaise signOut) to
    // provider state automatically sync ho jaye.
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RoutineProvider? routineProvider;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _onboardingCompleted = false;

  UserModel? get currentUser => _currentUser;

  String get userName {
    final name = _currentUser?.name.trim();

    if (name == null || name.isEmpty) {
      return 'Friend';
    }

    return name;
  }

  bool get isLoggedIn => _currentUser != null;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get onboardingCompleted => _onboardingCompleted;

  void _onAuthStateChanged(fb_auth.User? user) {
    // Sign-out Firebase side se hua ho to local state clear karo.
    if (user == null && _currentUser != null) {
      _currentUser = null;
      _onboardingCompleted = false;
      routineProvider?.bindUser(null);
      notifyListeners();
    }
  }

  /// App start hote hi call hota hai. Dekhta hai ke Firebase mein pehle se
  /// koi session saved hai ya nahi (Firebase khud session persist karta hai).
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fbUser = _auth.currentUser;

      if (fbUser != null) {
        // Parallel: user doc (network) + onboarding flag (local prefs)
        // run together — sequential awaits ek full round-trip slow theke.
        await Future.wait([
          _fetchOrCreateUserDoc(fbUser.uid, fbUser.email ?? ''),
          _loadOnboardingFlag(fbUser.uid),
        ]);
        await routineProvider?.bindUser(fbUser.uid);
      } else {
        _currentUser = null;
        _onboardingCompleted = false;
        await routineProvider?.bindUser(null);
      }
    } catch (e) {
      debugPrint('AuthProvider loadUser error: $e');
      _currentUser = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadOnboardingFlag(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _onboardingCompleted =
          prefs.getBool('onboarding_completed_$uid') ?? false;
    } catch (e) {
      debugPrint('AuthProvider onboarding flag error: $e');
      _onboardingCompleted = false;
    }
  }

  /// OnboardingScreen final page par ye call karta hai.
  /// Flag save hota hai aur AuthGate turant HomeScreen dikha deta hai.
  Future<void> completeOnboarding() async {
    final uid = _currentUser?.uid;
    if (uid == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed_$uid', true);
    } catch (e) {
      debugPrint('AuthProvider completeOnboarding error: $e');
    }
    _onboardingCompleted = true;
    notifyListeners();
  }

  /// Firestore se user ka document uthata hai. Agar exist nahi karta
  /// (bohot rare case — jaise doc manually delete ho gaya ho) to naya bana deta hai.
  Future<void> _fetchOrCreateUserDoc(String uid, String email) async {
    final docRef = _firestore.collection('users').doc(uid);
    final snapshot = await docRef.get();

    final firebaseUser = _auth.currentUser;

    if (snapshot.exists && snapshot.data() != null) {
      final data = snapshot.data()!;

      final firestoreName = (data['name'] ?? '').toString().trim();

      final firebaseName = (firebaseUser?.displayName ?? '').trim();

      final finalName = firestoreName.isNotEmpty ? firestoreName : firebaseName;

      _currentUser = UserModel(
        uid: uid,
        name: finalName,
        email: (data['email'] ?? email).toString(),
        mood: (data['mood'] ?? '🙂').toString(),
        routineCount: data['routineCount'] is int
            ? data['routineCount'] as int
            : 0,
        taskCount: data['taskCount'] is int ? data['taskCount'] as int : 0,
      );

      // Agar Firestore mein name missing tha,
      // Firebase name ko Firestore mein save kar do.
      if (firestoreName.isEmpty && finalName.isNotEmpty) {
        await docRef.set({
          'name': finalName,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } else {
      final firebaseName = (firebaseUser?.displayName ?? '').trim();

      final newUser = UserModel(uid: uid, name: firebaseName, email: email);

      await docRef.set({
        ...newUser.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _currentUser = newUser;
    }
  }

  /// Real Firebase email/password sign-in.
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final fbUser = credential.user;
      if (fbUser == null) {
        throw fb_auth.FirebaseAuthException(code: 'unknown');
      }

      await _fetchOrCreateUserDoc(fbUser.uid, fbUser.email ?? '');
      await _loadOnboardingFlag(fbUser.uid);
      await routineProvider?.bindUser(fbUser.uid);

      _isLoading = false;
      notifyListeners();
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('AuthProvider login error: $e');
      _errorMessage = 'Something went wrong. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Real Firebase email/password sign-up. Firestore mein naya user
  /// document bhi turant create ho jata hai (name ke sath).
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final fbUser = credential.user;

      if (fbUser == null) {
        throw fb_auth.FirebaseAuthException(code: 'unknown');
      }

      final cleanName = name.trim();

      // Firebase Auth profile
      await fbUser.updateDisplayName(cleanName);

      // Firestore profile
      final newUser = UserModel(
        uid: fbUser.uid,
        name: cleanName,
        email: fbUser.email ?? email.trim(),
      );

      await _firestore.collection('users').doc(fbUser.uid).set({
        ...newUser.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _currentUser = newUser;

      // Naya user — onboarding abhi complete nahi hua
      await _loadOnboardingFlag(fbUser.uid);
      await routineProvider?.bindUser(fbUser.uid);

      _isLoading = false;
      notifyListeners();
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('AuthProvider signUp error: $e');
      _errorMessage = 'Something went wrong. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sirf name field update karta hai — Firestore mein merge hoti hai,
  /// baaki fields (mood, routineCount, taskCount) untouched rehte hain.
  Future<void> updateName(String name) async {
    final cleanName = name.trim();

    if (cleanName.isEmpty || _currentUser == null) {
      return;
    }

    try {
      final firebaseUser = _auth.currentUser;

      // Firebase Authentication profile
      if (firebaseUser != null) {
        await firebaseUser.updateDisplayName(cleanName);
      }

      // Firestore profile
      await _firestore.collection('users').doc(_currentUser!.uid).set({
        'name': cleanName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Local provider state
      _currentUser = _currentUser!.copyWith(name: cleanName);

      notifyListeners();
    } catch (e) {
      debugPrint('AuthProvider updateName error: $e');
    }
  }

  /// Logout — Firebase signOut ke baad local state hamesha clear
  /// hota hai (chahe signOut error de de). AuthGate khud AuthScreen
  /// dikha deta hai, kisi manual navigation ki zaroorat nahi.
  Future<void> logout(BuildContext context) async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('AuthProvider logout error: $e');
    }

    _currentUser = null;
    _onboardingCompleted = false;
    await routineProvider?.bindUser(null);
    notifyListeners();

    // ✅ mounted check - async gap safe
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  String _mapAuthError(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
