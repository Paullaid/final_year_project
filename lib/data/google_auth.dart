// google_auth.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A service class that handles Google Authentication using Firebase.
class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void>? _googleSignInInitialization;

  Future<void> _ensureGoogleSignInInitialized() async {
    _googleSignInInitialization ??= GoogleSignIn.instance.initialize();
    await _googleSignInInitialization;
  }

  /// Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Returns the currently signed-in user, if any
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Signs in a user using Google Sign-In and Firebase Authentication.
  ///
  /// **Web:** Uses [FirebaseAuth.signInWithRedirect] (not popup). Popup-based
  /// [signInWithPopup] often hits Google's `401 … malformed` in Chrome when
  /// third-party cookies / FedCM block the helper iframe, or when OAuth origins
  /// do not match. After redirect, call [FirebaseAuth.getRedirectResult] early
  /// in app startup (see `main.dart`).
  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      try {
        final GoogleAuthProvider provider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile');
        await _auth.signInWithRedirect(provider);
        // Browser navigates away; credential arrives on next load via
        // [getRedirectResult].
        return null;
      } on FirebaseAuthException catch (e) {
        debugPrint('FirebaseAuthException (Google web redirect): ${e.message}');
        return null;
      } catch (e) {
        debugPrint('Unknown error during Google web redirect: $e');
        return null;
      }
    }

    try {
      await _ensureGoogleSignInInitialized();

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate(
        scopeHint: const <String>['email', 'profile'],
      );

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      debugPrint('User signed in with Google: ${userCredential.user?.email}');
      return userCredential;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        debugPrint('Google sign-in aborted by user');
        return null;
      }
      debugPrint('GoogleSignInException: ${e.description}');
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Unknown error during Google sign-in: $e');
      return null;
    }
  }

  /// Signs out the current user from both Firebase and Google
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _ensureGoogleSignInInitialized();
        await GoogleSignIn.instance.signOut();
      }
      await _auth.signOut();

      debugPrint('User signed out successfully');
    } catch (e) {
      debugPrint('Error during sign out: $e');
    }
  }
}
