import 'package:flutter/material.dart';
import 'package:skillswap/features/marketplace/screens/marketplace_screen.dart';
import 'package:skillswap/features/marketplace/screens/explore_screen.dart';
import 'package:skillswap/features/requests/screens/requests_screen.dart';
import 'package:skillswap/features/message/screens/message_screen.dart';


import 'package:skillswap/features/marketplace/screens/add_skill_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  final Color textGrey = const Color(0xFF667085);
  final List<Color> primaryGradient = [
    const Color(0xFF8099FF),
    const Color(0xFF33CCBC),
  ];

  final List<Widget> _pages = [
    const MarketplaceScreen(),
    const ExploreScreen(),
    const RequestsScreen(),
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
            _buildNavItem(0, Icons.home_filled),
            _buildNavItem(1, Icons.search_rounded),
            
            
            _buildAddSkillButton(context), 
            
            _buildNavItem(2, Icons.swap_horiz_rounded),
            _buildNavItem(3, Icons.mail_outline_rounded),
          ],
        ),
      ),
    );
  }

  
  Widget _buildAddSkillButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        
        showModalBottomSheet(
          context: context,
          isScrollControlled: true, 
          backgroundColor: Colors.transparent, 
          builder: (context) => const AddSkillScreen(),
        );
      },
      child: Container(
        height: 46, 
        width: 46,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle, 
          boxShadow: [
            BoxShadow(
              color: primaryGradient[0].withOpacity(0.3), 
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 24), 
      ),
    );
  }

  
  Widget _buildNavItem(int index, IconData icon) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        color: Colors.transparent, 
        
        width: 60,
        height: 60,
        alignment: Alignment.center, 
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: isSelected
              
              ? ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: primaryGradient,
                  ).createShader(bounds),
                  child: Icon(icon, color: Colors.white, size: 28),
                )
              
              : Icon(icon, color: textGrey, size: 26),
        ),
      ),
    );
  }
}