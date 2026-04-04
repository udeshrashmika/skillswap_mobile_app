import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color primaryPurple = Color(0xFF6A5AE0);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF1E1E2D);
  static const Color textMuted = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: lightBackground,

        appBar: AppBar(
          backgroundColor: lightBackground,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: false,

          title: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 8.0),
            child: Text(
              "Requests",
              style: GoogleFonts.poppins(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 28,
                letterSpacing: 0.5,
              ),
            ),
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0, right: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.exit_to_app_rounded,
                    color: textColor,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),

        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Manage your skill exchange',
                style: TextStyle(color: textMuted, fontSize: 14),
              ),
            ),
            const SizedBox(height: 25),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: TabBar(
                indicatorColor: primaryPurple,
                indicatorWeight: 3,
                labelColor: primaryPurple,
                unselectedLabelColor: textMuted,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: 'Received'),
                  Tab(text: 'Sent'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: TabBarView(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return _buildLightRequestCard();
                    },
                  ),
                  const Center(
                    child: Text(
                      "No sent requests yet",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLightRequestCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://randomuser.me/api/portraits/men/32.jpg',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Silva',
                      style: GoogleFonts.poppins(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          'Wants to learn: ',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          'UI Design',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Skill offered : ',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                'Flutter Development',
                style: TextStyle(
                  color: primaryPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Message: "Can you teach me basics?"',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Accept',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 36,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Reject',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
