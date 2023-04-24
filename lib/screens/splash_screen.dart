// ignore_for_file: use_build_context_synchronously

import 'package:assessment/screens/home_screen.dart';
import 'package:assessment/screens/login_screen.dart';
import 'package:assessment/services/local_db_service.dart';
import 'package:assessment/services/user_service.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    checkForUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Login With Phone'),
            SizedBox(
              height: 20,
            ),
            CircularProgressIndicator(
              color: Colors.black,
            )
          ],
        ),
      ),
    );
  }

  /// Checking if there is already a user in the local DB or not
  void checkForUser() async {
    final user = await LocalDBService().getUser();

    if (user != null) {
      await UserService().syncOrCreateUserAccount(user: user);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(user: user),
          ));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ));
    }
  }
}
