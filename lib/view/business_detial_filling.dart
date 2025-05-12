// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:taskova/Model/colors.dart';
// import 'package:taskova/view/bottom_nav.dart';
// import 'package:http/http.dart' as http;
// import 'package:taskova/language/language_provider.dart';
// import 'package:geocoding/geocoding.dart'; // Import geocoding package

// class BusinessFormPage extends StatefulWidget {
//   const BusinessFormPage({Key? key}) : super(key: key);

//   @override
//   State<BusinessFormPage> createState() => _BusinessFormPageState();
// }

// class _BusinessFormPageState extends State<BusinessFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _businessNameController = TextEditingController();
//   final _businessAddressController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _contactNumberController = TextEditingController();
//   final _postcodeController = TextEditingController();
//   final _latitudeController = TextEditingController();
//   final _longitudeController = TextEditingController();

//   File? _businessImage;
//   final ImagePicker _picker = ImagePicker();
//   bool _isLoading = false;
//   bool _isGeocodingLoading = false; // Added for geocoding loading state
//   String? _accessToken;
//   String? _userId;
//   bool _isActive = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();

//     // Add listener to postcode field to automatically fetch coordinates
//     _postcodeController.addListener(_onPostcodeChanged);
//   }

//   @override
//   void dispose() {
//     // Remove listener when disposing
//     _postcodeController.removeListener(_onPostcodeChanged);
//     _postcodeController.dispose();
//     _businessNameController.dispose();
//     _businessAddressController.dispose();
//     _emailController.dispose();
//     _contactNumberController.dispose();
//     _latitudeController.dispose();
//     _longitudeController.dispose();
//     super.dispose();
//   }

//   // Debounce mechanism to prevent too many API calls
//   DateTime? _lastPostcodeChange;
//   Future<void> _onPostcodeChanged() async {
//     final postcode = _postcodeController.text.trim();

//     // Only proceed if postcode has at least 4 characters
//     if (postcode.length < 4) return;

//     // Debounce: only fetch after user stops typing for 1 second
//     _lastPostcodeChange = DateTime.now();
//     await Future.delayed(const Duration(seconds: 1));

//     // If there was another change after this one, don't proceed
//     if (_lastPostcodeChange != null &&
//         DateTime.now().difference(_lastPostcodeChange!).inSeconds < 1) {
//       return;
//     }

//     // Fetch coordinates from postcode
//     _fetchCoordinatesFromPostcode(postcode);
//   }

//   Future<void> _fetchCoordinatesFromPostcode(String postcode) async {
//     if (postcode.isEmpty) return;

//     setState(() {
//       _isGeocodingLoading = true;
//     });

//     try {
//       // For UK postcodes, you might want to add the country to improve accuracy
//       List<Location> locations = await locationFromAddress("$postcode, UK");

//       if (locations.isNotEmpty) {
//         setState(() {
//           _latitudeController.text = locations.first.latitude.toString();
//           _longitudeController.text = locations.first.longitude.toString();
//           _isGeocodingLoading = false;
//         });
//       } else {
//         _showSnackbar("Could not find coordinates for this postcode", true);
//         setState(() {
//           _isGeocodingLoading = false;
//         });
//       }
//     } catch (e) {
//       print("Error geocoding postcode: $e");
//       setState(() {
//         _isGeocodingLoading = false;
//       });

//       // Only show error if the postcode field still has content
//       if (_postcodeController.text.isNotEmpty) {
//         _showSnackbar("Error finding location: $e", true);
//       }
//     }
//   }

//   Future<void> _loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _accessToken = prefs.getString('access_token');
//       _userId = prefs.getString('user_id');
//     });
//   }

//   Future<void> _pickImage() async {
//     try {
//       final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//       if (image != null) {
//         setState(() {
//           _businessImage = File(image.path);
//         });
//       }
//     } catch (e) {
//       print("Error picking image: $e");
//     }
//   }

//   void _showSnackbar(String message, bool isError) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   Future<void> _submitBusinessDetails() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         var headers = {
//           'Authorization': 'Bearer $_accessToken',
//         };

//         var request = http.MultipartRequest('POST',
//             Uri.parse('http://192.168.20.3:8000/api/shopkeeper/businesses/'));

