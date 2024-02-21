import 'package:flutter/material.dart';
import 'custom_text_field.dart';

class RegistrationFields extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const RegistrationFields({
    Key? key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: usernameController,
          label: 'Username',
        ),
        SizedBox(height: 16),
        CustomTextField(
          controller: emailController,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16),
        CustomTextField(
          controller: passwordController,
          label: 'Password',
          obscureText: true,
        ),
        SizedBox(height: 16),
        CustomTextField(
          controller: confirmPasswordController,
          label: 'Confirm Password',
          obscureText: true,
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
