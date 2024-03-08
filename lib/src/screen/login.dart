import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/src/screen/forgetpassword.dart';
import 'package:task/src/blocs/Login/login_bloc.dart';
import 'package:task/src/models/login_helper.dart';
import 'package:task/src/models/user.dart';
import 'package:task/src/screen/registration.dart';
import 'package:task/src/utils/message.dart';
import 'package:task/src/widgets/login_fields.dart';
import 'package:task/src/screen/task.dart';

class LoginPage extends StatelessWidget {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final LoginBloc loginBloc = BlocProvider.of<LoginBloc>(context);

    Future<void> _saveUserIdToSharedPreferences(String userId) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userId', userId);
    }

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: BlocListener<LoginBloc, LoginState>(
              listener: (context, state) async {
                if (state is LoginSuccess) {
                  User user = state.user;
                  await _saveUserIdToSharedPreferences(user.id);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskPage(
                        user: user,
                      ),
                    ),
                  );
                } else if (state is LoginFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${Message.LoginFailed} ${state.error}'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', height: 400, width: 260),
                    SizedBox(height: 16),
                    LoginFields(
                      usernameController: _usernameController,
                      passwordController: _passwordController,
                    ),
                    Container(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          final username = _usernameController.text;
                          final password = _passwordController.text;

                          if (username.isNotEmpty && password.isNotEmpty) {
                            UserCredentials credentials = UserCredentials(
                              username: username,
                              password: password,
                            );
                            loginBloc.add(LoginSubmitted(credentials));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(Message.fill),
                              ),
                            );
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue),
                        ),
                        child: Text(
                          Message.Login,
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgetPasswordForm()),
                            );
                          },
                          child: Text(
                            Message.Forget,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegistrationForm()),
                            );
                          },
                          child: Text(
                            Message.account,
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
