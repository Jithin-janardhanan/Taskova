// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:taskova/colors.dart';
// import 'package:taskova/Model/api_config.dart';
// import 'package:http/http.dart' as http;
// import 'package:taskova/auth/login.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({Key? key}) : super(key: key);

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   bool _isLoading = true;
//   String _name = '';
//   String _email = '';
//   String _role = '';
//   String _profileImage = '';
//   String? _accessToken;
//   String? _errorMessage;
//   bool _isEditing = false;

//   final TextEditingController _nameController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadProfileData();
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadProfileData() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = null;
//       });

//       // Get access token from SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       _accessToken = prefs.getString('access_token');

//       if (_accessToken == null) {
//         setState(() {
//           _errorMessage = 'Not logged in. Please login again.';
//           _isLoading = false;
//         });
//         return;
//       }

//       // Fetch profile data from API
//       final response = await http.get(
//         Uri.parse('${ApiConfig.baseUrl}/api/profile/'),
//         headers: {
//           'Authorization': 'Bearer $_accessToken',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _name = data['name'] ?? 'User';
//           _email = data['email'] ?? '';
//           _role = data['role'] ?? 'User';
//           _profileImage = data['profile_image'] ?? '';
//           _nameController.text = _name;
//           _isLoading = false;
//         });
//       } else if (response.statusCode == 401) {
//         // Token expired or invalid
//         await _refreshToken();
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to load profile data';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Connection error. Please check your internet.';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _refreshToken() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final refreshToken = prefs.getString('refresh_token');

//       if (refreshToken == null) {
//         _logout();
//         return;
//       }

//       final response = await http.post(
//         Uri.parse('${ApiConfig.baseUrl}/api/token/refresh/'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'refresh': refreshToken}),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         await prefs.setString('access_token', data['access']);
//         _accessToken = data['access'];
//         // Try loading profile again with new token
//         _loadProfileData();
//       } else {
//         _logout();
//       }
//     } catch (e) {
//       _logout();
//     }
//   }

//   void _logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('access_token');
//     await prefs.remove('refresh_token');
//     await prefs.remove('user_email');
//     await prefs.remove('user_name');

//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (context) => const Login()),
//       (route) => false,
//     );
//   }

//   Future<void> _updateProfile() async {
//     if (_nameController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Name cannot be empty')),
//       );
//       return;
//     }

//     try {
//       setState(() {
//         _isLoading = true;
//       });

//       final response = await http.patch(
//         Uri.parse('${ApiConfig.baseUrl}/api/profile/update/'),
//         headers: {
//           'Authorization': 'Bearer $_accessToken!',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'name': _nameController.text,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _name = data['name'] ?? _name;
//           _isLoading = false;
//           _isEditing = false;
//         });

