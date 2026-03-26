import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'explore_screen.dart';
import '../../message/screens/message_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  int _selectedIndex = 0;

  final Color bgLight = const Color(0xFFFBFBFF);
  final Color textDark = const Color(0xFF1D2939);
  final Color textGrey = const Color(0xFF667085);

  final List<Color> primaryGradient = [
    const Color(0xFF8099FF),
    const Color(0xFF33CCBC),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: bgLight,
          elevation: 0,
          centerTitle: false,
          title: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: primaryGradient,
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: Text(
                "SKILLSWAP",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0, right: 8.0),
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.logout_rounded, color: textDark),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFD0D5DD).withOpacity(0.5),
                ),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search for skills...",
                  hintStyle: GoogleFonts.poppins(color: textGrey, fontSize: 14),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: primaryGradient[0]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Discover Skills",
              style: GoogleFonts.poppins(
                color: textDark,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildGradientCategoryChip("All", true),
                _buildCategoryChip("Design", false),
                _buildCategoryChip("Programming", false),
                _buildCategoryChip("Mathematics", false),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              itemBuilder: (context, index) => _buildSkillCard(index),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildGradientCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: primaryGradient),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: primaryGradient[1].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFD0D5DD)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: textDark,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSkillCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  'https://images.unsplash.com/photo-1498050108023-c5249f4df085?q=80&w=500',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCFBEF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Beginner",
                    style: TextStyle(
                      color: primaryGradient[1],
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a'),
            ),
            title: Text(
              index % 2 == 0 ? "UI/UX Design Masterclass" : "Flutter Dev",
              style: GoogleFonts.poppins(
                color: textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "Marcus Johnson",
              style: GoogleFonts.poppins(
                color: primaryGradient[1],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 85,
      padding: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF2F4F7))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.home_filled, "Home"),
          _buildNavItem(1, Icons.search_rounded, "Explore"),
          _buildNavItem(2, Icons.swap_horiz_rounded, "Swap"),
          _buildNavItem(3, Icons.mail_outline, "Message"),
          _buildNavItem(4, Icons.person_outline, "Profile"),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExploreScreen()),
          ).then((_) => setState(() => _selectedIndex = 0));
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MessageScreen()),
          ).then((_) => setState(() => _selectedIndex = 0));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryGradient[0] : textGrey,
              size: 26,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: primaryGradient[0],
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
