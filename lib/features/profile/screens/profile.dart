import 'history.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/screens/login.dart';

class ProfileScreen extends StatefulWidget {
  final String? uid;
  const ProfileScreen({super.key, this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const Color primaryDarkPurple = Color(0xFF464275);
  static const Color gradientStartBlue = Color(0xFF799AF8);
  static const Color gradientEndTeal = Color(0xFF4CC2C7);
  static const Color textColor = Color(0xFF1E2432);
  static const Color secondaryText = Color(0xFF8E95A4);
  static const Color starRatingColor = Color(0xFFFBA100);
  static const Color softBlueBg = Color(0xFFF8FAFF);

  late String targetUid;
  bool isMe = false;

  final List<String> defaultAvatars = [
    'https://i.pravatar.cc/150?img=11',
    'https://i.pravatar.cc/150?img=12',
    'https://i.pravatar.cc/150?img=13',
    'https://i.pravatar.cc/150?img=14',
    'https://i.pravatar.cc/150?img=32',
    'https://i.pravatar.cc/150?img=33',
    'https://i.pravatar.cc/150?img=44',
    'https://i.pravatar.cc/150?img=45',
  ];

  @override
  void initState() {
    super.initState();
    targetUid = widget.uid ?? _auth.currentUser!.uid;
    isMe = targetUid == _auth.currentUser?.uid;
  }

  Future<void> _saveBio(String newBio) async => await _firestore
      .collection('users')
      .doc(targetUid)
      .update({'bio': newBio});

  Future<void> _saveSkills(List<String> newSkills) async => await _firestore
      .collection('users')
      .doc(targetUid)
      .update({'skills': newSkills});

  Future<void> _saveAvatar(String url) async {
    await _firestore.collection('users').doc(targetUid).update({
      'profileImageUrl': url,
    });
    if (mounted) Navigator.pop(context);
  }

  void _deleteMarketplaceSkill(String docId, String title) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Remove Skill",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to stop sharing '$title' in the marketplace?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: const StadiumBorder(),
            ),
            onPressed: () async {
              await _firestore.collection('skills').doc(docId).delete();
              if (mounted) Navigator.pop(c);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(targetUid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: primaryDarkPurple),
            ),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text("Profile Not Found")));
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        String name = data['fullName'] ?? "User";
        String bio = data['bio'] ?? "";
        List<String> skills = List<String>.from(data['skills'] ?? []);
        String profilePic = data['profileImageUrl'] ?? "";
        double rating = (data['rating'] ?? 0.0).toDouble();
        int reviewCount = data['reviewCount'] ?? 0;
        String university = data['university'] ?? "SkillSwap Member";

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: primaryDarkPurple),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              isMe ? "My Profile" : "Profile",
              style: GoogleFonts.poppins(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryDarkPurple,
                        boxShadow: [
                          BoxShadow(
                            color: primaryDarkPurple.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: profilePic.isNotEmpty
                            ? Image.network(profilePic, fit: BoxFit.cover)
                            : Center(
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : "U",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    if (isMe)
                      GestureDetector(
                        onTap: _showAvatarSelectionSheet,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: gradientEndTeal,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  university,
                  style: GoogleFonts.poppins(
                    color: secondaryText,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: starRatingColor,
                      size: 24,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$rating ($reviewCount reviews)",
                      style: GoogleFonts.poppins(
                        color: secondaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                _buildSectionHeader(
                  "About Me",
                  isMe ? () => _showEditBioSheet(bio) : null,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Text(
                    bio.isEmpty ? "Tell us about yourself!" : bio,
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                _buildSectionHeader(
                  "Skills Summary",
                  isMe ? () => _showEditSkillsSheet(skills) : null,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: skills.isEmpty
                        ? [const Text("No skills added yet.")]
                        : skills.map((s) => _buildSkillChip(s)).toList(),
                  ),
                ),

                const SizedBox(height: 30),

                if (isMe) ...[
                  _buildSectionHeader("My Marketplace Posts", null),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('skills')
                        .where('userId', isEqualTo: targetUid)
                        .snapshots(),
                    builder: (context, skillSnapshot) {
                      if (!skillSnapshot.hasData ||
                          skillSnapshot.data!.docs.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: softBlueBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "You haven't shared any skills yet.",
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: skillSnapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var skillDoc = skillSnapshot.data!.docs[index];
                          var skillData =
                              skillDoc.data() as Map<String, dynamic>;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.1),
                              ),
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
                                horizontal: 16,
                                vertical: 4,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: gradientStartBlue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.bolt_rounded,
                                  color: gradientStartBlue,
                                ),
                              ),
                              title: Text(
                                skillData['title'] ?? "Untitled",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: textColor,
                                ),
                              ),
                              subtitle: Text(
                                "${skillData['category']} • ${skillData['level']}",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: secondaryText,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => _deleteMarketplaceSkill(
                                  skillDoc.id,
                                  skillData['title'],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],

                const SizedBox(height: 40),
                if (isMe) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                        ),
                      ),
                      icon: const Icon(
                        Icons.history_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Swap History",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDarkPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.redAccent,
                      ),
                      label: const Text(
                        "Logout",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(
                          color: Colors.redAccent,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onEdit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onEdit != null)
          GestureDetector(
            onTap: onEdit,
            child: const Icon(Icons.edit_note, color: secondaryText, size: 28),
          ),
      ],
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [gradientStartBlue, gradientEndTeal],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 14),
          const SizedBox(width: 8),
          Text(
            skill,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: const StadiumBorder(),
            ),
            onPressed: () async {
              await _auth.signOut();
              if (mounted)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (c) => const LoginScreen()),
                  (r) => false,
                );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAvatarSelectionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (c) => Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: defaultAvatars.length,
          itemBuilder: (c, i) => GestureDetector(
            onTap: () => _saveAvatar(defaultAvatars[i]),
            child: CircleAvatar(
              backgroundImage: NetworkImage(defaultAvatars[i]),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditBioSheet(String currentBio) {
    TextEditingController controller = TextEditingController(text: currentBio);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (c) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(c).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Text(
              "Edit Bio",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: textColor,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: softBlueBg,
                hintText: "Write something about yourself...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryDarkPurple,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                _saveBio(controller.text.trim());
                Navigator.pop(c);
              },
              child: const Text(
                "Save Changes",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSkillsSheet(List<String> currentSkills) {
    TextEditingController controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (c) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(c).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                "Manage Skills Summary",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: "Add skill (e.g. Figma)",
                        filled: true,
                        fillColor: softBlueBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      if (controller.text.isNotEmpty) {
                        setModalState(
                          () => currentSkills.add(controller.text.trim()),
                        );
                        _saveSkills(currentSkills);
                        controller.clear();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [gradientStartBlue, gradientEndTeal],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: currentSkills
                      .map(
                        (s) => Chip(
                          label: Text(
                            s,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: primaryDarkPurple,
                          deleteIcon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                          onDeleted: () {
                            setModalState(() => currentSkills.remove(s));
                            _saveSkills(currentSkills);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide.none,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
