import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isLoggedIn => _auth.currentUser != null;
  String? get uid => _auth.currentUser?.uid;

  // ─── Google Sign-In ──────────────────────────────────────────────────────
  Future<User?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    await _ensureUserDoc(result.user);
    return result.user;
  }

  // ─── Apple Sign-In ───────────────────────────────────────────────────────
  Future<User?> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    final result = await _auth.signInWithCredential(oauthCredential);
    // Apple only sends name on first sign-in
    if (result.additionalUserInfo?.isNewUser == true) {
      final fullName = [
        appleCredential.givenName,
        appleCredential.familyName,
      ].where((s) => s != null && s.isNotEmpty).join(' ');
      if (fullName.isNotEmpty) {
        await result.user?.updateDisplayName(fullName);
      }
    }
    await _ensureUserDoc(result.user);
    return result.user;
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ─── Firestore: saved tweets ─────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> _savedRef(String uid) =>
      _db.collection('users').doc(uid).collection('saved_tweets');

  Future<void> saveTweet(Map<String, dynamic> tweetData) async {
    final id = _auth.currentUser?.uid;
    if (id == null) return;
    final tweetId = tweetData['id']?.toString() ?? '';
    if (tweetId.isEmpty) return;
    await _savedRef(id).doc(tweetId).set({
      ...tweetData,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unsaveTweet(String tweetId) async {
    final id = _auth.currentUser?.uid;
    if (id == null) return;
    await _savedRef(id).doc(tweetId).delete();
  }

  Future<bool> isTweetSaved(String tweetId) async {
    final id = _auth.currentUser?.uid;
    if (id == null) return false;
    final doc = await _savedRef(id).doc(tweetId).get();
    return doc.exists;
  }

  Stream<List<Map<String, dynamic>>> savedTweetsStream() {
    final id = _auth.currentUser?.uid;
    if (id == null) return const Stream.empty();
    return _savedRef(id)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  // ─── User doc ────────────────────────────────────────────────────────────
  Future<void> _ensureUserDoc(User? user) async {
    if (user == null) return;
    final ref = _db.collection('users').doc(user.uid);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'uid': user.uid,
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  bool get isAppleAvailable => Platform.isIOS || Platform.isMacOS;
}
