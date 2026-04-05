import 'history.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/screens/login.dart';

const Color bg = Colors.white;
const Color primaryDarkPurple = Color(0xFF464275);
const Color gradientStartBlue = Color(0xFF799AF8);
const Color gradientEndTeal = Color(0xFF4CC2C7);
const Color textColor = Color(0xFF1E2432);
const Color secondaryText = Color(0xFF8E95A4);
const Color starRatingColor = Color(0xFFFBA100);
const Color bottomNavActive = Color(0xFF6A9DFB);
const Color softBlueBg = Color(0xFFEEF2FF);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;

  String userName = "Loading...";
  String userUniversity = "Loading...";
  String userBio = "";
  List<String> skillsOffered = [];
  String profileImageUrl = "";

  final List<String> defaultAvatars = [
    'https://i.pravatar.cc/150?img=11',
    'https://i.pravatar.cc/150?img=12',
    'https://i.pravatar.cc/150?img=13',
    'https://i.pravatar.cc/150?img=14',
    'https://i.pravatar.cc/150?img=15',
    'https://i.pravatar.cc/150?img=16',
    'https://i.pravatar.cc/150?img=17',
    'https://i.pravatar.cc/150?img=18',
    'https://i.pravatar.cc/150?img=19',
    'https://i.pravatar.cc/150?img=32',
    'https://i.pravatar.cc/150?img=33',
    'https://i.pravatar.cc/150?img=34',
    'https://i.pravatar.cc/150?img=35',
    'https://i.pravatar.cc/150?img=36',
    'https://i.pravatar.cc/150?img=37',
    'https://i.pravatar.cc/150?img=38',
    'https://i.pravatar.cc/150?img=40',
    'https://i.pravatar.cc/150?img=41',
    'https://i.pravatar.cc/150?img=42',
    'https://i.pravatar.cc/150?img=44',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? currentUser = _auth.currentUser;
    
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            userName = data['name'] ?? currentUser.displayName ?? currentUser.email ?? "No Name";
            userUniversity = data['university'] ?? "Update your university";
            userBio = data['bio'] ?? "";
            skillsOffered = List<String>.from(data['skills'] ?? []);
            profileImageUrl = data['profileImageUrl'] ?? "";
            isLoading = false;
          });
        } else {
          setState(() {
            userName = currentUser.displayName ?? currentUser.email ?? "New User";
            userUniversity = "Update your university";
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          userName = currentUser.email ?? "Error Loading Data";
          userUniversity = "Check Network/Rules";
          isLoading = false;
        });
      }
    } else {
      setState(() {
        userName = "Not Logged In";
        userUniversity = "";
        isLoading = false;
      });
    }
  }

  Future<void> _saveSelectedAvatar(String avatarUrl) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      setState(() => isLoading = true);
      try {
        await _firestore.collection('users').doc(currentUser.uid).set({
          'profileImageUrl': avatarUrl,
        }, SetOptions(merge: true));
        
        setState(() {
          profileImageUrl = avatarUrl;
          isLoading = false;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Avatar updated successfully!")),
        );
      } catch (e) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showAvatarSelectionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 20.0,
            left: 20.0,
            right: 20.0,
            bottom: 40.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose a Professional Avatar",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: defaultAvatars.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _saveSelectedAvatar(defaultAvatars[index]),
                      child: Container(
                        decoration: BoxDecoration(
                          color: softBlueBg,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: profileImageUrl == defaultAvatars[index]
                                ? gradientEndTeal
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            defaultAvatars[index],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: gradientStartBlue,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.person,
                                  color: secondaryText,
                                  size: 30,
                                ),
                              );
                            },
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
      },
    );
  }

  Future<void> _saveBio(String newBio) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore.collection('users').doc(currentUser.uid).set({
        'bio': newBio,
      }, SetOptions(merge: true));
      setState(() {
        userBio = newBio;
      });
    }
  }

  Future<void> _saveSkills(List<String> newSkills) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore.collection('users').doc(currentUser.uid).set({
        'skills': newSkills,
      }, SetOptions(merge: true));
      setState(() {
        skillsOffered = newSkills;
      });
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          content: const Text("Are you sure you want to logout from your account?", style: TextStyle(color: secondaryText)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel", style: TextStyle(color: secondaryText, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await FirebaseAuth.instance.signOut();

                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  void _showEditBioSheet() {
    TextEditingController bioController = TextEditingController(text: userBio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text("Edit About Me", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: bioController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Write a short bio about yourself...",
                    hintStyle: const TextStyle(color: secondaryText, fontSize: 13),
                    filled: true,
                    fillColor: softBlueBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryDarkPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _saveBio(bioController.text.trim());
                      Navigator.pop(context);
                    },
                    child: const Text("Save Bio", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditSkillsSheet() {
    TextEditingController skillController = TextEditingController();
    List<String> tempSkills = List.from(skillsOffered);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20, right: 20, top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text("Edit Skills Offered", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: skillController,
                            decoration: InputDecoration(
                              hintText: "Add a skill (e.g. Figma)",
                              hintStyle: const TextStyle(color: secondaryText, fontSize: 13),
                              filled: true,
                              fillColor: softBlueBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: const BoxDecoration(color: gradientEndTeal, shape: BoxShape.circle),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () {
                              if (skillController.text.trim().isNotEmpty) {
                                setModalState(() {
                                  skillsOffered.add(
                                    skillController.text.trim(),
                                  );
                                  skillController.clear();
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tempSkills.map((skill) {
                        return Chip(
                          label: Text(skill, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          backgroundColor: bottomNavActive,
                          deleteIcon: const Icon(Icons.close, color: Colors.white, size: 16),
                          onDeleted: () {
                            setModalState(() {
                              tempSkills.remove(skill);
                            });
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryDarkPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Done",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: primaryDarkPurple),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryDarkPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Profile",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
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
              child: const Center(
                child: Text(
                  "I",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(userName, style: const TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(userUniversity, style: const TextStyle(color: secondaryText, fontSize: 15)),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_rounded, color: starRatingColor, size: 24),
                SizedBox(width: 4),
                Text("4.8 (32 reviews)", style: TextStyle(color: secondaryText, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("About Me", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: _showEditBioSheet,
                        child: const Icon(Icons.edit_note, color: secondaryText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  userBio.isEmpty
                      ? GestureDetector(
                          onTap: _showEditBioSheet,
                          child: const Text(
                            "Tell us about yourself! Click here or the edit icon to add a short bio.",
                            style: TextStyle(color: secondaryText, fontStyle: FontStyle.italic, fontSize: 14),
                          ),
                        )
                      : Text(userBio, style: const TextStyle(color: textColor, fontSize: 14, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSkillSection(context, "Skills Offered", skillsOffered, true),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showLogoutDialog(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillSection(BuildContext context, String title, List<String> skills, bool useGradient) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (skills.isEmpty)
                ActionChip(
                  backgroundColor: softBlueBg,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  label: const Text("+ Add your first skill", style: TextStyle(color: bottomNavActive, fontWeight: FontWeight.bold)),
                  onPressed: _showEditSkillsSheet,
                )
              else
                ...skills.map<Widget>((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: useGradient ? null : softBlueBg,
                      gradient: useGradient
                          ? const LinearGradient(
                              colors: [gradientStartBlue, gradientEndTeal],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (useGradient) ...[
                          const CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 8,
                            child: Icon(Icons.check, color: gradientEndTeal, size: 10),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(skill, style: TextStyle(color: useGradient ? Colors.white : bottomNavActive, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  );
                }).toList(),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: primaryDarkPurple.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_rounded, color: primaryDarkPurple, size: 18),
                      SizedBox(width: 6),
                      Text(
                        "History",
                        style: TextStyle(color: primaryDarkPurple, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
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