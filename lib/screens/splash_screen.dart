import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_chat/auth/login_screen.dart';
import 'package:we_chat/screens/home_screen.dart';
import 'package:we_chat/main.dart';
import '../api/api.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool animate = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
    );

    // Start animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => animate = true);
    });

    // Navigate after splash
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;

      final user = Api.auth.currentUser;

      if (user != null) {
        // ✅ User already logged in
        await Api.ensureUserExists(user);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        // ❌ Not logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOut,
            top: mq.height * 0.25,
            left: animate ? mq.width * 0.25 : -mq.width * 0.6,
            width: mq.width * 0.5,
            child: Image.asset('assets/images/chatting.png'),
          ),
          Positioned(
            bottom: mq.height * 0.12,
            left: 0,
            right: 0,
            child: const Text(
              'MADE IN INDIA WITH ❤️',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
