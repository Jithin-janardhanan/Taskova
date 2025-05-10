// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:taskova/auth/registration.dart';
// import 'package:taskova/view/business_detial_filling.dart';
// import 'package:taskova/view/bottom_nav.dart';
// import 'package:taskova/Model/colors.dart';
// import 'package:taskova/view/profile.dart';
// import 'package:http/http.dart' as http;
// import 'package:taskova/language/language_provider.dart';

// class ProfileDetailFillingPage extends StatefulWidget {
//   const ProfileDetailFillingPage({Key? key}) : super(key: key);

//   @override
//   State<ProfileDetailFillingPage> createState() =>
//       _ProfileDetailFillingPageState();
// }

// class _ProfileDetailFillingPageState extends State<ProfileDetailFillingPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _businessNameController = TextEditingController();
//   final _businessAddressController = TextEditingController();

//   File? _profileImage;
//   final ImagePicker _picker = ImagePicker();
//   bool _isLoading = false;
//   String? _accessToken;
//   String? _userName;
//   bool _includeBusinessProfile = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _accessToken = prefs.getString('access_token');
//       _userName = prefs.getString('user_name') ?? "";
//       _nameController.text = _userName ?? "";
//     });
//   }

//   Future<void> _pickImage() async {
//     try {
//       final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//       if (image != null) {
//         setState(() {
//           _profileImage = File(image.path);
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

//   Future<void> _submitProfileDetails() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         var headers = {
//           'Authorization': 'Bearer $_accessToken',
//         };

//         var request = http.MultipartRequest('POST',
//             Uri.parse('http://192.168.20.3:8000/api/shopkeeper/profile/'));

//         request.fields.addAll({
//           'personal_profile[phone_number]': _phoneController.text,
//           'personal_profile[name]': _nameController.text,
//           'personal_profile[email]': '', // Add this field if needed
//         });

//         // Add business profile fields if the option is selected
//         if (_includeBusinessProfile) {
//           request.fields.addAll({
//             'business_profile[business_name]': _businessNameController.text,
//             'business_profile[business_address]':
//                 _businessAddressController.text,
//           });
//         }

//         if (_profileImage != null) {
//           request.files.add(await http.MultipartFile.fromPath(
//               'personal_profile[profile_picture]', _profileImage!.path));
//         }

//         request.headers.addAll(headers);

//         final appLanguage = Provider.of<AppLanguage>(context, listen: false);

//         http.StreamedResponse response = await request.send();

//         setState(() {
//           _isLoading = false;
//         });

//         if (response.statusCode == 200 || response.statusCode == 201) {
//           final responseBody = await response.stream.bytesToString();
//           print('Profile updated: $responseBody');

//           // Update stored user name
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString('user_name', _nameController.text);

//           // Show success message
//           _showSnackbar(
//               await appLanguage.translate(
//                   "Profile updated successfully!", appLanguage.currentLanguage),
//               false);

//           // Navigate to profile page
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => BusinessFormPage()),
//           );
//         } else {
//           final errorResponse = await response.stream.bytesToString();
//           print(
//               'Profile update failed: ${response.reasonPhrase}, $errorResponse');

//           // Show error message
//           _showSnackbar(
//               await appLanguage.translate(
//                   "Failed to update profile. Please try again.",
//                   appLanguage.currentLanguage),
//               true);
//         }
//       } catch (e) {
//         setState(() {
//           _isLoading = false;
//         });
//         print("Profile update error: $e");

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
//           appLanguage.get('complete_profile'),
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

//                   // Profile image picker
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
//                           child: _profileImage != null
//                               ? ClipOval(
//                                   child: Image.file(
//                                     _profileImage!,
//                                     width: 120,
//                                     height: 120,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 )
//                               : Icon(
//                                   Icons.person,
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
//                       appLanguage.get('profile_instructions'),
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 30),

//                   // Name field
//                   TextFormField(
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return appLanguage.get('name_required');
//                       }
//                       return null;
//                     },
//                     controller: _nameController,
//                     decoration: InputDecoration(
//                       labelText: appLanguage.get('name'),
//                       hintText: appLanguage.get('enter_full_name'),
//                       prefixIcon: const Icon(
//                         Icons.person_outline,
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

//                   // Phone number field
//                   TextFormField(
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return appLanguage.get('phone_required');
//                       }
//                       return null;
//                     },
//                     controller: _phoneController,
//                     keyboardType: TextInputType.phone,
//                     decoration: InputDecoration(
//                       labelText: appLanguage.get('phone'),
//                       hintText: appLanguage.get('enter_phone'),
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

//                   // Business profile toggle
//                   // SwitchListTile(
//                   //   title: Text(
//                   //     appLanguage.get('include_business_profile'),
//                   //     style: TextStyle(
//                   //       color: AppColors.secondaryBlue,
//                   //       fontWeight: FontWeight.w500,
//                   //     ),
//                   //   ),
//                   //   value: _includeBusinessProfile,
//                   //   onChanged: (bool value) {
//                   //     setState(() {
//                   //       _includeBusinessProfile = value;
//                   //     });
//                   //   },
//                   //   activeColor: AppColors.primaryBlue,
//                   //   contentPadding: EdgeInsets.zero,
//                   // ),

