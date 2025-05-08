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

  File? _businessImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _accessToken;
  String? _userId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accessToken = prefs.getString('access_token');
      _userId = prefs.getString('user_id');
    });
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
            Uri.parse('http://192.168.20.3:8000/api/shopkeeper/businesses/'));

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
          appLanguage.get('business_details') ?? 'Business Details',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                      labelText:
                          appLanguage.get('business_name') ?? 'Business Name',
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
                        return appLanguage.get('business_address_required') ??
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
                      labelText:
                          appLanguage.get('contact_number') ?? 'Contact Number',
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

                  // Two fields in a row: Postcode and Is Active
                  Row(
                    children: [
                      // Postcode field
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return appLanguage.get('postcode_required') ??
                                  'Postcode is required';
                            }
                            return null;
                          },
                          controller: _postcodeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText:
                                appLanguage.get('postcode') ?? 'Postcode',
                            hintText: appLanguage.get('enter_postcode') ??
                                'Enter postcode',
                            prefixIcon: const Icon(
                              Icons.location_city,
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
                      ),
                      const SizedBox(width: 10),
                      // Is Active switch
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.lightBlue, width: 1),
                          ),
                          child: SwitchListTile(
                            title: Text(
                              appLanguage.get('active') ?? 'Active',
                              style: TextStyle(
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
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Two fields in a row: Latitude and Longitude
                  Row(
                    children: [
                      // Latitude field
                      Expanded(
                        child: TextFormField(
                          controller: _latitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText:
                                appLanguage.get('latitude') ?? 'Latitude',
                            hintText: appLanguage.get('enter_latitude') ??
                                'Enter latitude',
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
                      ),
                      const SizedBox(width: 10),
                      // Longitude field
                      Expanded(
                        child: TextFormField(
                          controller: _longitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText:
                                appLanguage.get('longitude') ?? 'Longitude',
                            hintText: appLanguage.get('enter_longitude') ??
                                'Enter longitude',
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
                      ),
                    ],
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
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              appLanguage.get('save_business') ??
                                  'Save Business',
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
    );
  }
}
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
// import 'package:geolocator/geolocator.dart';

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
//   bool _isLocationLoading = false;
//   String? _accessToken;
//   String? _userId;
//   bool _isActive = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
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

//   // Check and request location permissions
//   Future<bool> _handleLocationPermission() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     // Test if location services are enabled
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       _showSnackbar(
//           'Location services are disabled. Please enable the services', true);
//       return false;
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         _showSnackbar('Location permissions are denied', true);
//         return false;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       _showSnackbar(
//           'Location permissions are permanently denied, we cannot request permissions',
//           true);
//       return false;
//     }

//     return true;
//   }

//   // Get current location
//   Future<void> _getCurrentLocation() async {
//     final appLanguage = Provider.of<AppLanguage>(context, listen: false);
    
//     setState(() {
//       _isLocationLoading = true;
//     });

//     final hasPermission = await _handleLocationPermission();
//     if (!hasPermission) {
//       setState(() {
//         _isLocationLoading = false;
//       });
//       return;
//     }

//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       setState(() {
//         _latitudeController.text = position.latitude.toString();
//         _longitudeController.text = position.longitude.toString();
//         _isLocationLoading = false;
//       });

//       _showSnackbar(
//           await appLanguage.translate(
//               "Location fetched successfully!", appLanguage.currentLanguage),
//           false);
//     } catch (e) {
//       setState(() {
//         _isLocationLoading = false;
//       });
//       print("Error getting current location: $e");
//       _showSnackbar(
//           await appLanguage.translate(
//               "Failed to get current location", appLanguage.currentLanguage),
//           true);
//     }
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
//           appLanguage.get('business_details') ?? 'Business Details',
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

//                   // Two fields in a row: Postcode and Is Active
//                   Row(
//                     children: [
//                       // Postcode field
//                       Expanded(
//                         flex: 2,
//                         child: TextFormField(
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return appLanguage.get('postcode_required') ??
//                                   'Postcode is required';
//                             }
//                             return null;
//                           },
//                           controller: _postcodeController,
//                           keyboardType: TextInputType.number,
//                           decoration: InputDecoration(
//                             labelText:
//                                 appLanguage.get('postcode') ?? 'Postcode',
//                             hintText: appLanguage.get('enter_postcode') ??
//                                 'Enter postcode',
//                             prefixIcon: const Icon(
//                               Icons.location_city,
//                               color: AppColors.secondaryBlue,
//                             ),
//                             filled: true,
//                             fillColor: Colors.grey[50],
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide.none,
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                   color: AppColors.lightBlue, width: 1),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                   color: AppColors.primaryBlue, width: 2),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       // Is Active switch
//                       Expanded(
//                         flex: 1,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(vertical: 5),
//                           height: 60,
//                           decoration: BoxDecoration(
//                             color: Colors.grey[50],
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                                 color: AppColors.lightBlue, width: 1),
//                           ),
//                           child: SwitchListTile(
//                             title: Text(
//                               appLanguage.get('active') ?? 'Active',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: AppColors.secondaryBlue,
//                               ),
//                             ),
//                             value: _isActive,
//                             onChanged: (bool value) {
//                               setState(() {
//                                 _isActive = value;
//                               });
//                             },
//                             activeColor: AppColors.primaryBlue,
//                             contentPadding: EdgeInsets.zero,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 20),

//                   // Two fields in a row: Latitude and Longitude with Get Location button
//                   Column(
//                     children: [
//                       Row(
//                         children: [
//                           // Latitude field
//                           Expanded(
//                             child: TextFormField(
//                               controller: _latitudeController,
//                               keyboardType: const TextInputType.numberWithOptions(
//                                   decimal: true),
//                               decoration: InputDecoration(
//                                 labelText:
//                                     appLanguage.get('latitude') ?? 'Latitude',
//                                 hintText: appLanguage.get('enter_latitude') ??
//                                     'Enter latitude',
//                                 filled: true,
//                                 fillColor: Colors.grey[50],
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: const BorderSide(
//                                       color: AppColors.lightBlue, width: 1),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: const BorderSide(
//                                       color: AppColors.primaryBlue, width: 2),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           // Longitude field
//                           Expanded(
//                             child: TextFormField(
//                               controller: _longitudeController,
//                               keyboardType: const TextInputType.numberWithOptions(
//                                   decimal: true),
//                               decoration: InputDecoration(
//                                 labelText:
//                                     appLanguage.get('longitude') ?? 'Longitude',
//                                 hintText: appLanguage.get('enter_longitude') ??
//                                     'Enter longitude',
//                                 filled: true,
//                                 fillColor: Colors.grey[50],
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: const BorderSide(
//                                       color: AppColors.lightBlue, width: 1),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: const BorderSide(
//                                       color: AppColors.primaryBlue, width: 2),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       // Get Current Location button
//                       SizedBox(
//                         width: double.infinity,
//                         height: 45,
//                         child: ElevatedButton.icon(
//                           onPressed: _isLocationLoading ? null : _getCurrentLocation,
//                           icon: _isLocationLoading
//                               ? SizedBox(
//                                   height: 20,
//                                   width: 20,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2.0,
//                                     color: Colors.white,
//                                   ),
//                                 )
//                               : Icon(Icons.my_location, size: 18),
//                           label: Text(
//                             appLanguage.get('get_current_location') ?? 'Get Current Location',
//                             style: TextStyle(fontSize: 14),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.secondaryBlue,
//                             foregroundColor: Colors.white,
//                             elevation: 0,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
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
//                               appLanguage.get('save_business') ??
//                                   'Save Business',
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