//         request.fields.addAll({
//           'business[name]': _businessNameController.text,
//           'business[address]': _businessAddressController.text,
//           'business[email]': _emailController.text,
//           'business[contact_number]': _contactNumberController.text,
//           'business[latitude]': _latitudeController.text,
//           'business[longitude]': _longitudeController.text,
//           'business[postcode]': _postcodeController.text,
//           'business[is_active]': _isActive.toString(),
//           'business[user]': _userId ?? '',
//         });

//         if (_businessImage != null) {
//           request.files.add(await http.MultipartFile.fromPath(
//               'business[image]', _businessImage!.path));
//         }

//         request.headers.addAll(headers);

//         final appLanguage = Provider.of<AppLanguage>(context, listen: false);

//         http.StreamedResponse response = await request.send();

//         setState(() {
//           _isLoading = false;
//         });

//         if (response.statusCode == 200 || response.statusCode == 201) {
//           final responseBody = await response.stream.bytesToString();
//           print('Business profile created: $responseBody');

//           // Show success message
//           _showSnackbar(
//               await appLanguage.translate(
//                   "Business profile created successfully!",
//                   appLanguage.currentLanguage),
//               false);

//           // Navigate to bottom navigation
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => HomePageWithBottomNav()),
//           );
//         } else {
//           final errorResponse = await response.stream.bytesToString();
//           print(
//               'Business profile creation failed: ${response.reasonPhrase}, $errorResponse');

//           // Show error message
//           _showSnackbar(
//               await appLanguage.translate(
//                   "Failed to create business profile. Please try again.",
//                   appLanguage.currentLanguage),
//               true);
//         }
//       } catch (e) {
//         setState(() {
//           _isLoading = false;
//         });
//         print("Business profile creation error: $e");

//         final appLanguage = Provider.of<AppLanguage>(context, listen: false);
//         _showSnackbar(
//             await appLanguage.translate(
//                 "Connection error. Please check your internet connection.",
//                 appLanguage.currentLanguage),
//             true);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final appLanguage = Provider.of<AppLanguage>(context);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(
//           appLanguage.get('business details') ?? 'Business Details',
//           style: const TextStyle(color: Colors.white),
//         ),
//         backgroundColor: AppColors.primaryBlue,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 20),

//                   // Business image picker
//                   GestureDetector(
//                     onTap: _pickImage,
//                     child: Stack(
//                       children: [
//                         Container(
//                           height: 120,
//                           width: 120,
//                           decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: AppColors.primaryBlue,
//                               width: 2,
//                             ),
//                           ),
//                           child: _businessImage != null
//                               ? ClipOval(
//                                   child: Image.file(
//                                     _businessImage!,
//                                     width: 120,
//                                     height: 120,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 )
//                               : Icon(
//                                   Icons.business,
//                                   size: 60,
//                                   color: Colors.grey[400],
//                                 ),
//                         ),
//                         Positioned(
//                           bottom: 0,
//                           right: 0,
//                           child: Container(
//                             height: 36,
//                             width: 36,
//                             decoration: BoxDecoration(
//                               color: AppColors.primaryBlue,
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: Colors.white,
//                                 width: 2,
//                               ),
//                             ),
//                             child: const Icon(
//                               Icons.camera_alt,
//                               size: 20,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 30),

