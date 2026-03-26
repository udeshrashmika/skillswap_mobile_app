import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'skill_details_screen.dart';
// import '../../message/screens/message_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // --- Dreamy Aesthetic Light Palette ---
  static const Color bg = Color(0xFFFBFBFE); // Very soft off-white
  static const Color cardBg = Colors.white; // Pure white for cards
  static const Color lavenderAccent = Color(
    0xFF818CF8,
  ); // Soft Lavender Blue (Primary Cool)
  static const Color tealAccent = Color(
    0xFF2DD4BF,
  ); // Fresh Mint Cyan (Secondary Cool)
  static const Color roseAccent = Color(
    0xFFF472B6,
  ); // Soft Rose Pink (Highlight Cool)

  static const Color textColor = Color(0xFF1E293B); // Dark Slate for clear text
  static const Color secondaryText = Color(
    0xFF64748B,
  ); // Slate Gray for sub-text
  static const Color searchBarBg = Color(0xFFF1F5F9); // Very light gray mist

  int selectedCategoryIndex = 0;
  int _selectedIndex = 1;

  final List<String> categories = [
    'All',
    'Design',
    'Mathematics',
    'Programming',
    'Science',
    'Languages',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      // Seamless White App Bar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: bg,
          elevation: 0,
          centerTitle: false,
          title: Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 5.0),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  lavenderAccent,
                  tealAccent,
                ], // Aesthetic Gradient title
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                "SKILLSWAP",
                style: GoogleFonts.poppins(
                  color: Colors.white, // Colors are overridden by gradient
                  fontWeight: FontWeight.w900, // Extra bold for brand
                  fontSize: 24,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 15.0, right: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: searchBarBg, // subtle background for icon
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: textColor,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Explore Skills Title
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 10.0,
              bottom: 15.0,
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Explore Skills',
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: 30, // Larger font for visual hierarchy
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                ),
              ),
            ),
          ),

          // 2. Search Bar (Pinned Delegate - Glassmorphism hint)
          SliverPersistentHeader(pinned: true, delegate: _SearchBarDelegate()),

          // 3. Categories Title
          SliverPadding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: GoogleFonts.poppins(
                      color: secondaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),

          // 4. Categories Grid (Gradient Buttons)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverToBoxAdapter(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.3,
                  crossAxisSpacing: 12, // Increased spacing for softness
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  bool isSelected = selectedCategoryIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategoryIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [
                                  lavenderAccent,
                                  tealAccent,
                                ], // Cool Gradient selected state
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected ? null : cardBg,
                        borderRadius: BorderRadius.circular(
                          16,
                        ), // Softer radius
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: lavenderAccent.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                                BoxShadow(
                                  color: tealAccent.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(3, 0),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            categories[index],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: isSelected ? Colors.white : textColor,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 5. Skills List (Beautiful Aesthetic Cards)
          SliverPadding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '8 Skills Found',
                        style: GoogleFonts.poppins(
                          color: secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: searchBarBg,
                        ),
                        child: Icon(
                          Icons.filter_list_rounded,
                          color: roseAccent,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildSkillCard(
                        title: 'React & TypeScript Fundamentals',
                        teacher: 'Marcus Johnson',
                        role: 'Computer Science',
                        description:
                            'Learn the basics of modern development. Perfect for beginners.',
                        imageUrl:
                            'https://images.unsplash.com/photo-1633356122544-f134324a6cee?q=80&w=500',
                        avatarUrl: 'https://i.pravatar.cc/150?img=11',
                        badgeText: 'Beginner',
                        context: context,
                      ),
                      _buildSkillCard(
                        title: 'Adobe Illustrator Basics',
                        teacher: 'Sarah Connor',
                        role: 'Graphic Design',
                        description:
                            'Master the fundamentals of vector design with AI.',
                        imageUrl:
                            'https://images.unsplash.com/photo-1611162616475-76b637898b69?q=80&w=500',
                        avatarUrl: 'https://i.pravatar.cc/150?img=5',
                        badgeText: 'Beginner',
                        context: context,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar (Glassy & Gradient active)
      bottomNavigationBar: Container(
        height: 90,
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: cardBg.withOpacity(0.9), // Glassy feel hint
          border: Border(
            top: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.home_filled, "Home"),
            _buildNavItem(1, Icons.search, "Explore"),
            _buildNavItem(2, Icons.swap_horiz, "Requests"),
            _buildNavItem(3, Icons.mail_outline, "Message"),
            _buildNavItem(4, Icons.person_outline, "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (_selectedIndex == index) return;
        setState(() => _selectedIndex = index);

        if (index == 0) {
          Navigator.pop(context);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutBack, // Beautiful animation
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEEF2FF)
              : Colors.transparent, // Soft Lavender base for selected
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isSelected
                ? ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [lavenderAccent, tealAccent], // Gradient icon
                    ).createShader(bounds),
                    child: Icon(icon, color: Colors.white, size: 26),
                  )
                : Icon(icon, color: secondaryText, size: 26),
            if (isSelected) ...[
              const SizedBox(width: 10),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [lavenderAccent, tealAccent], // Gradient text
                ).createShader(bounds),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSkillCard({
    required String title,
    required String teacher,
    required String role,
    required String description,
    required String imageUrl,
    required String avatarUrl,
    required String badgeText,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SkillDetailsScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 25,
        ), // Increased margin for softness
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(28), // Very soft radius
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), // Soft shadow
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 170, // Slightly taller image
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFCCFBF1,
                      ).withOpacity(0.95), // Very light soft Teal mist
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeText,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF134E4A), // Deep teal text
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(
                20.0,
              ), // Increased padding for softness
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(avatarUrl),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacher,
                            style: GoogleFonts.poppins(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            role,
                            style: GoogleFonts.poppins(
                              color: tealAccent, // Freshman teal accent on role
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      color: secondaryText,
                      fontSize: 13,
                      height: 1.6,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Search Bar Delegate with Aesthetic Glassmorphism Hint
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFFFBFBFE), // Matches lightBackground
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 10.0,
        bottom: 20.0,
      ),
      alignment: Alignment.topCenter,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9), // Light gray mist background
          borderRadius: BorderRadius.circular(18), // Softer radius
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02), // subtle shadow
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          style: GoogleFonts.poppins(color: const Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: 'Search for skills...',
            hintStyle: GoogleFonts.poppins(
              color: const Color(0xFF94A3B8),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF818CF8),
            ), // Lavender search icon
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 17),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 85.0;

  @override
  double get minExtent => 85.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
