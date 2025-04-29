// import 'package:flutter/material.dart';
// import 'package:taskova/login.dart';


// void main() {

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Taskova',

      
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: Login(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskova/language/language_provider.dart';
import 'package:taskova/language/language_selection_screen.dart';

import 'package:taskova/auth/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize language provider
  AppLanguage appLanguage = AppLanguage();
  await appLanguage.init();
  
  // Check if language is already selected
  final prefs = await SharedPreferences.getInstance();
  final hasSelectedLanguage = prefs.containsKey('language_code');
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => appLanguage,
      child: MyApp(hasSelectedLanguage: hasSelectedLanguage),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasSelectedLanguage;
  
  const MyApp({
    super.key,
    required this.hasSelectedLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taskova',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: hasSelectedLanguage ? const Login() : const LanguageSelectionScreen(),
    );
  }
}