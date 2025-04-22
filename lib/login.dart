import 'package:flutter/material.dart';
import 'package:taskova/validator.dart';

import 'applelogi.dart';
import 'registration.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formkey,
            // autovalidateMode: AutovalidateMode.always,
            child: Column(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                    validator: validateEmail,
                    controller: _emailcontroller,
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.email,
                          color: const Color.fromARGB(255, 37, 97, 143),
                        ),
                        border: OutlineInputBorder(),
                        labelText: 'Email')),
                TextFormField(
                  validator: validatePassword,
                  controller: _passwordcontroller,
                  obscureText: true,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock,
                        color: const Color.fromARGB(255, 37, 97, 143),
                      ),
                      border: OutlineInputBorder(),
                      labelText: 'password'),
                ),
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () => (),
                        child: Text(
                          'forget password ? ',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {}
                    },
                    child: Text('Login')),
                ElevatedButton(
                  onPressed: () {
                    handleAppleSignIn(
                        context); // 🎯 call the function from another file
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 37, 97, 143)),
                  child: Text(
                    'apple login',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => Registration(),
                      ),
                    );
                  },
                  child: Text("Create an account"),
                )
              ],
            ),
          )),
    );
  }
}
