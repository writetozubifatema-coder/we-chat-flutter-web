import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart'
    show GoogleSignIn, GoogleSignInAccount, GoogleSignInAuthentication;

import 'package:we_chat/api/api.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool animate = false;
  GoogleSignIn? _googleSignIn;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      _googleSignIn = GoogleSignIn();
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        animate = true;
      });
    });
  }

  // ✅ FINAL GOOGLE LOGIN HANDLER
  Future<void> _handleGoogleBtnClick() async {
    Dialogs.showprogressbar(context);

    UserCredential? userCredential;

    try {
      if (kIsWeb) {
        userCredential = await FirebaseAuth.instance
            .signInWithPopup(GoogleAuthProvider());
      } else {
        userCredential = await _signInWithGoogle();
      }

      if (mounted) Navigator.pop(context);

      if (userCredential == null || userCredential.user == null) return;

      log('User UID: ${userCredential.user!.uid}');

      // ✅ CHECK → CREATE → NAVIGATE (ONLY ONCE)
     // ✅ ALWAYS ensure user exists in Firestore
final firebaseUser = userCredential.user!;
await Api.ensureUserExists(firebaseUser);
await Api.syncProfilePhoto(userCredential.user!);



// ✅ THEN navigate
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const HomeScreen()),
);

    } catch (e) {
      if (mounted) Navigator.pop(context);
      log('Login error: $e');
      Dialogs.showsnackbar(context, 'Login failed. Try again.');
    }
  }

  // ✅ MOBILE GOOGLE SIGN-IN
  Future<UserCredential?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn!.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance
          .signInWithCredential(credential);
    } catch (e) {
      log('Google Sign-In error: $e');
      Dialogs.showsnackbar(context, 'Login failed. Try again.');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to We Chat'),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height * 0.15,
            right: animate ? mq.width * 0.25 : -mq.width * 0.5,
            width: mq.width * 0.5,
            duration: const Duration(seconds: 1),
            child: Image.asset('assets/images/chatting.png'),
          ),
          Positioned(
            bottom: mq.height * 0.15,
            left: mq.width * 0.05,
            width: mq.width * 0.9,
            height: mq.height * 0.07,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(255, 219, 255, 178),
                shape: const StadiumBorder(),
                elevation: 1,
              ),
              onPressed: _handleGoogleBtnClick,
              icon: Image.asset('assets/images/google.png'),
              label: const Text(
                'Login with Google',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