//                   // Instructions text
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: Text(
//                       appLanguage.get('business_instructions') ??
//                           'Please fill in the details of your business',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 30),

//                   // Business Name field
//                   TextFormField(
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return appLanguage.get('business_name_required') ??
//                             'Business name is required';
//                       }
//                       return null;
//                     },
//                     controller: _businessNameController,
//                     decoration: InputDecoration(
//                       labelText:
//                           appLanguage.get('business_name') ?? 'Business Name',
//                       hintText: appLanguage.get('enter_business_name') ??
//                           'Enter your business name',
//                       prefixIcon: const Icon(
//                         Icons.business,
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

//                   // Business Address field
//                   TextFormField(
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return appLanguage.get('business_address_required') ??
//                             'Business address is required';
//                       }
//                       return null;
//                     },
//                     controller: _businessAddressController,
//                     maxLines: 2,
//                     decoration: InputDecoration(
//                       labelText: appLanguage.get('business_address') ??
//                           'Business Address',
//                       hintText: appLanguage.get('enter_business_address') ??
//                           'Enter your business address',
//                       prefixIcon: const Padding(
//                         padding: EdgeInsets.only(bottom: 20),
//                         child: Icon(
//                           Icons.location_on_outlined,
//                           color: AppColors.secondaryBlue,
//                         ),
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

//                   // Email field
//                   TextFormField(
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return appLanguage.get('email_required') ??
//                             'Email is required';
//                       }
//                       if (!value.contains('@')) {
//                         return appLanguage.get('valid_email_required') ??
//                             'Please enter a valid email';
//                       }
//                       return null;
//                     },
//                     controller: _emailController,
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: InputDecoration(
//                       labelText: appLanguage.get('email') ?? 'Email',
//                       hintText: appLanguage.get('enter_email') ??
//                           'Enter business email',
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

//                   // Contact Number field
//                   TextFormField(
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return appLanguage.get('contact_number_required') ??
//                             'Contact number is required';
//                       }
//                       return null;
//                     },
//                     controller: _contactNumberController,
//                     keyboardType: TextInputType.phone,
//                     decoration: InputDecoration(
//                       labelText:
//                           appLanguage.get('contact_number') ?? 'Contact Number',
//                       hintText: appLanguage.get('enter_contact_number') ??
//                           'Enter business contact number',
//                       prefixIcon: const Icon(
//                         Icons.phone_outlined,
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

//                   // Postcode field with fetch button
//                   TextFormField(
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return appLanguage.get('postcode_required') ??
//                             'Postcode is required';
//                       }
//                       return null;
//                     },
//                     controller: _postcodeController,
//                     keyboardType: TextInputType.text,
//                     decoration: InputDecoration(
//                       labelText: appLanguage.get('postcode') ?? 'Postcode',
//                       hintText:
//                           appLanguage.get('enter_postcode') ?? 'Enter postcode',
//                       prefixIcon: const Icon(
//                         Icons.location_city,
//                         color: AppColors.secondaryBlue,
//                       ),
//                       suffixIcon: _isGeocodingLoading
//                           ? Container(
//                               width: 24,
//                               height: 24,
//                               padding: const EdgeInsets.all(8.0),
//                               child: const CircularProgressIndicator(
//                                 strokeWidth: 2.0,
//                                 color: AppColors.primaryBlue,
//                               ),
//                             )
//                           : IconButton(
//                               icon: const Icon(Icons.gps_fixed,
//                                   color: AppColors.primaryBlue),
//                               onPressed: () {
//                                 if (_postcodeController.text.isNotEmpty) {
//                                   _fetchCoordinatesFromPostcode(
//                                       _postcodeController.text);
//                                 } else {
//                                   _showSnackbar(
//                                       appLanguage
//                                               .get('please_enter_postcode') ??
//                                           'Please enter a postcode first',
//                                       true);
//                                 }
//                               },
//                               tooltip: appLanguage.get('fetch_coordinates') ??
//                                   'Fetch coordinates from postcode',
//                             ),
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

//                   // Is Active switch
//                   Container(
//                     padding: const EdgeInsets.symmetric(vertical: 5),
//                     height: 60,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[50],
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: AppColors.lightBlue, width: 1),
//                     ),
//                     child: SwitchListTile(
//                       title: Text(
//                         appLanguage.get('active') ?? 'Active',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: AppColors.secondaryBlue,
//                         ),
//                       ),
//                       value: _isActive,
//                       onChanged: (bool value) {
//                         setState(() {
//                           _isActive = value;
//                         });
//                       },
//                       activeColor: AppColors.primaryBlue,
//                       contentPadding:
//                           const EdgeInsets.symmetric(horizontal: 16),
//                     ),
//                   ),

//                   const SizedBox(height: 40),

//                   // Submit button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 55,
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _submitBusinessDetails,
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
//                               appLanguage.get('save business') ??
//                                   'Save_Business',
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // Skip for now button
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => HomePageWithBottomNav()),
//                       );
//                     },
//                     child: Text(
//                       appLanguage.get('skip_for_now') ?? 'Skip for now',
//                       style: const TextStyle(
//                         color: AppColors.secondaryBlue,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
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
// }
//-------------------------------------------------------------------------

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskova/Model/colors.dart';
import 'package:taskova/view/bottom_nav.dart';
import 'package:http/http.dart' as http;
import 'package:taskova/language/language_provider.dart';
import 'package:geocoding/geocoding.dart';

