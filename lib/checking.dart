// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class TestScreen extends StatefulWidget {
//   const TestScreen({Key? key}) : super(key: key);

//   @override
//   State<TestScreen> createState() => _TestScreenState();
// }

// class _TestScreenState extends State<TestScreen> {
//   String _firestoreStatus = 'Not tested';
//   String _authStatus = 'Not tested';
//   User? _currentUser;
//   String? _userToken;
//   bool _tokenLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkCurrentUser();
//   }

//   void _checkCurrentUser() async {
//     final user = FirebaseAuth.instance.currentUser;
//     setState(() {
//       _currentUser = user;
//       if (user != null) {
//         _authStatus = 'Signed in as: ${user.email}';
//         // Get token automatically when user is already signed in
//         _getIdToken();
//       }
//     });
//   }

//   Future<void> _getIdToken() async {
//     if (_currentUser == null) {
//       setState(() {
//         _userToken = null;
//       });
//       return;
//     }

//     setState(() {
//       _tokenLoading = true;
//     });

//     try {
//       // Get the ID token
//       final idToken = await _currentUser!.getIdToken(true);

//       setState(() {
//         _userToken = idToken;
//         _tokenLoading = false;
//       });

//       print('Generated token length: ${idToken?.length}');
//     } catch (e) {
//       setState(() {
//         _userToken = null;
//         _tokenLoading = false;
//       });
//       print('Error getting token: $e');
//     }
//   }

//   Future<void> _copyTokenToClipboard() async {
//     if (_userToken != null) {
//       await Clipboard.setData(ClipboardData(text: _userToken!));
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Token copied to clipboard'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   Future<void> _testFirestore() async {
//     setState(() {
//       _firestoreStatus = 'Testing Firestore...';
//     });

//     try {
//       // Try a simple operation - read document that might not exist
//       print('Attempting to access Firestore...');

//       final testDocRef = FirebaseFirestore.instance
//           .collection('test_collection')
//           .doc('test_document');

//       print('Getting document...');

//       final docSnapshot = await testDocRef.get();
//       print('Document exists: ${docSnapshot.exists}');

//       if (docSnapshot.exists) {
//         setState(() {
//           _firestoreStatus = 'Firestore read success! Document exists.';
//         });
//       } else {
//         // Try to write data
//         print('Attempting to write to Firestore...');

//         await testDocRef.set({
//           'test': true,
//           'timestamp': FieldValue.serverTimestamp(),
//         });

//         print('Write successful, verifying...');

//         // Verify write
//         final verifySnapshot = await testDocRef.get();

//         setState(() {
//           _firestoreStatus = 'Firestore read/write test successful!';
//         });
//       }
//     } catch (e) {
//       print('Firestore error details: $e');
//       setState(() {
//         _firestoreStatus = 'Error: $e';
//       });
//     }
//   }

//   Future<void> _signInWithGoogle() async {
//     setState(() {
//       _authStatus = 'Starting Google Sign-In...';
//       _userToken = null;
//     });

//     try {
//       print('Initializing Google Sign-In...');
//       final GoogleSignIn googleSignIn = GoogleSignIn();

//       print('Triggering Google Sign-In UI...');
//       final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

//       if (googleUser == null) {
//         print('User canceled sign-in');
//         setState(() {
//           _authStatus = 'Sign-in canceled by user';
//         });
//         return;
//       }

//       print('Got Google account: ${googleUser.email}');
//       setState(() {
//         _authStatus = 'Got Google account, getting credentials...';
//       });

//       try {
//         final GoogleSignInAuthentication googleAuth =
//             await googleUser.authentication;
//         print(
//             'Got auth. Access token length: ${googleAuth.accessToken?.length ?? 0}');
//         print('Got auth. ID token length: ${googleAuth.idToken?.length ?? 0}');

//         if (googleAuth.idToken == null) {
//           setState(() {
//             _authStatus = 'Error: No ID token received from Google';
//           });
//           return;
//         }

//         setState(() {
//           _authStatus = 'Got tokens, creating Firebase credential...';
//         });

//         final credential = GoogleAuthProvider.credential(
//           accessToken: googleAuth.accessToken,
//           idToken: googleAuth.idToken,
//         );

