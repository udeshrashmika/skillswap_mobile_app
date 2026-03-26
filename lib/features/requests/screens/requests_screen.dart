import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color textDark = Color(0xFF1D2939);
    const Color textGrey = Color(0xFF667085);
    const List<Color> primaryGradient = [Color(0xFF8099FF), Color(0xFF33CCBC)];

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: primaryGradient,
              ).createShader(bounds),
              child: const Icon(
                Icons.rocket_launch_rounded,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Coming Soon",
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "We are building the request system!",
              style: GoogleFonts.poppins(color: textGrey),
            ),
          ],
        ),
      ),
    );
  }
}
