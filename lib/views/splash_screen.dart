import 'package:flutter/material.dart';
import 'package:sitikap/extensions/extensions.dart';
import 'package:sitikap/local/shared_preferenced.dart';
import 'package:sitikap/views/home_screen.dart';
import 'package:sitikap/views/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const id = "/splash_screen";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkLogin();
    });
  }

  void checkLogin() async {
    final isLogin = await PreferenceHandler.getLogin();
    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (!mounted) return;

      if (isLogin == true) {
        context.pushReplacementNamed(HomeScreen.id);
      } else {
        context.pushNamed(LoginScreen.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        // child: Lottie.asset("assets/lotiie/animation.json"),
        // child: Image.asset(AppImage.logo, width: 275, fit: BoxFit.cover),
      ),
    );
  }
}
