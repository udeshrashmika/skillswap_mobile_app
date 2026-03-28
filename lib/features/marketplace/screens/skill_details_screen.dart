import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

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
                        skillData['title'] ?? 'No Title', 
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
                        child: Column(
                          children: [
                            Text('Your Teacher', style: GoogleFonts.poppins(color: secondaryText, fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: lavenderAccent, width: 2),
                              ),
                              child: const CircleAvatar(
                                radius: 35,
                                backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Marcus Johnson',
                              style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Computer Science',
                              style: GoogleFonts.poppins(color: tealAccent, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Passionate about Web development and teaching others',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(color: secondaryText, fontSize: 12),
                            ),
                          ],
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
                          onPressed: () {},
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