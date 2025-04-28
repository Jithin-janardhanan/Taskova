import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ShopRegistrationPage extends StatefulWidget {
  const ShopRegistrationPage({Key? key}) : super(key: key);

  @override
  _ShopRegistrationPageState createState() => _ShopRegistrationPageState();
}

class _ShopRegistrationPageState extends State<ShopRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  bool _isLoading = false;
  String _errorMessage = '';
  
  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }
  
  // Get token from shared preferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
  
  Future<void> _registerShop() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Get the saved token
      final token = await _getToken();
      if (token == null) {
        setState(() {
          _errorMessage = 'Authentication token not found. Please login again.';
          _isLoading = false;
        });
        return;
      }
      
      // API endpoint
      final Uri url = Uri.parse('http://192.168.20.10:8000/api/shopkeeper-profile/');
      
      // Request headers
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };
      
      // Request body
      final body = jsonEncode({
        "name": _nameController.text,
        "business_address": _addressController.text,
        "business_contact": _contactController.text,
        "business_email": _emailController.text
      });
      
      // Send POST request
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Registration successful
        final responseData = json.decode(response.body);
        print('Success: ${response.body}');
        
        // Show success and navigate to next screen
        _showSuccessDialog();
      } else {
        // Registration failed
        final responseData = json.decode(response.body);
        setState(() {
          _errorMessage = responseData['detail'] ?? 'Failed to register shop profile. Please try again.';
        });
        print('Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please check your connection and try again.';
      });
      print('Exception: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Registration Successful'),
        content: const Text('Your shop profile has been registered successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              // Navigate to the main dashboard/home
              Navigator.pushNamedAndRemoveUntil(
                context, 
                '/dashboard', 
                (route) => false,
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Registration'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Register Your Shop',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Please provide your shop details below',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Shop Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Shop Name',
                    hintText: 'Enter your shop name',
                    prefixIcon: Icon(Icons.storefront),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your shop name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Business Address
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Business Address',
                    hintText: 'Enter your full business address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your business address';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Business Contact
                TextFormField(
                  controller: _contactController,
                  decoration: const InputDecoration(
                    labelText: 'Business Contact',
                    hintText: 'Enter business phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                    prefixText: '+44 ',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your business contact';
                    }
                    // UK phone number validation (basic)
                    if (value.length < 10) {
                      return 'Please enter a valid UK phone number';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Business Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Business Email',
                    hintText: 'Enter business email address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your business email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 30),
                
                // Error message
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                
                if (_errorMessage.isNotEmpty)
                  const SizedBox(height: 20),
                
                // Register Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _registerShop,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: _isLoading 
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Register Shop',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                
                const SizedBox(height: 20),
                
                // Terms and conditions note
                Text(
                  'By registering, you agree to our Terms of Service and Privacy Policy.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
