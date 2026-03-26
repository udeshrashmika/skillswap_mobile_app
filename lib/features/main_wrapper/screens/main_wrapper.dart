import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/marketplace/screens/marketplace_screen.dart';
import 'package:skillswap/features/marketplace/screens/explore_screen.dart';
//import 'package:skillswap/features/requests/screens/requests_screen.dart';
import 'package:skillswap/features/message/screens/message_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  final Color bgLight = const Color(0xFFFBFBFF);
  final Color textGrey = const Color(0xFF667085);
  final List<Color> primaryGradient = [
    const Color(0xFF8099FF),
    const Color(0xFF33CCBC),
  ];

  final List<Widget> _pages = [
    const MarketplaceScreen(),
    const ExploreScreen(),
    //const RequestsScreen(),
    const MessageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: Container(
        height: 85,
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.black.withOpacity(0.05), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.home_filled, "Home"),
            _buildNavItem(1, Icons.search_rounded, "Explore"),
            _buildNavItem(2, Icons.swap_horiz_rounded, "Requests"),
            _buildNavItem(3, Icons.mail_outline_rounded, "Messages"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isSelected
                ? ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: primaryGradient,
                    ).createShader(bounds),
                    child: Icon(icon, color: Colors.white, size: 24),
                  )
                : Icon(icon, color: textGrey, size: 24),

            if (isSelected) ...[
              const SizedBox(width: 8),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: primaryGradient,
                ).createShader(bounds),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
