import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  static const Color bg = Color(0xFFFBFBFE);
  static const Color lavenderAccent = Color(0xFF818CF8);
  static const Color tealAccent = Color(0xFF2DD4BF);
  static const Color textColor = Color(0xFF1E293B);
  static const Color secondaryText = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Messages",
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  // Logout function here
                },
                icon: const Icon(
                  Icons.logout_rounded,
                  color: textColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 10.0,
              bottom: 20.0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                style: GoogleFonts.poppins(color: textColor),
                decoration: InputDecoration(
                  hintText: "Search messages...",
                  hintStyle: GoogleFonts.poppins(
                    color: secondaryText,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: lavenderAccent),
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: chatList.length,
              itemBuilder: (context, index) {
                final chat = chatList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    leading: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: chat['unread'] > 0
                              ? lavenderAccent
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.network(
                          chat['image'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              width: 50,
                              height: 50,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: lavenderAccent,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 50,
                              height: 50,
                              color: const Color(0xFFF1F5F9),
                              child: const Icon(
                                Icons.person,
                                color: secondaryText,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    title: Text(
                      chat['name'],
                      style: GoogleFonts.poppins(
                        color: textColor,
                        fontWeight: chat['unread'] > 0
                            ? FontWeight.bold
                            : FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        chat['message'],
                        style: GoogleFonts.poppins(
                          color: chat['unread'] > 0
                              ? textColor.withOpacity(0.8)
                              : secondaryText,
                          fontSize: 12,
                          fontWeight: chat['unread'] > 0
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: chat['unread'] > 0
                        ? Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [lavenderAccent, tealAccent],
                              ),
                            ),
                            child: Text(
                              chat['unread'].toString(),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Text(
                            "12:30 PM",
                            style: GoogleFonts.poppins(
                              color: secondaryText.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Mock Data
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
