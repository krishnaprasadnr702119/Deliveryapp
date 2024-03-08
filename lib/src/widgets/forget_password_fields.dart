import 'package:flutter/material.dart';
import 'package:task/src/blocs/Forget_Password/forgetpassword_bloc.dart';
import 'package:task/src/data/database_helper.dart';
import 'package:task/src/models/user.dart';
import 'package:task/src/widgets/password_custom_text_field.dart';

class ForgetPasswordFields extends StatefulWidget {
  final ForgetPasswordBloc forgetPasswordBloc;

  const ForgetPasswordFields({required this.forgetPasswordBloc});

  @override
  _ForgetPasswordFieldsState createState() => _ForgetPasswordFieldsState();
}

class _ForgetPasswordFieldsState extends State<ForgetPasswordFields> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isUsernameAndEmailValid = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: _usernameController,
          labelText: 'Username',
          onChanged: (_) => _validateUsernameAndEmail(),
        ),
        SizedBox(height: 16),
        CustomTextField(
          controller: _emailController,
          labelText: 'Email',
          onChanged: (_) => _validateUsernameAndEmail(),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16),
        if (_isUsernameAndEmailValid) ...[
          CustomTextField(
            controller: _passwordController,
            labelText: 'New Password',
            obscureText: true,
          ),
          SizedBox(height: 16),
          CustomTextField(
            controller: _confirmPasswordController,
            labelText: 'Confirm Password',
            obscureText: true,
          ),
          SizedBox(height: 16),
        ],
        Container(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _resetPassword(widget.forgetPasswordBloc),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            child: Text(
              'Reset Password',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _validateUsernameAndEmail() {
    setState(() {
      _isUsernameAndEmailValid = _usernameController.text.trim().isNotEmpty &&
          _emailController.text.trim().isNotEmpty;
    });
  }

  bool _isPasswordValid(String password) {
    // Password should have at least 6 characters,
    // 1 uppercase letter, 1 lowercase letter, and 1 symbol.
    final RegExp passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+])[a-zA-Z\d!@#$%^&*()_+]{6,}$');
    return passwordRegex.hasMatch(password);
  }

  void _resetPassword(ForgetPasswordBloc forgetPasswordBloc) {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (_isUsernameAndEmailValid &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty) {
      if (password == confirmPassword) {
        // Check if the username is associated with the provided email
        _checkUsernameAssociation(username, email, forgetPasswordBloc);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passwords do not match.'),
          ),
        );
        _clearTextFields();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
      _clearTextFields();
    }
  }

  void _clearTextFields() {
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  void _checkUsernameAssociation(
      String username, String email, ForgetPasswordBloc forgetPasswordBloc) {
    // Check if the username is associated with the provided email
    AppDatabase yourDatabaseHelper = AppDatabase();
    yourDatabaseHelper.initDatabase().then((_) async {
      bool isAssociated =
          await yourDatabaseHelper.usernamandemail(username, email);
      if (isAssociated) {
        if (_isPasswordValid(_passwordController.text.trim())) {
          User forgetUser = User(
            id: User.generateUserId(),
            username: username,
            email: email,
            password: _passwordController.text.trim(),
          );
          forgetPasswordBloc.add(ForgetPasswordSubmitted(forgetUser));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Password must have at least 6 characters, 1 uppercase, 1 lowercase, and 1 symbol.',
              ),
            ),
          );
          _clearTextFields();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Username is not associated with the provided email.'),
          ),
        );
        _clearTextFields();
      }
    });
  }
}