class BusinessFormPage extends StatefulWidget {
  const BusinessFormPage({Key? key}) : super(key: key);

  @override
  State<BusinessFormPage> createState() => _BusinessFormPageState();
}

class _BusinessFormPageState extends State<BusinessFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  // Focus node for postcode field
  final _postcodeFocusNode = FocusNode();

  File? _businessImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isGeocodingLoading = false;
  String? _accessToken;
  String? _userId;
  bool _isActive = true;

  // List to store postal code suggestions
  List<String> _postalCodeSuggestions = [];

  // Track whether suggestions are visible
  bool _areSuggestionsVisible = false;

  // UK postcode regex pattern
  final _postcodeRegex = RegExp(r'^[A-Z]{1,2}[0-9][A-Z0-9]? ?[0-9][A-Z]{2}$',
      caseSensitive: false);

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Add listener to postcode field to fetch suggestions
    _postcodeController.addListener(_fetchPostcodeSuggestions);

    // Add listener to focus changes
    _postcodeFocusNode.addListener(_onPostcodeFocusChange);
  }

  void _onPostcodeFocusChange() {
    if (!_postcodeFocusNode.hasFocus) {
      // Delay to allow tap on suggestion to work
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          _postalCodeSuggestions = [];
          _areSuggestionsVisible = false;
        });
      });
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accessToken = prefs.getString('access_token');
      _userId = prefs.getString('user_id');

      // Fetch email from shared preferences
      final savedEmail = prefs.getString('user_email');
      if (savedEmail != null) {
        _emailController.text = savedEmail;
      }
    });
  }

  // Fetch postal code suggestions from an API
  Future<void> _fetchPostcodeSuggestions() async {
    final query = _postcodeController.text.trim();

    // Hide suggestions if postcode is complete and valid
    if (_postcodeRegex.hasMatch(query)) {
      setState(() {
        _postalCodeSuggestions = [];
        _areSuggestionsVisible = false;
      });
      return;
    }

    // Only fetch suggestions if query is at least 2 characters
    if (query.length < 2) {
      setState(() {
        _postalCodeSuggestions = [];
        _areSuggestionsVisible = false;
      });
      return;
    }

    try {
      // Replace with your actual API endpoint for postcode suggestions
      final response = await http.get(
        Uri.parse('https://api.postcodes.io/postcodes/$query/autocomplete'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Check if the API returns a list of postcodes
        if (data['result'] != null) {
          setState(() {
            _postalCodeSuggestions = List<String>.from(data['result']);
            _areSuggestionsVisible = _postalCodeSuggestions.isNotEmpty;
          });
        } else {
          setState(() {
            _postalCodeSuggestions = [];
            _areSuggestionsVisible = false;
          });
        }
      } else {
        // Fallback to a static list if API fails
        final fallbackSuggestions = _generateFallbackPostcodes(query);
        setState(() {
          _postalCodeSuggestions = fallbackSuggestions;
          _areSuggestionsVisible = fallbackSuggestions.isNotEmpty;
        });
      }
    } catch (e) {
      print('Error fetching postcode suggestions: $e');

      // Fallback to a static list if there's a network error
      final fallbackSuggestions = _generateFallbackPostcodes(query);
      setState(() {
        _postalCodeSuggestions = fallbackSuggestions;
        _areSuggestionsVisible = fallbackSuggestions.isNotEmpty;
      });
    }
  }

  // Generate fallback postcode suggestions
  List<String> _generateFallbackPostcodes(String query) {
    // Sample list of UK postcodes
    final allPostcodes = [
      'SW1A 1AA',
      'W1A 0AX',
      'EC1A 1BB',
      'M1 1AE',
      'B33 8TH',
      'CR2 6XH',
      'DN55 1PT',
      'L1 1QW',
      'SE1 7GP',
      'W1T 1UQ',
    ];

    // Filter postcodes that start with the query (case-insensitive)
    return allPostcodes
        .where((postcode) =>
            postcode.toLowerCase().startsWith(query.toLowerCase()))
        .toList();
  }

  Future<void> _selectPostcode(String postcode) async {
    // Set the selected postcode
    _postcodeController.text = postcode;

    // Clear suggestions and hide them immediately
    setState(() {
      _postalCodeSuggestions = [];
      _areSuggestionsVisible = false;
    });

    // Unfocus the postcode field
    FocusScope.of(context).unfocus();

    // Fetch coordinates
    await _fetchCoordinatesFromPostcode(postcode);
  }

  Future<void> _fetchCoordinatesFromPostcode(String postcode) async {
    if (postcode.isEmpty) return;

    setState(() {
      _isGeocodingLoading = true;
    });

    try {
      List<Location> locations = await locationFromAddress("$postcode, UK");

      if (locations.isNotEmpty) {
        setState(() {
          _latitudeController.text = locations.first.latitude.toString();
          _longitudeController.text = locations.first.longitude.toString();
          _isGeocodingLoading = false;
        });
      } else {
        _showSnackbar("Could not find coordinates for this postcode", true);
        setState(() {
          _isGeocodingLoading = false;
        });
      }
    } catch (e) {
      print("Error geocoding postcode: $e");
      setState(() {
        _isGeocodingLoading = false;
      });

      if (_postcodeController.text.isNotEmpty) {
        _showSnackbar("Error finding location: $e", true);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _businessImage = File(image.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void _showSnackbar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submitBusinessDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        var headers = {
          'Authorization': 'Bearer $_accessToken',
        };

        var request = http.MultipartRequest('POST',
            Uri.parse('http://192.168.20.15:8000/api/shopkeeper/businesses/'));

        request.fields.addAll({
          'business[name]': _businessNameController.text,
          'business[address]': _businessAddressController.text,
          'business[email]': _emailController.text,
          'business[contact_number]': _contactNumberController.text,
          'business[latitude]': _latitudeController.text,
          'business[longitude]': _longitudeController.text,
          'business[postcode]': _postcodeController.text,
          'business[is_active]': _isActive.toString(),
          'business[user]': _userId ?? '',
        });

        if (_businessImage != null) {
          request.files.add(await http.MultipartFile.fromPath(
              'business[image]', _businessImage!.path));
        }

        request.headers.addAll(headers);

        final appLanguage = Provider.of<AppLanguage>(context, listen: false);

        http.StreamedResponse response = await request.send();

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseBody = await response.stream.bytesToString();
          print('Business profile created: $responseBody');

          // Show success message
          _showSnackbar(
              await appLanguage.translate(
                  "Business profile created successfully!",
                  appLanguage.currentLanguage),
              false);

          // Navigate to bottom navigation
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePageWithBottomNav()),
          );
        } else {
          final errorResponse = await response.stream.bytesToString();
          print(
              'Business profile creation failed: ${response.reasonPhrase}, $errorResponse');

          // Show error message
          _showSnackbar(
              await appLanguage.translate(
                  "Failed to create business profile. Please try again.",
                  appLanguage.currentLanguage),
              true);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print("Business profile creation error: $e");

        final appLanguage = Provider.of<AppLanguage>(context, listen: false);
        _showSnackbar(
            await appLanguage.translate(
                "Connection error. Please check your internet connection.",
                appLanguage.currentLanguage),
            true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            appLanguage.get('business details') ?? 'Business Details',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
          centerTitle: true,
        ),
        body: GestureDetector(
          // Dismiss keyboard and suggestions when tapping outside
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() {
              _postalCodeSuggestions = [];
              _areSuggestionsVisible = false;
            });
          },
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // Business image picker
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryBlue,
                                  width: 2,
                                ),
                              ),
                              child: _businessImage != null
                                  ? ClipOval(
                                      child: Image.file(
                                        _businessImage!,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.business,
                                      size: 60,
                                      color: Colors.grey[400],
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                height: 36,
                                width: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Instructions text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          appLanguage.get('business_instructions') ??
                              'Please fill in the details of your business',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Business Name field
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return appLanguage.get('business_name_required') ??
                                'Business name is required';
                          }
                          return null;
                        },
                        controller: _businessNameController,
                        decoration: InputDecoration(
                          labelText: appLanguage.get('business_name') ??
                              'Business Name',
                          hintText: appLanguage.get('enter_business_name') ??
                              'Enter your business name',
                          prefixIcon: const Icon(
                            Icons.business,
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

                      // Business Address field
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return appLanguage
                                    .get('business_address_required') ??
                                'Business address is required';
                          }
                          return null;
                        },
                        controller: _businessAddressController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: appLanguage.get('business_address') ??
                              'Business Address',
                          hintText: appLanguage.get('enter_business_address') ??
                              'Enter your business address',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Icon(
                              Icons.location_on_outlined,
                              color: AppColors.secondaryBlue,
                            ),
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

                      // Email field
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return appLanguage.get('email_required') ??
                                'Email is required';
                          }
                          if (!value.contains('@')) {
                            return appLanguage.get('valid_email_required') ??
                                'Please enter a valid email';
                          }
                          return null;
                        },
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: appLanguage.get('email') ?? 'Email',
                          hintText: appLanguage.get('enter_email') ??
                              'Enter business email',
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

                      // Contact Number field
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return appLanguage.get('contact_number_required') ??
                                'Contact number is required';
                          }
                          return null;
                        },
                        controller: _contactNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: appLanguage.get('contact_number') ??
                              'Contact Number',
                          hintText: appLanguage.get('enter_contact_number') ??
                              'Enter business contact number',
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
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

                      // Postcode field with fetch button
                      Column(
                        children: [
                          TextFormField(
                            controller: _postcodeController,
                            focusNode: _postcodeFocusNode,
                            decoration: InputDecoration(
                              labelText:
                                  appLanguage.get('postcode') ?? 'Postcode',
                              hintText: appLanguage.get('enter_postcode') ??
                                  'Enter postcode',
                              prefixIcon: const Icon(
                                Icons.location_city,
                                color: AppColors.secondaryBlue,
                              ),
                              suffixIcon: _isGeocodingLoading
                                  ? Container(
                                      width: 24,
                                      height: 24,
                                      padding: const EdgeInsets.all(8.0),
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        color: AppColors.primaryBlue,
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.gps_fixed,
                                          color: AppColors.primaryBlue),
                                      onPressed: () {
                                        if (_postcodeController
                                            .text.isNotEmpty) {
                                          _fetchCoordinatesFromPostcode(
                                              _postcodeController.text);
                                        } else {
                                          _showSnackbar(
                                              appLanguage.get(
                                                      'please_enter_postcode') ??
                                                  'Please enter a postcode first',
                                              true);
                                        }
                                      },
                                      tooltip: appLanguage
                                              .get('fetch_coordinates') ??
                                          'Fetch coordinates from postcode',
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return appLanguage.get('postcode_required') ??
                                    'Postcode is required';
                              }
                              return null;
                            },
                          ),

                          // Suggestion list
                          if (_areSuggestionsVisible)
                            Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _postalCodeSuggestions.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_postalCodeSuggestions[index]),
                                    onTap: () {
                                      // Use the new method to select postcode
                                      _selectPostcode(
                                          _postalCodeSuggestions[index]);
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Is Active switch
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: AppColors.lightBlue, width: 1),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            appLanguage.get('active') ?? 'Active',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryBlue,
                            ),
                          ),
                          value: _isActive,
                          onChanged: (bool value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                          activeColor: AppColors.primaryBlue,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitBusinessDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  appLanguage.get('save business') ??
                                      'Save_Business',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Skip for now button
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePageWithBottomNav()),
                          );
                        },
                        child: Text(
                          appLanguage.get('skip_for_now') ?? 'Skip for now',
                          style: const TextStyle(
                            color: AppColors.secondaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    // Remove listeners
    _postcodeController.removeListener(_fetchPostcodeSuggestions);
    _postcodeFocusNode.removeListener(_onPostcodeFocusChange);

    // Dispose nodes and controllers
    _postcodeFocusNode.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    _postcodeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }
}
