import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/profile/screens/profile.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  static const Color bg = Color(0xFFFBFBFE);
  static const Color lavenderAccent = Color(0xFF818CF8);
  static const Color tealAccent = Color(0xFF2DD4BF);
  static const Color textColor = Color(0xFF1E293B);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color unselectedChipBg = Color(0xFFF1F5F9);

  String searchQuery = "";
  String selectedCategory = "All";
  bool _isSending = false; 

  final List<String> categories = ["All", "Coding", "Design", "Music", "Art", "Language"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        String displayName = "Welcome";
                        if (snapshot.hasData && snapshot.data!.exists) {
                          var d = snapshot.data!.data() as Map<String, dynamic>;
                          displayName = d['fullName'] ?? d['name'] ?? "User";
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Hi, $displayName!",
                                style: GoogleFonts.poppins(color: lavenderAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("Let's swap a skill",
                                style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w800, fontSize: 24)),
                          ],
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          String url = 'https://i.pravatar.cc/150?u=me';
                          if (snapshot.hasData && snapshot.data!.exists) {
                            var d = snapshot.data!.data() as Map<String, dynamic>;
                            url = d['profileImageUrl'] ?? url;
                          }
                          return CircleAvatar(radius: 25, backgroundColor: lavenderAccent.withOpacity(0.1), backgroundImage: NetworkImage(url));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                    decoration: const InputDecoration(icon: Icon(Icons.search, color: lavenderAccent), hintText: "Find a lesson...", border: InputBorder.none),
                  ),
                ),
              ),
            ),

            
            SliverToBoxAdapter(
              child: SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20, top: 15),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedCategory == categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(categories[index]),
                        selected: isSelected,
                        onSelected: (val) => setState(() => selectedCategory = categories[index]),
                        selectedColor: lavenderAccent,
                        backgroundColor: unselectedChipBg,
                        showCheckmark: false,
                        labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? Colors.white : secondaryText),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    );
                  },
                ),
              ),
            ),

            
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Featured Skills"),
                  SizedBox(
                    height: 220,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('skills').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildEmptyState("No skills found");

                        var docs = snapshot.data!.docs.where((d) {
                          Map<String, dynamic> data = d.data() as Map<String, dynamic>;
                          String title = (data['title'] ?? "").toString().toLowerCase();
                          String cat = (data['category'] ?? "").toString();
                          return title.contains(searchQuery) && (selectedCategory == "All" || cat == selectedCategory);
                        }).toList();

                        if (docs.isEmpty) return _buildEmptyState("No matching skills found");

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 20),
                          itemCount: docs.length,
                          itemBuilder: (context, index) => _buildFeaturedCard(index, docs[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            
            SliverToBoxAdapter(child: _buildSectionHeader("Top Rated Students", hasViewAll: true)),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('rating', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return SliverToBoxAdapter(child: _buildEmptyState("No students found"));

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildTeacherTile(snapshot.data!.docs[index]),
                      childCount: snapshot.data!.docs.length,
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool hasViewAll = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
          if (hasViewAll) const Text("View All", style: TextStyle(color: tealAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(int index, DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 15, bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(colors: index % 2 == 0 ? [lavenderAccent, const Color(0xFF6366F1)] : [tealAccent, const Color(0xFF0EA5E9)]),
        boxShadow: [BoxShadow(color: lavenderAccent.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text((data['category'] ?? "SKILL").toString().toUpperCase(), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 8),
            Text(data['title'] ?? "Untitled", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18), maxLines: 2),
            const SizedBox(height: 4),
            Text("${data['level'] ?? 'All levels'} • ${data['time'] ?? 'Flexible'}", style: const TextStyle(color: Colors.white60, fontSize: 12)),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _showSkillDetailDialog(doc),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: lavenderAccent, shape: const StadiumBorder()),
              child: const Text("View Details"),
            ),
          ],
        ),
      ),
    );
  }

  
  void _showSkillDetailDialog(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String teacherId = data['userId'] ?? "";

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(30)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [lavenderAccent, Color(0xFF6366F1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 15),
                    Text(data['title'] ?? "Untitled Skill", textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
                    Text((data['category'] ?? "General").toString().toUpperCase(),
                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12)),
                  ],
                ),
              ),
              // Body
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _detailChip(Icons.stairs_rounded, data['level'] ?? "Beginner"),
                        _detailChip(Icons.schedule_rounded, data['time'] ?? "Flexible"),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Text("About this Skill", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: textColor, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(data['description'] ?? "Connect to learn more about this skill swap!",
                        style: GoogleFonts.poppins(color: secondaryText, fontSize: 14, height: 1.5)),
                  ],
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: Text("Close", style: GoogleFonts.poppins(color: secondaryText, fontWeight: FontWeight.w600)))),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSending ? null : () {
                          Navigator.pop(context);
                          _sendSwapRequest(data, teacherId);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: tealAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 15)),
                        child: _isSending 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text("Request Swap", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: lavenderAccent.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [Icon(icon, size: 16, color: lavenderAccent), const SizedBox(width: 6), Text(label, style: GoogleFonts.poppins(color: lavenderAccent, fontWeight: FontWeight.w600, fontSize: 12))]),
    );
  }

  
  Future<void> _sendSwapRequest(Map<String, dynamic> skillData, String receiverId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || receiverId.isEmpty) return;
    
    setState(() => _isSending = true);

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance.collection('requests').add({
        'senderId': user.uid,
        'senderName': userData['fullName'] ?? userData['name'] ?? 'User',
        'senderPhoto': userData['profileImageUrl'],
        'receiverId': receiverId,
        'skillTitle': skillData['title'],
        'message': "Hi, I would like to learn this skill from you.",
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request sent successfully!"), backgroundColor: tealAccent));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Widget _buildTeacherTile(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String name = data['fullName'] ?? data['name'] ?? 'SkillSwap Member';
    String university = data['university'] ?? 'SkillSwap Student';
    String profileImg = data['profileImageUrl'] ?? 'https://ui-avatars.com/api/?name=$name';
    double rating = (data['rating'] ?? 0.0).toDouble();

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(uid: doc.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
        child: Row(
          children: [
            CircleAvatar(radius: 25, backgroundImage: NetworkImage(profileImg)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: textColor)),
                Text(university, style: const TextStyle(color: secondaryText, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const Icon(Icons.star_rounded, color: Colors.orange, size: 20),
            Text(" ${rating.toStringAsFixed(1)}", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text(message, style: const TextStyle(color: secondaryText, fontStyle: FontStyle.italic))));
  }
}