// import 'package:flutter/material.dart';

// import 'login.dart';
// import 'validator.dart';

// class Registration extends StatefulWidget {
//   const Registration({super.key});

//   @override
//   State<Registration> createState() => _RegistrationState();
// }

// class _RegistrationState extends State<Registration> {
//   final _emailcontroller = TextEditingController();
//   final _passwordcontroller = TextEditingController();
//   final TextEditingController _confirmPass = TextEditingController();
//   bool _visiblepassword = false;

//   @override
//   void initState() {
//     super.initState();
//     _visiblepassword = false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Container(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               spacing: 20,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 TextFormField(
//                   controller: _emailcontroller,
//                   decoration: InputDecoration(
//                       prefixIcon: Icon(Icons.email_outlined),
//                       labelText: 'Email',
//                       border: OutlineInputBorder()),
//                 ),
//                 TextFormField(
//                   validator: validatePassword,
//                   controller: _passwordcontroller,
//                   obscureText: !_visiblepassword,
//                   decoration: InputDecoration(
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           // Based on passwordVisible state choose the icon
//                           _visiblepassword
//                               ? Icons.visibility
//                               : Icons.visibility_off,
//                           color: Theme.of(context).primaryColorDark,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _visiblepassword = !_visiblepassword;
//                           });
//                         },
//                       ),
//                       prefixIcon: Icon(
//                         Icons.lock,
//                         color: const Color.fromARGB(255, 37, 97, 143),
//                       ),
//                       border: OutlineInputBorder(),
//                       labelText: 'password'),
//                 ),
//                 TextFormField(
//                   obscureText: true,
//                   controller: _confirmPass,
//                   validator: (val) {
//                     if (val == null || val.isEmpty) return 'Empty';
//                     if (val != _passwordcontroller.text) return 'Not Match';
//                     return null;
//                   },
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(Icons.lock),
//                     labelText: 'Confirm password',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     foregroundColor: Colors.white,
//                   ),
//                   onPressed: () {},
//                   child: Text('Register'),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text('Already have account ?'),
//                     TextButton(
//                         onPressed: () {
//                           Navigator.push(context,
//                               MaterialPageRoute(builder: (context) => Login()));
//                         },
//                         child: Text('Login')),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:taskova/colors.dart';
import 'login.dart';
import 'validator.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();
  bool _visiblePassword = false;

  @override
  void initState() {
    super.initState();
    _visiblePassword = false;
  }

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 60),
                  // App Logo
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon( 
                      Icons.app_registration_rounded,
                      size: 60,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // App name
                  const Text(
                    'Join Taskova',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Tagline
                  const Text(
                    'Create an account to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: validatePassword,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      prefixIcon: const Icon(
                        Icons.person_add,
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: validatePassword,
                    decoration: InputDecoration(
                      hintText: 'Email address',
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_visiblePassword,
                    validator: validatePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.secondaryBlue,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _visiblePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.secondaryBlue,
                        ),
                        onPressed: () {
                          setState(() {
                            _visiblePassword = !_visiblePassword;
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Confirm Password field
                  TextFormField(
                    controller: _confirmPass,
                    obscureText: true,
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return 'Confirm password is required';
                      if (val != _passwordController.text)
                        return 'Passwords do not match';
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Confirm password',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Register button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Registration logic
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
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Login(),
                            ),
                          );
                        },
                        child: const Text(
                          'Log In',
                          style: TextStyle(
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
}
