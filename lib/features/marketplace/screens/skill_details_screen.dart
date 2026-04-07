import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SkillDetailsScreen extends StatelessWidget {
  final String skillId;

  const SkillDetailsScreen({super.key, required this.skillId});

  static const Color bg = Color(0xFFFBFBFE);
  static const Color lavenderAccent = Color(0xFF818CF8);
  static const Color tealAccent = Color(0xFF2DD4BF);
  static const Color textColor = Color(0xFF1E293B);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color cardBg = Color(0xFFF1F5F9);

  final List<Color> primaryGradient = const [
    Color(0xFF8099FF),
    Color(0xFF33CCBC),
  ];

  void _sendRequest(BuildContext context, String receiverId, String skillTitle) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    if (currentUser.uid == receiverId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You cannot request your own skill!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    TextEditingController msgController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Send Request",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: textColor),
        ),
        content: TextField(
          controller: msgController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Hi, can you teach me the basics?",
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: cardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: secondaryText)),
          ),
          ElevatedButton(
            onPressed: () async {
              String message = msgController.text.trim();
              if (message.isEmpty) {
                message = "Hi, I would like to learn this skill from you.";
              }

              await FirebaseFirestore.instance.collection('requests').add({
                'skillId': skillId,
                'senderId': currentUser.uid,
                'receiverId': receiverId,
                'skillTitle': skillTitle,
                'message': message,
                'status': 'pending',
                'timestamp': FieldValue.serverTimestamp(),
              });

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Request sent successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: lavenderAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Send", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: Text(
          'Skill Details',
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('skills').doc(skillId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Skill not found"));
          }

          var skillData = snapshot.data!.data() as Map<String, dynamic>;
          String receiverId = skillData['userId'] ?? '';
          String skillTitle = skillData['title'] ?? 'Unknown Skill';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1555066931-4365d14bab8c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [bg, Colors.white.withOpacity(0.0)],
                        stops: const [0.0, 0.4],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        skillTitle,
                        style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoCard(Icons.access_time, 'Duration', skillData['time'] ?? 'N/A'),
                          _buildInfoCard(Icons.local_offer_outlined, 'Category', skillData['category'] ?? 'N/A'),
                          _buildInfoCard(Icons.trending_up_rounded, 'Level', skillData['level'] ?? 'N/A'),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'About this skill',
                        style: GoogleFonts.poppins(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        skillData['description'] ?? 'No description provided.',
                        style: GoogleFonts.poppins(color: secondaryText, height: 1.6, fontSize: 13),
                      ),
                      const SizedBox(height: 35),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('users').doc(receiverId).get(),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            
                            String teacherName = 'Teacher';
                            String teacherBio = 'Passionate about teaching others';
                            String teacherAvatar = 'https://randomuser.me/api/portraits/men/32.jpg';

                            if (userSnapshot.hasData && userSnapshot.data!.exists) {
                              var uData = userSnapshot.data!.data() as Map<String, dynamic>;
                              teacherName = uData['fullName'] ?? uData['name'] ?? 'Teacher';
                              teacherBio = uData['bio'] ?? teacherBio;
                              teacherAvatar = uData['profileImageUrl'] ?? teacherAvatar;
                            }

                            return Column(
                              children: [
                                Text('Your Teacher', style: GoogleFonts.poppins(color: secondaryText, fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 15),
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: lavenderAccent, width: 2),
                                  ),
                                  child: CircleAvatar(
                                    radius: 35,
                                    backgroundImage: NetworkImage(teacherAvatar),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  teacherName,
                                  style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  skillData['category'] ?? 'Category',
                                  style: GoogleFonts.poppins(color: tealAccent, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  teacherBio,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(color: secondaryText, fontSize: 12),
                                ),
                              ],
                            );
                          }
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: primaryGradient,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: primaryGradient[0].withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _sendRequest(context, receiverId, skillTitle);
                          },
                          icon: const Icon(Icons.mail_outline, color: Colors.white),
                          label: Text(
                            'Request to Learn',
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Icon(icon, color: lavenderAccent, size: 24),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.poppins(color: secondaryText, fontSize: 11)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}