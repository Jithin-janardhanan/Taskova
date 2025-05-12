import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:taskova/Model/api_config.dart';
import 'package:taskova/Model/profile_status.dart';
import 'package:taskova/auth/profile_page.dart';
import 'package:taskova/auth/registration.dart';
import 'package:taskova/view/bottom_nav.dart';
import 'package:provider/provider.dart';
import '../language/language_provider.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // This function handles the Google sign-in flow
  Future<void> signInWithGoogle({
    required BuildContext context,
    required Function(String) showSuccessSnackbar,
    required Function(String) showErrorSnackbar,
    required Function(bool) setLoadingState,
  }) async {
    setLoadingState(true);

    try {
      // Sign out first to ensure the account picker shows every time
      await _googleSignIn.signOut();

      // Trigger the authentication flow with account selection
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in process
        setLoadingState(false);
        return;
      }

      // Get authentication token
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        setLoadingState(false);
        showErrorSnackbar(Provider.of<AppLanguage>(context, listen: false)
            .get('authentication_failed'));
        return;
      }

      // Send the token to your backend
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/social_auth/google/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'auth_token': idToken,
        }),
      );

      setLoadingState(false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Authentication successful
        Map<String, dynamic> responseData = jsonDecode(response.body);
        print("Google login response: $responseData"); // Log response

        // Extract tokens from nested auth_token.tokens
        String accessToken = 
            responseData['auth_token']?['tokens']?['access'] ?? "";
        String refreshToken = 
            responseData['auth_token']?['tokens']?['refresh'] ?? "";
        String name = responseData['auth_token']?['username'] ?? 
            googleUser.displayName ?? 
            "User";
        bool isNewUser = responseData['is_new_user'] ?? false;

        await _saveTokens(accessToken, refreshToken, googleUser.email, name);

        final appLanguage = Provider.of<AppLanguage>(context, listen: false);
        showSuccessSnackbar(await appLanguage.translate(
            "Google login successful!", appLanguage.currentLanguage));

        if (isNewUser) {
          // If email is not already registered, navigate to registration
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Registration()),
            (Route<dynamic> route) => false,
          );
        } else {
          // If email is already registered, check profile status and navigate
          await checkProfileStatusAndNavigate(
            context: context,
            profileFillingPage: ProfileDetailFillingPage(),
            homePage: HomePageWithBottomNav(),
          );
        }
      } else {
        // Authentication failed
        Map<String, dynamic> errorData = jsonDecode(response.body);
        String errorMessage = errorData['detail'] ??
            Provider.of<AppLanguage>(context, listen: false)
                .get('login_failed');
        showErrorSnackbar(errorMessage);
      }
    } catch (e) {
      setLoadingState(false);
      print("Google login error: $e");
      showErrorSnackbar(Provider.of<AppLanguage>(context, listen: false)
          .get('connection_error'));
    }
  }

  // Helper method to save authentication tokens
  Future<void> _saveTokens(String accessToken, String refreshToken, String email,
      String name) async {
    final prefs = await SharedPreferences.getInstance();
    if (accessToken.isEmpty || refreshToken.isEmpty) {
      print("Error: Attempting to save empty tokens");
      return;
    }
    print(
        "Saving tokens: access_token=$accessToken, refresh_token=$refreshToken, email=$email, name=$name");
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    await prefs.setString('user_email', email);
    await prefs.setString('user_name', name);
    print("Saved access_token: ${prefs.getString('access_token')}");
  }
}