// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:lottie/lottie.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:taskova/Model/api_config.dart';
// import 'package:taskova/auth/profile_page.dart';
// import 'package:taskova/bottom_nav.dart';
// import 'package:taskova/colors.dart';
// import 'package:taskova/auth/forgot_password.dart';
// import 'package:taskova/home.dart';
// import 'package:taskova/language/language_selection_screen.dart';
// import 'package:taskova/otp.dart';
// import 'package:taskova/profile.dart';
// import 'package:taskova/validator.dart';
// import 'applelogi.dart';
// import '../language/language_provider.dart';
// import 'registration.dart';
// import 'package:http/http.dart' as http;

// class Login extends StatefulWidget {
//   const Login({Key? key}) : super(key: key);

//   @override
//   State<Login> createState() => _LoginState();
// }

// class _LoginState extends State<Login> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _passwordVisible = false;
//   bool _isLoading = false;

//   GoogleSignIn _googleSignIn = GoogleSignIn();

//   void googleLogin() async {
//     try {
//       var user = await _googleSignIn.signIn();
//       if (user != null) {
//         print('User logged in successfully');
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => Registration(
//                 // email: user.email,
//                 // name: user.displayName ?? "No Name",
//                 ),
//           ),
//         );
//       }
//     } catch (e) {
//       print("Google login failed: $e");
//     }
//   }

//   Future<void> saveTokens(String accessToken, String refreshToken, String email,
//       String name) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('access_token', accessToken);
//     await prefs.setString('refresh_token', refreshToken);
//     await prefs.setString('user_email', email);
//     await prefs.setString('user_name', name);
//   }

//   void showErrorSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red.shade700,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   void showSuccessSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green.shade700,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

// Future<void> loginUser() async {
//   if (_formKey.currentState!.validate()) {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // 1. First make the login request
//       final response = await http.post(
//         Uri.parse(ApiConfig.loginUrl),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'email': _emailController.text,
//           'password': _passwordController.text,
//         }),
//       );

//       if (response.statusCode == 200) {
//         // Login successful
//         Map<String, dynamic> responseData = jsonDecode(response.body);
//         print('Login successful: $responseData');

//         // Store tokens in SharedPreferences
//         String accessToken = responseData['access'] ?? "";
//         String refreshToken = responseData['refresh'] ?? "";
//         String name = responseData['name'] ?? "User";

//         await saveTokens(accessToken, refreshToken, _emailController.text, name);

//         // 2. Now check profile status
//         final profileResponse = await http.get(
//           Uri.parse(ApiConfig.profilestatsUrl),
//           headers: {
//             'Authorization': 'Bearer $accessToken',
//             'Content-Type': 'application/json',
//           },
//         );

//         if (profileResponse.statusCode == 200) {
//           final profileData = jsonDecode(profileResponse.body);
//           bool isProfileComplete = profileData['is_profile_complete'] ?? false;
//           bool isEmailVerified = profileData['is_email_verified'] ?? false;
//           print( 'Profile status email: $isEmailVerified +++++++++++++++++++++++++++++++++++++++++++++++++++++++');
//           // Check if email is verified

//           if (!isEmailVerified) {
//             // Email is not verified, navigate to OTP verification page
//             showSuccessSnackbar("Please verify your email");
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => OtpVerification(email: _emailController.text),
//               ),
//             );
//           } else {
//             // Email is verified, proceed with normal flow
//             showSuccessSnackbar("Login successful!");

//             // 3. Navigate based on profile completion status
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => isProfileComplete
//                     ? HomePageWithBottomNav()
//                     : ProfileDetailFillingPage(),
//               ),
//             );
//           }
//         } else {
//           // Handle profile status check error
//           showErrorSnackbar("Could not verify profile status");
//         }
//       } else {
//         // Login failed
//           // Extract 'is_email_verified' from response data
//           final responseData = jsonDecode(response.body);
//           bool isEmailVerified = responseData['is_email_verified'] ?? false;

//           if (!isEmailVerified) {
//             // Email is not verified, navigate to OTP verification page
//             showSuccessSnackbar("Please verify your email");
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => OtpVerification(email: _emailController.text),
//               ),
//             );
//           }
//         Map<String, dynamic> errorData = jsonDecode(response.body);
//         String errorMessage = errorData['detail'] ?? "Login failed. Please check your credentials.";

//         // Check if the error is due to unverified email
//         if (errorMessage.toLowerCase().contains("email") &&
//             errorMessage.toLowerCase().contains("verif")) {
//           // This suggests the error is related to email verification
//           print("Please verify your email address to login");
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => OtpVerification(email: _emailController.text),
//             ),
//           );
//         } else {
//           showErrorSnackbar(errorMessage);
//         }
//       }
//     } catch (e) {
//       print("Login error: $e");
//       showErrorSnackbar("Connection error. Please check your internet connection.");
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     final appLanguage = Provider.of<AppLanguage>(context);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 20),
//                   // Language switcher button
//                   Align(
//                     alignment: Alignment.topRight,
//                     child: TextButton.icon(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 const LanguageSelectionScreen(),
//                           ),
//                         );
//                       },
//                       icon: const Icon(Icons.language,
//                           color: AppColors.secondaryBlue),
//                       label: Text(
//                         appLanguage.get('change_language'),
//                         style: const TextStyle(color: AppColors.secondaryBlue),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   // App Logo
//                   Container(
//                     height: 100,
//                     width: 100,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Lottie.asset(
//                       'assets/login_lottie.json',
//                       height: 60,
//                       width: 60,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   // App name
//                   Text(
//                     appLanguage.get('app_name'),
//                     style: const TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primaryBlue,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   // Tagline
//                   Text(
//                     appLanguage.get('tagline'),
//                     style: const TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey,
//                     ),
//                   ),
//                   const SizedBox(height: 50),
//                   // Email field
//                   TextFormField(
//                     validator: validateEmail,
//                     controller: _emailController,
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: InputDecoration(
//                       hintText: appLanguage.get('email_hint'),
//                       prefixIcon: const Icon(
//                         Icons.email_outlined,
//                         color: AppColors.secondaryBlue,
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(
//                             color: AppColors.lightBlue, width: 1),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(
//                             color: AppColors.primaryBlue, width: 2),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   // Password field
//                   TextFormField(
//                     controller: _passwordController,
//                     obscureText: !_passwordVisible,
//                     decoration: InputDecoration(
//                       hintText: appLanguage.get('password_hint'),
//                       prefixIcon: const Icon(
//                         Icons.lock_outline,
//                         color: AppColors.secondaryBlue,
//                       ),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _passwordVisible
//                               ? Icons.visibility
//                               : Icons.visibility_off,
//                           color: AppColors.secondaryBlue,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _passwordVisible = !_passwordVisible;
//                           });
//                         },
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(
//                             color: AppColors.lightBlue, width: 1),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(
//                             color: AppColors.primaryBlue, width: 2),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   // Forgot password
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: TextButton(
//                       onPressed: () => navigateToForgotPasswordScreen(context),
//                       child: Text(
//                         appLanguage.get('forgot_password'),
//                         style: const TextStyle(
//                           color: AppColors.secondaryBlue,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   // Login button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 55,
//                     child: ElevatedButton(
//                       onPressed: _isLoading
//                           ? null
//                           : () {
//                               if (_formKey.currentState!.validate()) {
//                                 loginUser();
//                               }
//                             },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primaryBlue,
//                         foregroundColor: Colors.white,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: _isLoading
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : Text(
//                               appLanguage.get('login'),
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   // Or divider
//                   Row(
//                     children: [
//                       Expanded(child: Divider(color: Colors.grey[300])),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Text(
//                           appLanguage.get('or_continue_with'),
//                           style:
//                               TextStyle(color: Colors.grey[600], fontSize: 12),
//                         ),
//                       ),
//                       Expanded(child: Divider(color: Colors.grey[300])),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   // Social login buttons
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // Google login
//                       _socialLoginButton(
//                         onPressed: () {
//                           googleLogin();
//                         },
//                         icon: Icons.g_mobiledata,
//                         label: appLanguage.get('google'),
//                         backgroundColor: Colors.white,
//                         textColor: Colors.black87,
//                       ),
//                       const SizedBox(width: 16),
//                       // Apple login
//                       _socialLoginButton(
//                         onPressed: () {
//                           handleAppleSignIn;
//                         },
//                         icon: Icons.apple,
//                         label: appLanguage.get('apple'),
//                         backgroundColor: Colors.black,
//                         textColor: Colors.white,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 30),
//                   // Register link
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         appLanguage.get('dont_have_account'),
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => Registration(),
//                             ),
//                           );
//                         },
//                         child: Text(
//                           appLanguage.get('sign_up'),
//                           style: const TextStyle(
//                             color: AppColors.primaryBlue,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _socialLoginButton({
//     required VoidCallback onPressed,
//     required IconData icon,
//     required String label,
//     required Color backgroundColor,
//     required Color textColor,
//   }) {
//     return SizedBox(
//       width: 150,
//       height: 50,
//       child: ElevatedButton.icon(
//         onPressed: onPressed,
//         icon: Icon(icon, color: textColor),
//         label: Text(
//           label,
//           style: TextStyle(color: textColor),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: backgroundColor,
//           foregroundColor: textColor,
//           elevation: 0,
//           side: BorderSide(color: Colors.grey[300]!),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }
// }

// void navigateToForgotPasswordScreen(BuildContext context) {
//   Navigator.push(
//     context,
//     MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
//   );
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskova/Model/api_config.dart';
import 'package:taskova/Model/profile_status.dart';
import 'package:taskova/auth/profile_page.dart';
import 'package:taskova/Model/colors.dart';
import 'package:taskova/auth/forgot_password.dart';
import 'package:taskova/language/language_selection_screen.dart';
import 'package:taskova/Model/validator.dart';
import 'package:taskova/view/job_post.dart';
import 'applelogi.dart';
import '../language/language_provider.dart';
import 'registration.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;

  GoogleSignIn _googleSignIn = GoogleSignIn();

  void googleLogin() async {
    try {
      var user = await _googleSignIn.signIn();
      if (user != null) {
        print('User logged in successfully');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Registration(
                // email: user.email,
                // name: user.displayName ?? "No Name",
                ),
          ),
        );
      }
    } catch (e) {
      print("Google login failed: $e");
    }
  }

  Future<void> saveTokens(String accessToken, String refreshToken, String email,
      String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    await prefs.setString('user_email', email);
    await prefs.setString('user_name', name);
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse(ApiConfig.loginUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': _emailController.text,
            'password': _passwordController.text,
            'remeber_me': true,
          }),
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          // Login successful
          Map<String, dynamic> responseData = jsonDecode(response.body);
          print('Login successful: $responseData');

          // Store tokens in SharedPreferences
          String accessToken = responseData['access'] ?? "";
          String refreshToken = responseData['refresh'] ?? "";
          String name = responseData['name'] ?? "User";

          await saveTokens(
              accessToken, refreshToken, _emailController.text, name);

          final appLanguage = Provider.of<AppLanguage>(context, listen: false);
          showSuccessSnackbar(await appLanguage.translate(
              "Login successful!", appLanguage.currentLanguage));
          await checkProfileStatusAndNavigate(
            context: context,
            profileFillingPage: ProfileDetailFillingPage(),
            homePage:
                DriverJobPostingPage(businessId: 3), // Replace with your actual home page
          );
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => ProfileDetailFillingPage(),
          //   ),
          // );
        } else {
          // Login failed
          Map<String, dynamic> errorData = jsonDecode(response.body);
          String errorMessage = errorData['detail'] ??
              Provider.of<AppLanguage>(context, listen: false)
                  .get('login_failed');
          showErrorSnackbar(errorMessage);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print("Login error: $e");
        showErrorSnackbar(Provider.of<AppLanguage>(context, listen: false)
            .get('connection_error'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Language switcher button
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const LanguageSelectionScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.language,
                          color: AppColors.secondaryBlue),
                      label: Text(
                        appLanguage.get('change_language'),
                        style: const TextStyle(color: AppColors.secondaryBlue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // App Logo
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Lottie.asset(
                      'assets/login_lottie.json',
                      height: 60,
                      width: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // App name
                  Text(
                    appLanguage.get('app_name'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Tagline
                  Text(
                    appLanguage.get('tagline'),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Email field
                  TextFormField(
                    validator: validateEmail,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: appLanguage.get('email_hint'),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.secondaryBlue,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.lightBlue, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primaryBlue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      hintText: appLanguage.get('password_hint'),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.secondaryBlue,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.secondaryBlue,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.lightBlue, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primaryBlue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => navigateToForgotPasswordScreen(context),
                      child: Text(
                        appLanguage.get('forgot_password'),
                        style: const TextStyle(
                          color: AppColors.secondaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                loginUser();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              appLanguage.get('login'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Or divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          appLanguage.get('or_continue_with'),
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Social login buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google login
                      _socialLoginButton(
                        onPressed: () {
                          googleLogin();
                        },
                        icon: Icons.g_mobiledata,
                        label: appLanguage.get('google'),
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                      ),
                      const SizedBox(width: 16),
                      // Apple login
                      _socialLoginButton(
                        onPressed: () {
                          handleAppleSignIn;
                        },
                        icon: Icons.apple,
                        label: appLanguage.get('apple'),
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        appLanguage.get('dont_have_account'),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Registration(),
                            ),
                          );
                        },
                        child: Text(
                          appLanguage.get('sign_up'),
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialLoginButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return SizedBox(
      width: 150,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor),
        label: Text(
          label,
          style: TextStyle(color: textColor),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

void navigateToForgotPasswordScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
  );
}
