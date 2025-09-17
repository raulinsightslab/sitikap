import 'package:flutter/material.dart';
import 'package:sitikap/extensions/extensions.dart';
import 'package:sitikap/local/shared_preferenced.dart';
import 'package:sitikap/utils/colors.dart';
import 'package:sitikap/views/home_screen.dart';
import 'package:sitikap/views/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const id = "/splash_screen";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fingerprintController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    // Fingerprint pulse
    _fingerprintController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Logo muncul
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Text animasi
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _textSlide =
        Tween<Offset>(
          begin: const Offset(0, 0.5), // dari bawah
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    // Flow animasi
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _fingerprintController.stop();
        _logoController.forward().whenComplete(() {
          _textController.forward();
        });
      }
    });

    // Navigasi setelah splash
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
  void dispose() {
    _fingerprintController.dispose();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Fingerprint pulse
                AnimatedBuilder(
                  animation: _fingerprintController,
                  builder: (context, child) {
                    final scale = 0.8 + (_fingerprintController.value * 0.4);
                    return Opacity(
                      opacity:
                          _logoController.isAnimating ||
                              _logoController.isCompleted
                          ? 0.0
                          : 1.0,
                      child: Transform.scale(
                        scale: scale,
                        child: Image.asset(
                          "assets/images/fingerprint1.png",
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),

                // Logo PPKD
                FadeTransition(
                  opacity: _logoController,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _logoController,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white,
                      backgroundImage: const AssetImage(
                        "assets/images/ppkd_logo1.png",
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Text SiTIKAP animasi
            FadeTransition(
              opacity: _textOpacity,
              child: SlideTransition(
                position: _textSlide,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      letterSpacing: 1.2,
                    ),
                    children: [
                      const TextSpan(
                        text: "Si",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: "TIKAP",
                        style: TextStyle(color: Colors.orangeAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
