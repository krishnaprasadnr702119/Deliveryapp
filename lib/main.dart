import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/src/utils/FirebaseApi.dart';
import 'package:task/src/data/database_helper.dart';
import 'package:task/src/utils/firebase_options.dart';
import 'package:task/src/blocs/Forget_Password/forgetpassword_bloc.dart';
import 'package:task/src/blocs/Login/login_bloc.dart';
import 'package:task/src/screen/login.dart';
import 'package:task/src/screen/splashscreen.dart';
import 'package:task/src/blocs/SignUp/registration_bloc.dart';
import 'package:task/src/blocs/Task/crud_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseApi().initNotification();
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