//         print('Created credential, signing in to Firebase...');

//         setState(() {
//           _authStatus = 'Created credential, signing in to Firebase...';
//         });

//         final userCredential =
//             await FirebaseAuth.instance.signInWithCredential(credential);

//         print('Successfully signed in: ${userCredential.user?.email}');

//         setState(() {
//           _currentUser = userCredential.user;
//           _authStatus = 'Signed in as: ${userCredential.user?.email}';
//         });

//         // Get ID token after successful sign-in
//         _getIdToken();
//       } catch (e) {
//         print('Error during auth: $e');
//         setState(() {
//           _authStatus = 'Auth error: $e';
//         });
//       }
//     } catch (e) {
//       print('Google Sign-In error: $e');
//       setState(() {
//         _authStatus = 'Error: $e';
//       });
//     }
//   }

//   Future<void> _signOut() async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       await GoogleSignIn().signOut();

//       setState(() {
//         _currentUser = null;
//         _userToken = null;
//         _authStatus = 'Signed out successfully';
//       });
//     } catch (e) {
//       setState(() {
//         _authStatus = 'Error signing out: $e';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Firebase Test'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 20),
//             // Firestore Test Section
//             const Text(
//               'Firestore Test',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//             const SizedBox(height: 8),
//             Text(_firestoreStatus),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: _testFirestore,
//               child: const Text('Test Firestore'),
//             ),

//             const SizedBox(height: 30),

//             // Authentication Section
//             const Text(
//               'Authentication Status',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//             const SizedBox(height: 8),
//             Text(_authStatus),
//             const SizedBox(height: 8),

