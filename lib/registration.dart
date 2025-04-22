import 'package:flutter/material.dart';

import 'login.dart';
import 'validator.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();
  bool _visiblepassword = false;

  @override
  void initState() {
    super.initState();
    _visiblepassword = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailcontroller,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined),
                      labelText: 'Email',
                      border: OutlineInputBorder()),
                ),
                TextFormField(
                  validator: validatePassword,
                  controller: _passwordcontroller,
                  obscureText: !_visiblepassword,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          _visiblepassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          setState(() {
                            _visiblepassword = !_visiblepassword;
                          });
                        },
                      ),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: const Color.fromARGB(255, 37, 97, 143),
                      ),
                      border: OutlineInputBorder(),
                      labelText: 'password'),
                ),
                TextFormField(
                  obscureText: true,
                  controller: _confirmPass,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Empty';
                    if (val != _passwordcontroller.text) return 'Not Match';
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    labelText: 'Confirm password',
                    border: OutlineInputBorder(),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {},
                  child: Text('Register'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have account ?'),
                    TextButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Login()));
                        },
                        child: Text('Login')),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
