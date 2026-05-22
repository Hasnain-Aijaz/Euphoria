import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../theme/app_theme.dart';
import 'dart:async';
import 'login_screen.dart';
import '../main.dart';
import '../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // Remove native splash screen
    FlutterNativeSplash.remove();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    // Wait for splash animation (4 seconds)
    final delayFuture = Future.delayed(const Duration(milliseconds: 4000));
    
    // Check if token exists and is valid
    final userFuture = ApiService.getMe();

    final results = await Future.wait([userFuture, delayFuture]);
    final user = results[0];

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              user != null ? const MainShell() : const LoginScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 1200),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.netflixRed.withOpacity(0.4),
                        blurRadius: 100,
                        spreadRadius: 20,
                      ),
                      BoxShadow(
                        color: AppTheme.darkRed.withOpacity(0.6),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/euphoria_logo1.png',
                      height: 160,
                      width: 160,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                )
                // Entrance: scale & fade
                .animate()
                .scale(
                  begin: const Offset(0.3, 0.3),
                  end: const Offset(1.0, 1.0),
                  duration: 1200.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 800.ms)
                // Effect: continuous slow heartbeat pulse
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.04, 1.04),
                  duration: 1500.ms,
                  curve: Curves.easeInOutSine,
                ),

            const SizedBox(height: 50),

            // app title
            const Text(
                  'E U P H O R I A',
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 10,
                  ),
                )
                // Entrance: slide up and fade
                .animate()
                .fadeIn(delay: 600.ms, duration: 1000.ms)
                .slideY(
                  begin: 0.8,
                  end: 0.0,
                  duration: 1000.ms,
                  curve: Curves.easeOutCubic,
                )
                // Effect: subtle red shimmer
                .shimmer(
                  delay: 1400.ms,
                  duration: 2000.ms,
                  color: AppTheme.netflixRed,
                ),
          ],
        ),
      ),
    );
  }
}
