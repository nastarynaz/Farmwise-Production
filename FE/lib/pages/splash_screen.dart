import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:farmwise_app/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  void _startApp() async {
    await Future.delayed(
      Duration(seconds: 1),
    ); // Lebih cepat sedikit = UX lebih baik
    if (FirebaseAuth.instance.currentUser != null) {
      context.go('/home');
    } else {
      context.go(AppRoutes.onboarding_1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: 1,
                duration: Duration(milliseconds: 800),
                child: Image.asset(
                  'assets/icons/farmwise-icon.png',
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'FarmWise',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 24, // lebih besar dan readable
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(color: Colors.green, strokeWidth: 3),
            ],
          ),
        ),
      ),
    );
  }
}