//         // Update stored name
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('user_name', _name);

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Profile updated successfully')),
//         );
//       } else if (response.statusCode == 401) {
//         await _refreshToken();
//         // We'll try again after token refresh
//       } else {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = 'Failed to update profile';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Connection error';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           'My Profile',
//           style: TextStyle(
//             color: AppColors.primaryBlue,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout, color: AppColors.secondaryBlue),
//             onPressed: () => _showLogoutConfirmationDialog(),
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(
//               child: CircularProgressIndicator(color: AppColors.primaryBlue),
//             )
//           : _errorMessage != null
//               ? _buildErrorView()
//               : RefreshIndicator(
//                   onRefresh: _loadProfileData,
//                   child: SingleChildScrollView(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           _buildProfileHeader(),
//                           const SizedBox(height: 30),
//                           _buildProfileInfo(),
//                           const SizedBox(height: 30),
//                           _buildActionButtons(),
//                           const SizedBox(height: 30),
//                           _buildSettingsSection(),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//     );
//   }

//   Widget _buildErrorView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.error_outline,
//             size: 80,
//             color: Colors.red,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             _errorMessage!,
//             style: const TextStyle(fontSize: 16),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: _loadProfileData,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primaryBlue,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             ),
//             child: const Text('Retry'),
//           ),
//           const SizedBox(height: 12),
//           TextButton(
//             onPressed: _logout,
//             child: const Text(
//               'Log Out',
//               style: TextStyle(color: AppColors.secondaryBlue),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfileHeader() {
//     return Column(
//       children: [
//         Stack(
//           children: [
//             CircleAvatar(
//               radius: 65,
//               backgroundColor: AppColors.lightBlue,
//               child: _profileImage.isNotEmpty
//                   ? ClipRRect(
//                       borderRadius: BorderRadius.circular(65),
//                       child: Image.network(
//                         _profileImage,
//                         width: 130,
//                         height: 130,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return const Icon(
//                             Icons.person,
//                             size: 70,
//                             color: AppColors.primaryBlue,
//                           );
//                         },
//                       ),
//                     )
//                   : const Icon(
//                       Icons.person,
//                       size: 70,
//                       color: AppColors.primaryBlue,
//                     ),
//             ),
//             Positioned(
//               bottom: 0,
//               right: 0,
//               child: Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: const BoxDecoration(
//                   color: AppColors.primaryBlue,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.camera_alt,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         _isEditing
//             ? TextField(
//                 controller: _nameController,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primaryBlue,
//                 ),
//                 decoration: const InputDecoration(
//                   isDense: true,
//                   border: UnderlineInputBorder(),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
//                   ),
//                 ),
//               )
//             : Text(
//                 _name,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primaryBlue,
//                 ),
//               ),
//         const SizedBox(height: 4),
//         Text(
//           _email,
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.grey[600],
//           ),
//         ),
//         Container(
//           margin: const EdgeInsets.symmetric(vertical: 10),
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: BoxDecoration(
//             color: AppColors.lightBlue.withOpacity(0.3),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             _role,
//             style: const TextStyle(
//               color: AppColors.primaryBlue,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildProfileInfo() {
//     return Card(
//       elevation: 2,
//       shadowColor: Colors.black26,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Account Information',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.primaryBlue,
//               ),
//             ),
//             const Divider(height: 24),
//             _buildInfoRow(Icons.email_outlined, 'Email', _email),
//             const SizedBox(height: 16),
//             _buildInfoRow(Icons.badge_outlined, 'Role', _role),
//             const SizedBox(height: 16),
//             _buildInfoRow(
//               Icons.calendar_today_outlined,
//               'Member Since',
//               'January 2023', // This should come from your API
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: AppColors.lightBlue.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             icon,
//             color: AppColors.secondaryBlue,
//             size: 20,
//           ),
//         ),
//         const SizedBox(width: 16),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//               ),
//             ),
//             Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButtons() {
//     if (_isEditing) {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ElevatedButton(
//             onPressed: _updateProfile,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primaryBlue,
//               foregroundColor: Colors.white,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//             ),
//             child: const Text('Save Changes'),
//           ),
//           const SizedBox(width: 16),
//           OutlinedButton(
//             onPressed: () {
//               setState(() {
//                 _isEditing = false;
//                 _nameController.text = _name; // Reset to original value
//               });
//             },
//             style: OutlinedButton.styleFrom(
//               foregroundColor: AppColors.secondaryBlue,
//               side: const BorderSide(color: AppColors.secondaryBlue),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//             ),
//             child: const Text('Cancel'),
//           ),
//         ],
//       );
//     } else {
//       return SizedBox(
//         width: double.infinity,
//         child: ElevatedButton.icon(
//           onPressed: () {
//             setState(() {
//               _isEditing = true;
//             });
//           },
//           icon: const Icon(Icons.edit),
//           label: const Text('Edit Profile'),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.primaryBlue,
//             foregroundColor: Colors.white,
//             elevation: 0,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             padding: const EdgeInsets.symmetric(vertical: 12),
//           ),
//         ),
//       );
//     }
//   }

//   Widget _buildSettingsSection() {
//     return Card(
//       elevation: 2,
//       shadowColor: Colors.black26,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Settings',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.primaryBlue,
//               ),
//             ),
//             const Divider(height: 24),
//             _buildSettingItem(
//               Icons.notifications_outlined,
//               'Notifications',
//               'Manage your notification preferences',
//               () {},
//             ),
//             _buildSettingItem(
//               Icons.lock_outline,
//               'Change Password',
//               'Update your password',
//               () {},
//             ),
//             _buildSettingItem(
//               Icons.language,
//               'Language',
//               'Change your preferred language',
//               () {},
//             ),
//             _buildSettingItem(
//               Icons.help_outline,
//               'Help & Support',
//               'Get help or contact support',
//               () {},
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSettingItem(
//     IconData icon,
//     String title,
//     String subtitle,
//     VoidCallback onTap,
//   ) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(10),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 12.0),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: AppColors.lightBlue.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 icon,
//                 color: AppColors.secondaryBlue,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(
//               Icons.chevron_right,
//               color: AppColors.secondaryBlue,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showLogoutConfirmationDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Log Out'),
//         content: const Text('Are you sure you want to log out?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               'Cancel',
//               style: TextStyle(color: Colors.grey),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _logout();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primaryBlue,
//             ),
//             child: const Text('Log Out'),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskova/Model/colors.dart';
import 'package:taskova/Model/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:taskova/auth/login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskova/auth/logout.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  String _name = 'User';
  String _email = '';
  String _role = 'SHOPKEEPER';
  String? _accessToken;
  String? _errorMessage;
  bool _isEditingName = false;
  final TextEditingController _nameController = TextEditingController();

  // Additional user info
  String _joinDate = 'April 2025';
  int _tasksCompleted = 0;
  bool _emailVerified = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access_token');

      if (_accessToken == null) {
        // If no token found, just load data from sharedPreferences
        _name = prefs.getString('user_name') ?? 'User';
        _email = prefs.getString('user_email') ?? '';

        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Try to fetch user data from API
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user/profile/'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _name = data['name'] ?? prefs.getString('user_name') ?? 'User';
          _email = data['email'] ?? prefs.getString('user_email') ?? '';
          _role = data['role'] ?? 'SHOPKEEPER';
          _tasksCompleted = data['tasks_completed'] ?? 0;
          _emailVerified = data['email_verified'] ?? false;
          if (data['join_date'] != null) {
            _joinDate = data['join_date'];
          }

          _nameController.text = _name;
          _isLoading = false;
        });

        // Update stored values
        await prefs.setString('user_name', _name);
        await prefs.setString('user_email', _email);
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        final success = await _refreshToken();
        if (success) {
          _loadUserData(); // Retry with new token
        } else {
          setState(() {
            // Fall back to stored data
            _name = prefs.getString('user_name') ?? 'User';
            _email = prefs.getString('user_email') ?? '';
            _nameController.text = _name;
            _isLoading = false;
          });
        }
      } else {
        // API error but we can still show cached data
        setState(() {
          _name = prefs.getString('user_name') ?? 'User';
          _email = prefs.getString('user_email') ?? '';
          _nameController.text = _name;
          _isLoading = false;
          _errorMessage = 'Could not update profile from server';
        });
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        // Fall back to stored data on error
        _name = prefs.getString('user_name') ?? 'User';
        _email = prefs.getString('user_email') ?? '';
        _nameController.text = _name;
        _isLoading = false;
        _errorMessage = 'Connection error. Using saved profile data.';
      });
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access'];
        await prefs.setString('access_token', _accessToken!);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }

    try {
      setState(() => _isLoading = true);

      // First try to update on server if we have token
      if (_accessToken != null) {
        try {
          final response = await http
              .patch(
                Uri.parse('${ApiConfig.baseUrl}/api/user/profile/update/'),
                headers: {
                  'Authorization': 'Bearer $_accessToken',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  'name': _nameController.text,
                }),
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            _name = data['name'] ?? _nameController.text;
          } else if (response.statusCode == 401) {
            // Try to refresh token and update again
            final refreshed = await _refreshToken();
            if (refreshed) {
              await _updateProfile();
              return;
            }
          }
        } catch (e) {
          // If API update fails, just continue with local update
          print("API update failed: $e");
        }
      }

      // Always update locally regardless of API result
      _name = _nameController.text;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _name);

      setState(() {
        _isEditingName = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated'),
          backgroundColor: AppColors.secondaryBlue,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _logout() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Perform logout
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');

    // Keep email and name for convenience on next login

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Here you would upload the image to your server
        // For now we just show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Profile image selected. Upload feature coming soon!'),
            backgroundColor: AppColors.secondaryBlue,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not access gallery'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.secondaryBlue),
            onPressed: () {
              LogoutService().logout(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: Colors.amber),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style:
                                      TextStyle(color: Colors.amber.shade900),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () {
                                  setState(() {
                                    _errorMessage = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      _buildProfileHeader(),
                      const SizedBox(height: 24),
                      _buildProfileStats(),
                      const SizedBox(height: 24),
                      _buildAccountDetails(),
                      const SizedBox(height: 24),
                      _buildSettingsSection(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.lightBlue,
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: AppColors.primaryBlue,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: InkWell(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name (editable)
          if (_isEditingName)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: 'Enter your name',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: _updateProfile,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _isEditingName = false;
                      _nameController.text = _name;
                    });
                  },
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () {
                    setState(() {
                      _isEditingName = true;
                      _nameController.text = _name;
                    });
                  },
                ),
              ],
            ),
          Text(
            _email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified,
                  size: 16,
                  color: _emailVerified ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  _role,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.calendar_today, _joinDate, 'Joined'),
          const VerticalDivider(thickness: 1),
          _buildStatItem(Icons.task_alt, '$_tasksCompleted', 'Tasks'),
          const VerticalDivider(thickness: 1),
          _buildStatItem(Icons.verified_user,
              _emailVerified ? 'Verified' : 'Pending', 'Status'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.secondaryBlue,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailItem(Icons.email, 'Email Address', _email),
          const Divider(),
          _buildDetailItem(Icons.badge, 'Role', _role),
          const Divider(),
          _buildDetailItem(
            Icons.verified_user,
            'Email Verification',
            _emailVerified ? 'Verified' : 'Not Verified',
            trailing: _emailVerified
                ? const Icon(Icons.check_circle, color: Colors.green)
                : TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verification email sent!'),
                        ),
                      );
                    },
                    child: const Text('Verify Now'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.secondaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            Icons.lock_outline,
            'Change Password',
            'Update your account password',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Change password feature coming soon')),
              );
            },
          ),
          _buildSettingItem(
            Icons.notifications_outlined,
            'Notifications',
            'Manage your notification preferences',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Notification settings coming soon')),
              );
            },
          ),
          _buildSettingItem(
            Icons.language,
            'Language',
            'Change your preferred language',
            onTap: () {
              Navigator.of(context).pushNamed('/language');
            },
          ),
          _buildSettingItem(
            Icons.help_outline,
            'Help & Support',
            'Get help or contact support',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Support center coming soon')),
              );
            },
          ),
          _buildSettingItem(
            Icons.logout,
            'Logout',
            'Sign out from your account',
            textColor: Colors.red,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle, {
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.lightBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: textColor ?? AppColors.secondaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: textColor ?? AppColors.secondaryBlue,
            ),
          ],
        ),
      ),
    );
  }
}
