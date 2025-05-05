import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskova/Model/colors.dart';

import 'package:taskova/auth/login.dart';

import 'language_provider.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late String selectedLanguage;
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // Initialize once during widget creation
    final appLanguage = Provider.of<AppLanguage>(context, listen: false);
    selectedLanguage = appLanguage.currentLanguage;
  }
  
  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // App Logo
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset(
                  'assets/app_logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => 
                    Icon(Icons.language, size: 60, color: AppColors.primaryBlue),
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
              // Select language text
              Text(
                appLanguage.get('select_language'),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              // Language options
              Expanded(
                child: ListView.builder(
                  itemCount: appLanguage.supportedLanguages.length,
                  itemBuilder: (context, index) {
                    final language = appLanguage.supportedLanguages[index];
                    final isSelected = language['code'] == selectedLanguage;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            selectedLanguage = language['code']!;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected 
                                ? AppColors.primaryBlue 
                                : AppColors.lightBlue,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        tileColor: isSelected ? AppColors.lightBlue.withOpacity(0.1) : Colors.white,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.lightBlue.withOpacity(0.3),
                          child: Text(
                            language['code']!.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(language['name']!),
                        subtitle: Text(language['nativeName']!),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: AppColors.primaryBlue)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Continue button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading 
                    ? null 
                    : () async {
                      setState(() {
                        isLoading = true;
                      });
                      
                      // Change language and translate strings
                      await appLanguage.changeLanguage(selectedLanguage);
                      
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
                        
                        // Navigate to login page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const Login()),
                        );
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
                  child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                      appLanguage.get('continue_text'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}