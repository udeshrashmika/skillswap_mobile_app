import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/features/marketplace/screens/skill_details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const Color bg = Color(0xFFFBFBFE);
  static const Color lavenderAccent = Color(0xFF818CF8);
  static const Color tealAccent = Color(0xFF2DD4BF);
  static const Color textColor = Color(0xFF1E293B);
  static const Color secondaryText = Color(0xFF64748B);

  String searchQuery = "";
  String selectedCategory = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Find Skills",
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                decoration: const InputDecoration(
                  hintText: "What do you want to learn?",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: lavenderAccent),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildCircularCat("Design", FontAwesomeIcons.penNib),
                _buildCircularCat("Coding", FontAwesomeIcons.code),
                _buildCircularCat("Music", FontAwesomeIcons.music),
                _buildCircularCat("Math", FontAwesomeIcons.calculator),
                _buildCircularCat("Video", FontAwesomeIcons.video),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Divider(color: Color(0xFFE2E8F0)),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('skills')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong!"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No skills found. Be the first to add one!",
                      style: GoogleFonts.poppins(color: secondaryText),
                    ),
                  );
                }

                final allSkills = snapshot.data!.docs;

                final filteredSkills = allSkills.where((skillDoc) {
                  final skillData = skillDoc.data() as Map<String, dynamic>;

                  final title = (skillData['title'] ?? '')
                      .toString()
                      .toLowerCase();

                  final category = (skillData['category'] ?? '')
                      .toString()
                      .toLowerCase();

                  final matchesSearch =
                      title.contains(searchQuery) ||
                      category.contains(searchQuery);

                  final matchesCategory =
                      selectedCategory.isEmpty ||
                      category == selectedCategory.toLowerCase();

                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredSkills.isEmpty) {
                  return Center(
                    child: Text(
                      "No results found",
                      style: GoogleFonts.poppins(color: secondaryText),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredSkills.length,
                  itemBuilder: (context, index) {
                    return _buildHorizontalCard(context, filteredSkills[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularCat(String label, dynamic icon) {
    final isSelected = selectedCategory == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedCategory == label) {
            selectedCategory = "";
          } else {
            selectedCategory = label;
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? lavenderAccent : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),

              child: Center(
                child: FaIcon(
                  icon,
                  color: isSelected ? Colors.white : lavenderAccent,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,

                color: isSelected ? lavenderAccent : secondaryText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(BuildContext context, DocumentSnapshot skillDoc) {
    final skillData = skillDoc.data() as Map<String, dynamic>;
    final skillId = skillDoc.id;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SkillDetailsScreen(skillId: skillId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?q=80&w=200',
                width: 85,
                height: 85,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skillData['title'] ?? 'No Title',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    skillData['category'] ?? 'General',
                    style: GoogleFonts.poppins(
                      color: secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const Text(
                        " 4.8",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [lavenderAccent, tealAccent],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          skillData['level'] ?? "Beginner",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
