import 'dart:async';
import 'package:flutter/material.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // LOGIC: Wait 4 seconds then open HomeScreen
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // STATIC: Full-screen GIF background
          SizedBox.expand(
            child: Image.asset(
              'assets/images/splash.gif',
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),

          // STATIC: Dark overlay to make text easier to read
          Container(color: Colors.black.withValues(alpha: 0.15)),

          // STATIC: App title and slogan
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'Study Planner',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 12)],
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    'Discover Your Path',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 1,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                    ),
                  ),

                  SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
