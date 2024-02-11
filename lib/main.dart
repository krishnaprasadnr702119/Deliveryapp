import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/data/database_helper.dart';
import 'package:task/forgetpassword/screen/bloc/forgetpassword_bloc.dart';
import 'package:task/login/screen/login.dart'; // Import your LoginPage here
import 'package:task/login/bloc/login_bloc.dart';
import 'package:task/signup/bloc/registration_bloc.dart';
import 'package:task/screens/splashscreen.dart';
import 'package:task/task/bloc/bloc/crud_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase().initDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RegistrationBloc>(
          create: (BuildContext context) => RegistrationBloc(),
        ),
        BlocProvider<LoginBloc>(
          create: (BuildContext context) => LoginBloc(),
        ),
        BlocProvider<ForgetPasswordBloc>(
          create: (BuildContext context) => ForgetPasswordBloc(),
        ),
        BlocProvider<CrudBloc>(
          create: (BuildContext context) => CrudBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (context) => SplashScreen());
            case '/login':
              return MaterialPageRoute(builder: (context) => LoginPage());
            default:
              return MaterialPageRoute(builder: (context) => SplashScreen());
          }
        },
      ),
    );
  }
}
