import 'package:flutter/material.dart';

class LoginFields extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  LoginFields({
    required this.usernameController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextField(
        controller: usernameController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Username',
          labelStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.white),
          ),
          prefixIcon: Icon(Icons.person, color: Colors.white),
        ),
      ),
      SizedBox(height: 16),
      TextField(
        controller: passwordController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.white),
          ),
          prefixIcon: Icon(Icons.lock, color: Colors.white),
        ),
        obscureText: true,
      ),
      SizedBox(height: 16),
    ]);
  }
}
