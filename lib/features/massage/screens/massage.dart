import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MassageScreen extends StatefulWidget {
  const MassageScreen({super.key});

  @override
  State<MassageScreen> createState() => _MassageScreenState();
}

class _MassageScreenState extends State<MassageScreen> {
  int _selectedIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141416),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
          child: AppBar(
            backgroundColor: const Color(0xFF6F51A1),
            elevation: 0,
            centerTitle: false,
            title: Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 8.0),
              child: Text(
                "SKILLSWAP",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, right: 16.0),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.exit_to_app_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        'https://randomuser.me/api/portraits/men/1.jpg',
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            width: 32,
                            height: 32,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFA68DFF),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 32,
                            height: 32,
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Message',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: TextField(
                    style: GoogleFonts.inter(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Search here',
                      hintStyle: GoogleFonts.inter(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black87,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: chatList.length,
              itemBuilder: (context, index) {
                final chat = chatList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),

                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.network(
                        chat['image'],
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            width: 44,
                            height: 44,
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFA68DFF),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 44,
                            height: 44,
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      chat['name'],
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        chat['message'],
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: chat['unread'] > 0
                        ? CircleAvatar(
                            radius: 12,
                            backgroundColor: const Color(0xFFA68DFF),
                            child: Text(
                              chat['unread'].toString(),
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E24),
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.home_filled, "Home"),
            _buildNavItem(1, Icons.search, "Explore"),
            _buildNavItem(2, Icons.inbox_outlined, "Requests"),
            _buildNavItem(3, Icons.mail_outline, "Messages"),
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
        setState(() => _selectedIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D2641) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFA68DFF) : Colors.white54,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: const Color(0xFFA68DFF),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

final List<Map<String, dynamic>> chatList = [
  {
    'name': 'Marcus Johnson',
    'message': 'That UI is smooth. Is that Flutter?',
    'unread': 1,
    'image': 'https://randomuser.me/api/portraits/men/32.jpg',
  },
  {
    'name': 'Sarah Connor',
    'message': 'Can you help me with the React bug?',
    'unread': 0,
    'image': 'https://randomuser.me/api/portraits/women/44.jpg',
  },
  {
    'name': 'David Chen',
    'message': 'Thanks for the TypeScript tutorial!',
    'unread': 0,
    'image': 'https://randomuser.me/api/portraits/men/46.jpg',
  },
  {
    'name': 'Emma Watson',
    'message': 'Are we still meeting at 5?',
    'unread': 3,
    'image': 'https://randomuser.me/api/portraits/women/32.jpg',
  },
  {
    'name': 'Michael Bay',
    'message': 'Thanks man! 🙏 Yeah, it\'s Flutter',
    'unread': 0,
    'image': 'https://randomuser.me/api/portraits/men/11.jpg',
  },
  {
    'name': 'Alice Smith',
    'message': 'I will send you the Figma design soon.',
    'unread': 0,
    'image': 'https://randomuser.me/api/portraits/women/12.jpg',
  },
  {
    'name': 'John Wick',
    'message': 'Yeah, the animations are looking great!',
    'unread': 2,
    'image': 'https://randomuser.me/api/portraits/men/9.jpg',
  },
];
