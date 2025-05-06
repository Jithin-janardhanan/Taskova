import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskova/checking.dart';
import 'package:taskova/language/language_provider.dart';
import 'package:taskova/language/language_selection_screen.dart';
import 'package:taskova/auth/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables with error handling
    await dotenv.load(fileName: ".env").catchError((error) {
      debugPrint("Error loading .env file: $error");
      throw Exception("Failed to load environment variables");
    });

    // // Verify API base URL is loaded
    // final baseUrl = dotenv.env['BASE_URL'];
    // if (baseUrl == null || baseUrl.isEmpty) {
    //   throw Exception("BASE_URL not found in .env file");
    // }
    // debugPrint("API Base URL: $baseUrl");
   

    // Print for debugging
    print('Loaded BASE_URL: ${dotenv.env['BASE_URL']}');

    // Initialize language provider
    final prefs = await SharedPreferences.getInstance();
    final appLanguage = AppLanguage();
    await appLanguage.init();
    final hasSelectedLanguage = prefs.containsKey('language_code');

    runApp(
      ChangeNotifierProvider.value(
        value: appLanguage,
        child: MyApp(hasSelectedLanguage: hasSelectedLanguage),
      ),
    );
  } catch (e) {
    // Fallback UI if initialization fails
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 50, color: Colors.red),
                const SizedBox(height: 20),
                Text(
                  "Initialization Error",
                ),
                const SizedBox(height: 10),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => main(), // Retry
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:
          hasSelectedLanguage ? const Login() : const LanguageSelectionScreen(),
    );
  }
}
