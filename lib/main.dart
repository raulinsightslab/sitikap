import 'package:flutter/material.dart';
import 'package:sitikap/views/login_screen.dart';
import 'package:sitikap/views/onboarding_screen.dart';
import 'package:sitikap/views/splash_screen.dart';
import 'package:sitikap/widget/botnav.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SITIKAP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: OnboardingScreen.id,
      routes: {
        OnboardingScreen.id: (context) => OnboardingScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        SplashScreen.id: (context) => SplashScreen(),
        FloatingNavBarExample.id: (context) => FloatingNavBarExample(),
      },
      // home: FloatingNavBarExample(),
    );
  }
}
