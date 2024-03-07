import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/FirebaseApi.dart';
import 'package:task/data/database_helper.dart';
import 'package:task/src/forgetpassword/forgetpassword_bloc.dart';
import 'package:task/src/login/bloc/login_bloc.dart';
import 'package:task/src/screen/login.dart';
import 'package:task/src/screen/splashscreen.dart';
import 'package:task/src/signup/bloc/registration_bloc.dart';
import 'package:task/task/bloc/bloc/crud_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // await FirebaseApi().initNotification();
  var status = await Permission.location.request();

  if (status.isGranted) {
    await AppDatabase().initDatabase();
    runApp(MyApp());
  } else {
    print('Location permission is denied');
  }
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
