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
  final List<String> categories = [
    "All",
    "Coding",
    "Design",
    "Music",
    "Art",
    "Language",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi, ${FirebaseAuth.instance.currentUser?.displayName ?? 'Welcome'}!",
                          style: GoogleFonts.poppins(
                            color: lavenderAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Let's swap a skill",
                          style: GoogleFonts.poppins(
                            color: textColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      ),
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          String url =
                              snapshot.data?.get('profileImageUrl') ??
                              'https://i.pravatar.cc/150?u=me';
                          return CircleAvatar(
                            radius: 25,
                            backgroundColor: lavenderAccent.withOpacity(0.1),
                            backgroundImage: NetworkImage(url),
                          );
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
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search, color: lavenderAccent),
                      hintText: "Find a lesson...",
                      border: InputBorder.none,
                    ),
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
                        onSelected: (val) => setState(
                          () => selectedCategory = categories[index],
                        ),
                        selectedColor: lavenderAccent,
                        backgroundColor: unselectedChipBg,
                        showCheckmark: false,
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected ? Colors.white : secondaryText,
                        ),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
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
                      stream: FirebaseFirestore.instance
                          .collection('skills')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: lavenderAccent,
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return _buildEmptyState("No skills found");
                        }

                        var filteredDocs = snapshot.data!.docs.where((d) {
                          var data = d.data() as Map<String, dynamic>;
                          String title = (data['title'] ?? "")
                              .toString()
                              .toLowerCase();
                          String category = (data['category'] ?? "").toString();

                          String cleanQuery = searchQuery.trim().toLowerCase();

                          bool matchesSearch = title.contains(cleanQuery);
                          bool matchesCategory =
                              selectedCategory == "All" ||
                              category == selectedCategory;

                          return matchesSearch && matchesCategory;
                        }).toList();

                        if (filteredDocs.isEmpty) {
                          return _buildEmptyState("No matching skills found");
                        }

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 20),
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) =>
                              _buildFeaturedCard(index, filteredDocs[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: _buildSectionHeader(
                "Top Rated Students",
                hasViewAll: true,
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('rating', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _buildEmptyState("No student ratings yet"),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildTeacherTile(snapshot.data!.docs[index]),
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
          Text(
            title,
            style: GoogleFonts.poppins(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          if (hasViewAll)
            const Text(
              "View All",
              style: TextStyle(color: tealAccent, fontWeight: FontWeight.bold),
            ),
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
        gradient: LinearGradient(
          colors: index % 2 == 0
              ? [lavenderAccent, const Color(0xFF6366F1)]
              : [tealAccent, const Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: lavenderAccent.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (data['category'] ?? "SKILL").toString().toUpperCase(),
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data['title'] ?? "Untitled",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 4),
            Text(
              "${data['level'] ?? ''} • ${data['time'] ?? ''}",
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: lavenderAccent,
                shape: const StadiumBorder(),
              ),
              child: const Text("View Details"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherTile(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String uid = doc.id;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen(uid: uid)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(
                data['profileImageUrl'] ??
                    'https://ui-avatars.com/api/?name=${data['name'] ?? 'User'}',
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? 'User',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    data['university'] ?? 'SkillSwap Student',
                    style: const TextStyle(color: secondaryText, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.star_rounded, color: Colors.orange, size: 20),
            Text(
              " ${(data['rating'] ?? 0.0).toStringAsFixed(1)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          message,
          style: const TextStyle(
            color: secondaryText,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
