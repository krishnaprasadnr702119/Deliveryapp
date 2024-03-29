import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/src/data/database_helper.dart';
import 'package:task/src/models/user.dart';
import 'package:task/src/blocs/SignUp/registration_bloc.dart';
import 'package:task/src/utils/message.dart';
import 'package:task/src/widgets/registration_fields.dart';

class RegistrationForm extends StatelessWidget {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final RegistrationBloc registrationBloc =
        BlocProvider.of<RegistrationBloc>(context);

    void _clearFields() {
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: BlocListener<RegistrationBloc, RegistrationState>(
            listener: (context, state) {
              if (state is RegistrationSuccess) {
                // Show Snackbar after a successful registration
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(Message.RegistrationSucces),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ),
                );
                // Clear fields after successful registration
                _clearFields();
              } else if (state is RegistrationFailure) {
                // Show Snackbar for registration failure
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('${Message.RegistrationFailed} ${state.error}'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', height: 390, width: 280),
                  SizedBox(height: 8),
                  RegistrationFields(
                    usernameController: _usernameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                  ),
                  SizedBox(height: size.height * 0.02),
                  Column(
                    children: [
                      Center(
                        child: Container(
                          width: double.infinity,
                          height: size.height * 0.07,
                          child: ElevatedButton(
                            onPressed: () async {
                              final username = _usernameController.text;
                              final email = _emailController.text;
                              final password = _passwordController.text;
                              final confirmPassword =
                                  _confirmPasswordController.text;

                              final validationMessage =
                                  Message.validateRegistrationFields(
                                username,
                                email,
                                password,
                                confirmPassword,
                              );

                              if (validationMessage == null) {
                                // Continue with registration logic
                                final existingUser =
                                    await AppDatabase().getUserByEmail(email);

                                if (existingUser == null) {
                                  User user = User(
                                    id: User.generateUserId(),
                                    email: email,
                                    username: username,
                                    password: password,
                                  );
                                  registrationBloc
                                      .add(RegistrationSubmitted(user));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(Message.UserExist),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                // Display validation message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(validationMessage),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }

                              // Clear fields after registration attempt
                              _clearFields();
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blue),
                            ),
                            child: Text(
                              Message.Register,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
