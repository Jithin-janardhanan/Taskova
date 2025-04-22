import 'package:flutter/material.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined),
                    labelText: 'Email',
                    border: OutlineInputBorder()),
              ),
              TextFormField(
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    
                    labelText: 'Password',
                    border: OutlineInputBorder()),
              )
            ],
          ),
        ),
      ),
    );
  }
}
