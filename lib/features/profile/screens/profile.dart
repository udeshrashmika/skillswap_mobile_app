import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- COLORS MATCHED TO YOUR UI ---
const Color bg = Colors.white;
const Color primaryDarkPurple = Color(0xFF464275);
const Color gradientStartBlue = Color(0xFF799AF8);
const Color gradientEndTeal = Color(0xFF4CC2C7);
const Color textColor = Color(0xFF1E2432);
const Color secondaryText = Color(0xFF8E95A4);
const Color starRatingColor = Color(0xFFFBA100);
const Color bottomNavActive = Color(0xFF6A9DFB);
const Color softBlueBg = Color(0xFFEEF2FF);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkillSwap Profile',
      themeMode: ThemeMode.light, 
      theme: ThemeData(
        scaffoldBackgroundColor: bg,
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: primaryDarkPurple),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String userName = "Irosh Cristeen";
    const String userUniversity = "NSBM Green University";
    const String userBio =
        "Hi, I'm a UI/UX design student. Passionate about creating clean interfaces and keen to learn Figma layouts. I can help you with beginner Python or basic Photoshop!";
    const List<String> skillsOffered = ["Beginner Python", "Basic Photoshop", "Problem Solving"];
    const List<String> skillsRequested = ["Figma Layouts", "Video Editing", "Mobile App Development"];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryDarkPurple),
          onPressed: () {
            // Me thiyenne add karapu back navigation eka
            Navigator.pop(context); 
          },
        ),
        title: const Text(
          "My Profile",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: primaryDarkPurple),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, 
          children: [
            const SizedBox(height: 10),
            // 1. Profile Picture
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
                child: Text("I", style: TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 15),

            // 2. User Info
            Text(userName, style: const TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(userUniversity, style: const TextStyle(color: secondaryText, fontSize: 15)),
            const SizedBox(height: 12),

            // 3. Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, color: starRatingColor, size: 24),
                const SizedBox(width: 4),
                const Text("4.8 (32 reviews)", style: TextStyle(color: secondaryText, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 25),

            // 4. About Me Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
                ],
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("About Me", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(userBio, style: const TextStyle(color: textColor, fontSize: 14, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 5. Skills Offered 
            _buildSkillSection(context, "Skills Offered", skillsOffered, true),
            const SizedBox(height: 25),

            // 6. Skills Requested 
            _buildSkillSection(context, "Skills Requested", skillsRequested, false),
            const SizedBox(height: 35),

            // 7. Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryDarkPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
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
            children: skills.map<Widget>((skill) {
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
                    Text(
                      skill,
                      style: TextStyle(
                        color: useGradient ? Colors.white : bottomNavActive,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        selectedItemColor: bottomNavActive,
        currentIndex: 4,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: gradientEndTeal, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
            label: 'Add',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: 'Messages'),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            activeIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: softBlueBg, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.person, color: bottomNavActive),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}