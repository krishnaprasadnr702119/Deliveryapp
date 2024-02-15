import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/forgetpassword/screen/bloc/forgetpassword_bloc.dart';
import 'package:task/models/user.dart';

class ForgetPasswordForm extends StatelessWidget {
  final _usernameController = TextEditingController(); // Add this line
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ForgetPasswordBloc forgetPasswordBloc =
        BlocProvider.of<ForgetPasswordBloc>(context);

    return Scaffold(
        backgroundColor: Colors.grey[200],
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/background.jpg'), // Replace with your actual image path
                fit: BoxFit.cover,
              ),
            ),
            child: BlocListener<ForgetPasswordBloc, ForgetPasswordState>(
              listener: (context, state) {
                if (state is ForgetPasswordSuccess) {
                  // Show Snackbar after a successful Forget Password
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Forget Password successful!'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green),
                  );
                } else if (state is ForgetPasswordFailure) {
                  // Show Snackbar for Forget Password failure
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Forget Password failed: ${state.error}'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', height: 280, width: 280),
                    SizedBox(height: 16),
                    TextField(
                      controller: _usernameController, // Add this line
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Username', // Update field label
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          final username = _usernameController.text.trim();
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();
                          final confirmPassword =
                              _confirmPasswordController.text.trim();

                          if (username.isNotEmpty &&
                              email.isNotEmpty &&
                              password.isNotEmpty &&
                              confirmPassword.isNotEmpty) {
                            if (password == confirmPassword) {
                              User forgetUser = User(
                                id: User.generateUserId(),
                                username: username,
                                email: email,
                                password: password,
                              );
                              forgetPasswordBloc
                                  .add(ForgetPasswordSubmitted(forgetUser));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Passwords do not match.'),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please fill in all fields.'),
                              ),
                            );
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue),
                        ),
                        child: Text(
                          'Reset Password',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