//                   // Business profile fields (conditionally visible)
//                   if (_includeBusinessProfile) ...[
//                     const SizedBox(height: 20),

//                     // Business name field
//                     TextFormField(
//                       validator: (value) {
//                         if (_includeBusinessProfile &&
//                             (value == null || value.isEmpty)) {
//                           return appLanguage.get('business_name_required');
//                         }
//                         return null;
//                       },
//                       controller: _businessNameController,
//                       decoration: InputDecoration(
//                         labelText: appLanguage.get('business_name'),
//                         hintText: appLanguage.get('enter_business_name'),
//                         prefixIcon: const Icon(
//                           Icons.business,
//                           color: AppColors.secondaryBlue,
//                         ),
//                         filled: true,
//                         fillColor: Colors.grey[50],
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(
//                               color: AppColors.lightBlue, width: 1),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(
//                               color: AppColors.primaryBlue, width: 2),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 20),

//                     // Business address field
//                     TextFormField(
//                       validator: (value) {
//                         if (_includeBusinessProfile &&
//                             (value == null || value.isEmpty)) {
//                           return appLanguage.get('business_address_required');
//                         }
//                         return null;
//                       },
//                       controller: _businessAddressController,
//                       maxLines: 2,
//                       decoration: InputDecoration(
//                         labelText: appLanguage.get('business_address'),
//                         hintText: appLanguage.get('enter_business_address'),
//                         prefixIcon: const Padding(
//                           padding: EdgeInsets.only(bottom: 20),
//                           child: Icon(
//                             Icons.location_on_outlined,
//                             color: AppColors.secondaryBlue,
//                           ),
//                         ),
//                         filled: true,
//                         fillColor: Colors.grey[50],
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(
//                               color: AppColors.lightBlue, width: 1),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(
//                               color: AppColors.primaryBlue, width: 2),
//                         ),
//                       ),
//                     ),
//                   ],

//                   const SizedBox(height: 40),

//                   // Submit button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 55,
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _submitProfileDetails,
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
//                               appLanguage.get('save_profile'),
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
//                       appLanguage.get('skip_for_now'),
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
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskova/auth/registration.dart';
import 'package:taskova/view/business_detial_filling.dart';
import 'package:taskova/view/bottom_nav.dart';
import 'package:taskova/Model/colors.dart';
import 'package:taskova/view/profile.dart';
import 'package:http/http.dart' as http;
import 'package:taskova/language/language_provider.dart';

class ProfileDetailFillingPage extends StatefulWidget {
  const ProfileDetailFillingPage({Key? key}) : super(key: key);

  @override
  State<ProfileDetailFillingPage> createState() =>
      _ProfileDetailFillingPageState();
}

class _ProfileDetailFillingPageState extends State<ProfileDetailFillingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _accessToken;
  String? _userName;
  bool _includeBusinessProfile = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accessToken = prefs.getString('access_token');
      _userName = prefs.getString('user_name') ?? "";
      _nameController.text = _userName ?? "";
      print("Loaded access_token: $_accessToken");
      print("Loaded user_name: $_userName");
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final File imageFile = File(image.path);
        if (await imageFile.exists()) {
          print("Image selected: ${image.path}");
          setState(() {
            _profileImage = imageFile;
          });
        } else {
          print("Error: Selected image file does not exist at ${image.path}");
          _showSnackbar("Selected image is invalid.", true);
        }
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Error picking image: $e");
      _showSnackbar("Failed to pick image. Please try again.", true);
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

  Future<void> _submitProfileDetails() async {
    if (_formKey.currentState!.validate()) {
      if (_accessToken == null || _accessToken!.isEmpty) {
        print("Error: No access token available");
        _showSnackbar("Please log in again.", true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Registration()),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        var headers = {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'multipart/form-data',
        };

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://192.168.20.3:8000/api/shopkeeper/profile/'),
        );

        // Add personal profile fields
        var personalProfileFields = {
          'personal_profile[phone_number]': _phoneController.text,
          'personal_profile[name]': _nameController.text,
          'personal_profile[email]': '', // Adjust if backend requires email
        };
        request.fields.addAll(personalProfileFields);

        // Add business profile fields if selected
        if (_includeBusinessProfile) {
          var businessProfileFields = {
            'business_profile[business_name]': _businessNameController.text,
            'business_profile[business_address]':
                _businessAddressController.text,
          };
          request.fields.addAll(businessProfileFields);
        }

        // Add profile picture if selected
        if (_profileImage != null) {
          var profilePicture = await http.MultipartFile.fromPath(
            'personal_profile[profile_picture]', // Adjust field name if needed
            _profileImage!.path,
          );
          request.files.add(profilePicture);
          print("Added profile picture: ${_profileImage!.path}");
        }

        request.headers.addAll(headers);
        print("Request fields: ${request.fields}");
        print("Request files: ${request.files.map((f) => f.field).toList()}");

        final appLanguage = Provider.of<AppLanguage>(context, listen: false);

        http.StreamedResponse response = await request.send();
        final responseBody = await response.stream.bytesToString();

        setState(() {
          _isLoading = false;
        });

        print("Response status: ${response.statusCode}");
        print("Response body: $responseBody");

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('Profile updated successfully');

          // Update stored user name
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_name', _nameController.text);
          

          // Show success message
          _showSnackbar(
              await appLanguage.translate(
                  "Profile updated successfully!", appLanguage.currentLanguage),
              false);

          // Navigate to business form page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BusinessFormPage()),
          );
        } else {
          print(
              'Profile update failed: ${response.statusCode} ${response.reasonPhrase}');
          print('Error response: $responseBody');

          // Show error message
          _showSnackbar(
              await appLanguage.translate(
                  "Failed to update profile: ${response.reasonPhrase}",
                  appLanguage.currentLanguage),
              true);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print("Profile update error: $e");

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
          appLanguage.get('complete_profile'),
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

                  // Profile image picker
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
                          child: _profileImage != null
                              ? ClipOval(
                                  child: Image.file(
                                    _profileImage!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print("Image load error: $error");
                                      return Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey[400],
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.person,
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
                      appLanguage.get('profile_instructions'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Name field
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return appLanguage.get('name_required');
                      }
                      return null;
                    },
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: appLanguage.get('name'),
                      hintText: appLanguage.get('enter_full_name'),
                      prefixIcon: const Icon(
                        Icons.person_outline,
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

                  // Phone number field
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return appLanguage.get('phone_required');
                      }
                      return null;
                    },
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: appLanguage.get('phone'),
                      hintText: appLanguage.get('enter_phone'),
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

                  // // Business profile toggle (commented out as in original)
                  // SwitchListTile(
                  //   title: Text(
                  //     appLanguage.get('include_business_profile'),
                  //     style: TextStyle(
                  //       color: AppColors.secondaryBlue,
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //   ),
                  //   value: _includeBusinessProfile,
                  //   onChanged: (bool value) {
                  //     setState(() {
                  //       _includeBusinessProfile = value;
                  //     });
                  //   },
                  //   activeColor: AppColors.primaryBlue,
                  //   contentPadding: EdgeInsets.zero,
                  // ),

                  // // Business profile fields (conditionally visible)
                  // if (_includeBusinessProfile) ...[
                  //   const SizedBox(height: 20),

                  //   // Business name field
                  //   TextFormField(
                  //     validator: (value) {
                  //       if (_includeBusinessProfile &&
                  //           (value == null || value.isEmpty)) {
                  //         return appLanguage.get('business_name_required');
                  //       }
                  //       return null;
                  //     },
                  //     controller: _businessNameController,
                  //     decoration: InputDecoration(
                  //       labelText: appLanguage.get('business_name'),
                  //       hintText: appLanguage.get('enter_business_name'),
                  //       prefixIcon: const Icon(
                  //         Icons.business,
                  //         color: AppColors.secondaryBlue,
                  //       ),
                  //       filled: true,
                  //       fillColor: Colors.grey[50],
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //         borderSide: BorderSide.none,
                  //       ),
                  //       enabledBorder: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //         borderSide: const BorderSide(
                  //             color: AppColors.lightBlue, width: 1),
                  //       ),
                  //       focusedBorder: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //         borderSide: const BorderSide(
                  //             color: AppColors.primaryBlue, width: 2),
                  //       ),
                  //     ),
                  //   ),

                  //   const SizedBox(height: 20),

                  //   // Business address field
                  //   TextFormField(
                  //     validator: (value) {
                  //       if (_includeBusinessProfile &&
                  //           (value == null || value.isEmpty)) {
                  //         return appLanguage.get('business_address_required');
                  //       }
                  //       return null;
                  //     },
                  //     controller: _businessAddressController,
                  //     maxLines: 2,
                  //     decoration: InputDecoration(
                  //       labelText: appLanguage.get('business_address'),
                  //       hintText: appLanguage.get('enter_business_address'),
                  //       prefixIcon: const Padding(
                  //         padding: EdgeInsets.only(bottom: 20),
                  //         child: Icon(
                  //           Icons.location_on_outlined,
                  //           color: AppColors.secondaryBlue,
                  //         ),
                  //       ),
                  //       filled: true,
                  //       fillColor: Colors.grey[50],
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //         borderSide: BorderSide.none,
                  //       ),
                  //       enabledBorder: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //         borderSide: const BorderSide(
                  //             color: AppColors.lightBlue, width: 1),
                  //       ),
                  //       focusedBorder: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //         borderSide: const BorderSide(
                  //             color: AppColors.primaryBlue, width: 2),
                  //       ),
                  //     ),
                  //   ),
                  // ],

                  const SizedBox(height: 40),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitProfileDetails,
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
                              appLanguage.get('save_profile'),
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
                      appLanguage.get('skip_for_now'),
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