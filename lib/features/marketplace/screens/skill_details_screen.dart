import 'package:flutter/material.dart';

class SkillDetailsScreen extends StatelessWidget {
  const SkillDetailsScreen({super.key});

  
  static const Color darkBackground = Color(0xFF13131A);
  static const Color primaryPurple = Color(0xFFA17CFF);
  static const Color cardColor = Color(0xFF1C1C26);
  static const Color textColor = Colors.white;
  static const Color textMuted = Colors.white70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      
      
      appBar: AppBar(
        backgroundColor: primaryPurple,
        elevation: 0, 
        
        
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
        
        
        centerTitle: true,
        title: const Text(
          'SKILLSWAP',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 18,
          ),
        ),
        
        
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white, size: 26),
            onPressed: () {
              
            },
          ),
          const SizedBox(width: 8), 
        ],
      ),

      body: SingleChildScrollView(
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
                    colors: [
                      darkBackground,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.3],
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
                  
                 
                  const Text(
                    'React & TypeScript Fundamentals',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),

                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard(Icons.access_time, 'Duration', '2 hours/week'),
                      _buildInfoCard(Icons.local_offer_outlined, 'Category', 'Programming'),
                      _buildInfoCard(Icons.calendar_today_outlined, 'Posted', 'Mar 10'),
                    ],
                  ),
                  const SizedBox(height: 30),

                  
                  const Text(
                    'About this skill',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Learn the basics of React and TypeScript to build modern web applications. Perfect for beginners who want to get started with frontend development. Learn the basics of React and TypeScript to build modern web applications. Perfect for beginners who want to get started with frontend development.',
                    style: TextStyle(
                      color: Colors.grey[400],
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 35),

                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: primaryPurple.withOpacity(0.3), 
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryPurple.withOpacity(0.15), 
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Your Teacher',
                          style: TextStyle(color: textMuted, fontSize: 14),
                        ),
                        const SizedBox(height: 15),
                        
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryPurple, width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'), 
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Marcus Johnson',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Computer Science',
                          style: TextStyle(color: textMuted, fontSize: 12),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Passionate about Web development and teaching others',
                          style: TextStyle(color: Colors.grey[500], fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                 
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        
                      },
                      icon: const Icon(Icons.mail_outline, color: darkBackground),
                      label: const Text(
                        'Request to Learn',
                        style: TextStyle(
                          color: darkBackground,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),

      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: darkBackground,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: primaryPurple,
          unselectedItemColor: primaryPurple.withOpacity(0.5),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.download_for_offline_outlined), label: 'Downloads'),
            BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: 'Messages'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  
  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primaryPurple, size: 20),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}