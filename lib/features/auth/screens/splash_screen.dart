import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, anim, sep) => const LoginScreen(),
          transitionsBuilder: (context, anim, sep, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Colors based on your provided reference image
    const Color bgSage = Color(0xFFDDE7DC);
    const Color primaryBlack = Color(0xFF000000);
    const Color accentRed = Color(0xFFE31E24);

    return Scaffold(
      backgroundColor: bgSage, // Flat sage background for that modern look
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO ANIMATION
            SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      // Main Icon in Black
                      const Icon(
                        Icons.sync_alt_rounded,
                        color: primaryBlack,
                        size: 110,
                      ),
                      // Small Red Dot Accent (matches the 'w' logo in your image)
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(top: 15, right: 10),
                        decoration: const BoxDecoration(
                          color: accentRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // TEXT ANIMATION
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    "SKILLSWAP",
                    style: GoogleFonts.poppins(
                      color: primaryBlack,
                      fontSize: 38,
                      fontWeight:
                          FontWeight.w900, // Thicker weight for 'Summary' style
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Skill Up Today, Lead Tomorrow",
                    style: GoogleFonts.poppins(
                      color: primaryBlack.withOpacity(0.6),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),

            // Modern, minimalist loading indicator
            FadeTransition(
              opacity: _fadeAnimation,
              child: const SizedBox(
                width: 35,
                height: 35,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryBlack),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