//             if (_currentUser == null)
//               ElevatedButton(
//                 onPressed: _signInWithGoogle,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   foregroundColor: Colors.black,
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: const [
//                       Icon(Icons.login, color: Colors.red),
//                       SizedBox(width: 8),
//                       Text('Sign in with Google'),
//                     ],
//                   ),
//                 ),
//               )
//             else
//               ElevatedButton(
//                 onPressed: _signOut,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: const Text('Sign Out'),
//               ),

//             const SizedBox(height: 30),

//             // Current User Info
//             if (_currentUser != null) ...[
//               const Text(
//                 'Current User Info',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//               ),
//               const SizedBox(height: 8),
//               Text('Email: ${_currentUser!.email}'),
//               Text('Name: ${_currentUser!.displayName}'),
//               Text('ID: ${_currentUser!.uid}'),

//               const SizedBox(height: 20),

//               // Firebase ID Token Section
//               const Text(
//                 'Firebase ID Token',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//               ),
//               const SizedBox(height: 8),

//               if (_tokenLoading)
//                 const CircularProgressIndicator()
//               else if (_userToken != null) ...[
//                 Container(
//                   height: 100,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   padding: const EdgeInsets.all(8),
//                   child: SingleChildScrollView(
//                     child: Text(
//                       _userToken!,
//                       style: const TextStyle(fontSize: 12),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: _copyTokenToClipboard,
//                       icon: const Icon(Icons.copy),
//                       label: const Text('Copy Token'),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton.icon(
//                       onPressed: _getIdToken,
//                       icon: const Icon(Icons.refresh),
//                       label: const Text('Refresh Token'),
//                     ),
//                   ],
//                 ),
//               ] else
//                 const Text('No token available. Please sign in first.'),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String _firestoreStatus = 'Not tested';
  String _authStatus = 'Not tested';
  User? _currentUser;
  Map<String, dynamic>? _djangoTokens;
  bool _tokenLoading = false;
  final String _apiBaseUrl =
      'http://192.168.20.3:8000/social_auth/google/'; // Replace with your actual API URL

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  void _checkCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUser = user;
      if (user != null) {
        _authStatus = 'Signed in as: ${user.email}';
        // Check if we need to authenticate with Django
        _authenticateWithDjango();
      }
    });
  }

  Future<void> _authenticateWithDjango() async {
    if (_currentUser == null) {
      setState(() {
        _djangoTokens = null;
      });
      return;
    }

    setState(() {
      _tokenLoading = true;
    });

    try {
      // Get the Firebase ID token
      final String? idToken = await _currentUser!.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to retrieve ID token from Firebase');
      }

      // Send request to Django backend with only auth_token
      final response = await http.post(
        Uri.parse('$_apiBaseUrl'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'auth_token': idToken,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        setState(() {
          _djangoTokens = responseData['tokens'];
          _tokenLoading = false;
        });

        print('Django authentication successful: ${responseData['email']}');
      } else {
        throw Exception('Django authentication failed: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _djangoTokens = null;
        _tokenLoading = false;
      });
      print('Django auth error: $e');
      _authStatus = 'Django auth error: $e';
    }
  }

  Future<void> _copyTokenToClipboard(String tokenType) async {
    if (_djangoTokens != null && _djangoTokens!.containsKey(tokenType)) {
      await Clipboard.setData(ClipboardData(text: _djangoTokens![tokenType]));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$tokenType token copied to clipboard'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _testFirestore() async {
    setState(() {
      _firestoreStatus = 'Testing Firestore...';
    });

    try {
      // Try a simple operation - read document that might not exist
      print('Attempting to access Firestore...');

      final testDocRef = FirebaseFirestore.instance
          .collection('test_collection')
          .doc('test_document');

      print('Getting document...');

      final docSnapshot = await testDocRef.get();
      print('Document exists: ${docSnapshot.exists}');

      if (docSnapshot.exists) {
        setState(() {
          _firestoreStatus = 'Firestore read success! Document exists.';
        });
      } else {
        // Try to write data
        print('Attempting to write to Firestore...');

        await testDocRef.set({
          'test': true,
          'timestamp': FieldValue.serverTimestamp(),
        });

        print('Write successful, verifying...');

        // Verify write
        final verifySnapshot = await testDocRef.get();

        setState(() {
          _firestoreStatus = 'Firestore read/write test successful!';
        });
      }
    } catch (e) {
      print('Firestore error details: $e');
      setState(() {
        _firestoreStatus = 'Error: $e';
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _authStatus = 'Starting Google Sign-In...';
      _djangoTokens = null;
    });

    try {
      print('Initializing Google Sign-In...');
      final GoogleSignIn googleSignIn = GoogleSignIn();

      print('Triggering Google Sign-In UI...');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('User canceled sign-in');
        setState(() {
          _authStatus = 'Sign-in canceled by user';
        });
        return;
      }

      print('Got Google account: ${googleUser.email}');
      setState(() {
        _authStatus = 'Got Google account, getting credentials...';
      });

      try {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        print(
            'Got auth. Access token length: ${googleAuth.accessToken?.length ?? 0}');
        print('Got auth. ID token length: ${googleAuth.idToken?.length ?? 0}');

        if (googleAuth.idToken == null) {
          setState(() {
            _authStatus = 'Error: No ID token received from Google';
          });
          return;
        }

        setState(() {
          _authStatus = 'Got tokens, creating Firebase credential...';
        });

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        print('Created credential, signing in to Firebase...');

        setState(() {
          _authStatus = 'Created credential, signing in to Firebase...';
        });

        final userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        print('Successfully signed in: ${userCredential.user?.email}');

        setState(() {
          _currentUser = userCredential.user;
          _authStatus = 'Signed in as: ${userCredential.user?.email}';
        });

        // Authenticate with Django after successful Firebase authentication
        _authenticateWithDjango();
      } catch (e) {
        print('Error during auth: $e');
        setState(() {
          _authStatus = 'Auth error: $e';
        });
      }
    } catch (e) {
      print('Google Sign-In error: $e');
      setState(() {
        _authStatus = 'Error: $e';
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      setState(() {
        _currentUser = null;
        _djangoTokens = null;
        _authStatus = 'Signed out successfully';
      });
    } catch (e) {
      setState(() {
        _authStatus = 'Error signing out: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Firestore Test Section
            const Text(
              'Firestore Test',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(_firestoreStatus),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testFirestore,
              child: const Text('Test Firestore'),
            ),

            const SizedBox(height: 30),

            // Authentication Section
            const Text(
              'Authentication Status',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(_authStatus),
            const SizedBox(height: 8),

            if (_currentUser == null)
              ElevatedButton(
                onPressed: _signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.login, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Sign in with Google'),
                    ],
                  ),
                ),
              )
            else
              ElevatedButton(
                onPressed: _signOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign Out'),
              ),

            const SizedBox(height: 30),

            // Current User Info
            if (_currentUser != null) ...[
              const Text(
                'Current User Info',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text('Email: ${_currentUser!.email}'),
              Text('Name: ${_currentUser!.displayName}'),
              Text('ID: ${_currentUser!.uid}'),

              const SizedBox(height: 20),

              // Django JWT Tokens Section
              const Text(
                'Django JWT Tokens',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),

              if (_tokenLoading)
                const CircularProgressIndicator()
              else if (_djangoTokens != null) ...[
                // Access Token
                const Text('Access Token:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: SingleChildScrollView(
                    child: Text(
                      _djangoTokens!['access'],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Refresh Token
                const Text('Refresh Token:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: SingleChildScrollView(
                    child: Text(
                      _djangoTokens!['refresh'],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _copyTokenToClipboard('access'),
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Access Token'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _copyTokenToClipboard('refresh'),
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Refresh Token'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _authenticateWithDjango,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Tokens'),
                ),
              ] else
                const Text('No Django tokens available. Please sign in first.'),
            ],
          ],
        ),
      ),
    );
  }
}
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as http;


// class GoogleSignInPage extends StatefulWidget {
//   const GoogleSignInPage({super.key});

//   @override
//   _GoogleSignInPageState createState() => _GoogleSignInPageState();
// }

// class _GoogleSignInPageState extends State<GoogleSignInPage> {
//   final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
//   GoogleSignInAccount? _currentUser;
//   String _message = '';

//   @override
//   void initState() {
//     super.initState();
//     // Check if a user is already signed in
//     _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
//       setState(() {
//         _currentUser = account;
//         if (_currentUser != null) {
//           _message = 'Selected account: ${_currentUser!.email}';
//         } else {
//           _message = '';
//         }
//       });
//     });
//     _googleSignIn.signInSilently();
//   }

//   Future<void> _handleSignIn() async {
//     try {
//       // Trigger Google account picker
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         setState(() {
//           _message = 'Sign-in canceled';
//         });
//         return;
//       }

//       // Get authentication token
//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;
//       final String? authToken = googleAuth.idToken;

//       if (authToken == null) {
//         setState(() {
//           _message = 'Failed to get authentication token';
//         });
//         return;
//       }

//       // Send token to backend
//       final headers = {'Content-Type': 'application/json'};
//       final request = http.Request(
//         'POST',
//         Uri.parse('http://192.168.20.3:8000/social_auth/google/'),
//       );
//       request.body = json.encode({'auth_token': authToken});
//       request.headers.addAll(headers);

//       final http.StreamedResponse response = await request.send();

//       if (response.statusCode == 200) {
//         final responseBody = await response.stream.bytesToString();
//         setState(() {
//           _message = 'Success: $responseBody';
//         });
//         // Navigate to MainPage on successful login
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const MainPage()),
//         );
//       } else {
//         setState(() {
//           _message = 'Error: ${response.reasonPhrase}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _message = 'Error: $e';
//       });
//     }
//   }

//   Future<void> _handleSignOut() async {
//     await _googleSignIn.signOut();
//     setState(() {
//       _currentUser = null;
//       _message = 'Signed out';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Google Sign-In')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (_currentUser != null)
//               Text(
//                 'Logged in as: ${_currentUser!.email}',
//                 style:
//                     const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: _currentUser == null ? _handleSignIn : null,
//               icon: const Icon(Icons.login),
//               label: const Text('Sign in with Google'),
//               style: ElevatedButton.styleFrom(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//               ),
//             ),
//             const SizedBox(height: 10),
//             if (_currentUser != null)
//               ElevatedButton.icon(
//                 onPressed: _handleSignOut,
//                 icon: const Icon(Icons.logout),
//                 label: const Text('Sign out'),
//                 style: ElevatedButton.styleFrom(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                   backgroundColor: Colors.red,
//                 ),
//               ),
//             const SizedBox(height: 20),
//             Text(
//               _message,
//               style: const TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MainPage extends StatelessWidget {
//   const MainPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Main Page')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Welcome to the Main Page!',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const GoogleSignInPage()),
//                 );
//               },
//               child: const Text('Sign Out'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
