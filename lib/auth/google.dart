
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<UserCredential?> signInWithGoogle() async {
  try {
    // Configure Google Sign-In for Android
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      // No need to specify clientId for Android - it uses google-services.json
    );

    // Start the sign-in process
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null; // User cancelled

    // Get authentication details
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create Firebase credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    print('Signed in: ${userCredential.user?.displayName}');
    log('$userCredential', name: 'jithin');
    return userCredential;
  } catch (e) {
    print('Error during Google Sign-In: $e');
    // Log more detailed error information
    if (e is FirebaseAuthException) {
      print('Firebase Auth Error Code: ${e.code}');
      print('Firebase Auth Error Message: ${e.message}');
    }
    rethrow; // Rethrow to handle the error in the UI layer
  }
}

// For backend communication, use this separate function
Future<String?> getFirebaseIdToken() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    // Force refresh the token to ensure it's valid
    return await user.getIdToken(true);
  } catch (e) {
    print('Error getting Firebase ID token: $e');
    return null;
  }
}
