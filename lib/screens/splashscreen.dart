import 'package:flutter/material.dart';
import 'package:task/login/screen/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigatetohome();
  }

  _navigatetohome() async {
    await Future.delayed(const Duration(milliseconds: 3000), () {});
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 200, // Specify the width of the logo
          height: 200, // Specify the height of the logo
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/amazon.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
